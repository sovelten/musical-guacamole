(in-package #:mud)

(defvar *server-running* nil)
(defvar *server-socket* nil)
(defvar *player-threads* (make-hash-table :test #'equal))
(defvar *server-lock* (bordeaux-threads:make-lock "server-lock"))

(defun handle-client (player)
  "Main loop for handling a client connection."
  (handler-case
      (let ((socket (player-socket player)))
        (loop while *server-running*
              do
              (handler-case
                  (progn
                    ;; Send prompt
                    (player-send-prompt player)
                    
                    ;; Try to read from socket using socket-stream
                    (let ((stream (handler-case
                                    (usocket:socket-stream socket)
                                    (error () nil))))
                      (when stream
                        (let ((line (read-line stream nil nil)))
                          (when line
                            (let ((trimmed (string-trim '(#\Return #\Newline) line)))
                              (when (and trimmed (> (length trimmed) 0))
                                (process-command player trimmed)))))))
                    )
                (end-of-file ()
                  ;; Connection closed by client
                  (mud.utils:log-message "Client ~A disconnected" (object-name player))
                  (return))
                (error (e)
                  (mud.utils:log-error "Error in client handler: ~A" e)
                  (return)))))
    (error (e)
      (mud.utils:log-error "Client handler error for ~A: ~A" (object-name player) e)))
  
  ;; Cleanup when disconnected
  (player-disconnect player))

(defun accept-connections ()
  "Accept incoming client connections."
  (handler-case
      (loop while *server-running*
            do
            (handler-case
                (let ((client-socket (usocket:socket-accept *server-socket*)))
                  (when client-socket
                    (let ((player-name (format nil "Player~D" (random 10000))))
                      (mud.utils:log-message "New connection: ~A" player-name)
                      
                      ;; Create player
                      (let ((player (create-player player-name client-socket)))
                        ;; Send welcome message
                        (player-send-message player "Welcome to the MUD!")
                        (player-send-message player (room-describe (object-location player)))
                        
                        ;; Start player thread
                        (let ((thread (bordeaux-threads:make-thread
                                      (lambda () (handle-client player))
                                      :name (format nil "player-~A" (object-id player)))))
                          (setf (gethash (object-id player) *player-threads*) thread))))))
              (usocket:timeout-error ()
                ;; Just a timeout, continue accepting
                nil)
              (error (e)
                (mud.utils:log-error "Error accepting connection: ~A" e))))
    (error (e)
      (mud.utils:log-error "Accept connections error: ~A" e))))

(defun start-mud-server (&key (host *server-host*) (port *server-port*))
  "Start the MUD server."
  (bordeaux-threads:with-lock-held (*server-lock*)
    (if *server-running*
        (progn
          (mud.utils:log-error "Server is already running!")
          (return-from start-mud-server nil))
        (progn
          ;; Initialize world
          (world-initialize)
          
          ;; Create server socket
          (setf *server-socket* (usocket:socket-listen host port 
                                                       :reuse-address t
                                                       :backlog 5))
          (setf *server-running* t)
          
          (mud.utils:log-message "MUD Server started on ~A:~D" host port)
          
          ;; Start acceptance thread
          (bordeaux-threads:make-thread #'accept-connections :name "accept-connections")
          
          t))))

(defun stop-mud-server ()
  "Stop the MUD server."
  (bordeaux-threads:with-lock-held (*server-lock*)
    (when *server-running*
      (setf *server-running* nil)
      
      ;; Disconnect all players
      (dolist (player (world-all-players))
        (player-disconnect player))
      
      ;; Close server socket
      (when *server-socket*
        (usocket:socket-close *server-socket*)
        (setf *server-socket* nil))
      
      (mud.utils:log-message "MUD Server stopped")
      t)))

(defun get-server-status ()
  "Get the current status of the server."
  (format nil "Server running: ~A~%Players online: ~D~%Rooms in world: ~D~%"
          (if *server-running* "Yes" "No")
          (hash-table-count *players*)
          (hash-table-count *world*)))
