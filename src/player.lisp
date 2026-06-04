(in-package #:mud)

;; Player class - a specialized mud-object with network connection

(defclass mud-player (mud-object)
  ((session :initarg :session
            :accessor player-session
            :initform nil
            :documentation "The session controlling this player")
   (inventory :initarg :inventory
              :accessor player-inventory
              :initform (make-array 0 :adjustable t :fill-pointer t)
              :documentation "Items the player carries"))
  (:documentation "A player character in the MUD"))

(defclass mud-session ()
  ((socket :initarg :socket
           :accessor session-socket
           :documentation "Network socket for this session")
   (player :initarg :player
           :accessor session-player
           :initform nil
           :documentation "Player controlled by this session")
   (input-buffer :initarg :input-buffer
                 :accessor session-input-buffer
                 :initform ""
                 :documentation "Accumulated input from the session"))
  (:documentation "A network session in the MUD"))

(defun create-player (name session)
  "Create a new player."
  (let ((player (make-instance 'mud-player
                               :id (mud.utils:make-id)
                               :name name
                               :type +object-type-player+
                               :session session
                               :location *start-room*)))
    ;; Link player to session
    (setf (session-player session) player)
    ;; Add player to starting room
    (when *start-room*
      (room-add-object *start-room* player))
    ;; Register player globally
    (world-add-player player)
    player))

(defun player-inventory-add (player obj)
  "Add an object to a player's inventory."
  (vector-push-extend obj (player-inventory player)))

(defun player-inventory-remove (player obj)
  "Remove an object from a player's inventory."
  (setf (player-inventory player)
        (delete obj (player-inventory player))))

(defun player-send-message (player message &key (newline t))
  "Send a message to a player. If NEWLINE is nil, don't add a trailing newline."
  (let ((session (player-session player)))
    (when session
      (handler-case
          (let ((stream (usocket:socket-stream (session-socket session))))
            (when stream
              (if newline
                  (format stream "~A~%" message)
                  (format stream "~A" message))
              (force-output stream)))
        (error (e)
          ;; Only log if it's not a connection error
          (let ((error-str (format nil "~A" e)))
            (unless (or (search "Broken pipe" error-str)
                        (search "closed" error-str))
              (mud.utils:log-error "Failed to send message to player ~A: ~A" 
                                  (object-name player) e))))))))

(defun player-send-prompt (player)
  "Send a prompt to a player on the same line (no newline)."
  (player-send-message player "> " :newline nil))

(defun player-set-input-buffer (player text)
  "Set the input buffer for a player."
  (let ((session (player-session player)))
    (when session
      (setf (session-input-buffer session) text))))

(defun player-get-input-buffer (player)
  "Get the input buffer for a player."
  (let ((session (player-session player)))
    (when session
      (session-input-buffer session))))

(defun player-clear-input-buffer (player)
  "Clear the input buffer for a player."
  (let ((session (player-session player)))
    (when session
      (setf (session-input-buffer session) ""))))

(defun player-disconnect (player)
  "Disconnect a player from the MUD."
  (mud.utils:log-message "Player ~A disconnecting" (object-name player))
  (let ((room (object-location player))
        (session (player-session player)))
    ;; Remove from room
    (when (typep room 'mud-room)
      (room-remove-object room player))
    ;; Remove from world
    (world-remove-player (object-id player))
    ;; Close socket if it exists
    (when (and session (session-socket session))
      (handler-case
          (usocket:socket-close (session-socket session))
        (error (e)
          (mud.utils:log-error "Error closing socket for ~A: ~A" 
                              (object-name player) e))))))
