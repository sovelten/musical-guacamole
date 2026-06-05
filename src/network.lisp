(in-package #:mud)

(defvar *server-running* nil)
(defvar *server-socket* nil)
(defvar *acceptance-thread* nil)
(defvar *session-threads* (make-hash-table :test #'equal))
(defvar *server-lock* (bordeaux-threads:make-lock "server-lock"))

(defun handle-client (session)
  (handler-case
      (let ((socket (session-socket session)))
        (loop while *server-running*
              do
              (handler-case
                  (let ((stream (usocket:socket-stream socket)))
                    (if (null stream) (return)
                        (progn
                          (when (session-character session)
                            (player-send-prompt (session-character session)))
                          (let ((line (read-line stream nil nil)))
                            (if line
                                (let ((trimmed (string-trim '(#\Return #\Newline) line)))
                                  (when (and trimmed (> (length trimmed) 0))
                                    (if (session-character session)
                                        (process-command (session-character session) trimmed)
                                        (process-auth-command session trimmed))))
                                (return))))))
                (end-of-file () (return))
                (error (e) (mud.utils:log-error "Client error: ~A" e) (return)))))
    (error (e) (mud.utils:log-error "Session error: ~A" e)))
  (let ((character (session-character session)))
    (when character (player-disconnect character))
    (mud.utils:log-message "Session disconnected")))

(defun accept-connections ()
  (loop while *server-running*
        do
        (handler-case
            (let ((client-socket (usocket:socket-accept *server-socket*)))
              (when client-socket
                (let ((session (make-instance 'mud-session :socket client-socket)))
                  (bordeaux-threads:make-thread (lambda () (handle-client session))))))
          (error (e) (mud.utils:log-error "Accept error: ~A" e)))))

(defun start-mud-server (&key (host *server-host*) (port *server-port*))
  (bordeaux-threads:with-lock-held (*server-lock*)
    (if *server-running* nil
        (progn
          (world-initialize)
          (setf *server-socket* (usocket:socket-listen host port :reuse-address t))
          (setf *server-running* t)
          (setf *acceptance-thread* (bordeaux-threads:make-thread #'accept-connections))
          t))))

(defun process-auth-command (session command-string)
  (multiple-value-bind (command args) (parse-command command-string)
    (cond
      ((string= command "login") (login-returning-player session (usocket:socket-stream (session-socket session))))
      ((string= command "register") (register-new-account session (usocket:socket-stream (session-socket session))))
      (t (player-send-message session "You must log in. Type 'login' or 'register'.")))))
