(in-package #:mud)

;; Entry point to start the MUD server
(defun start ()
  "Start the MUD server with default settings."
  (when (start-mud-server)
    ;; Keep the main thread alive while server is running
    (loop while *server-running*
          do (sleep 1))))

(defun status ()
  "Print the server status."
  (format t "~A" (get-server-status)))

(defun stop ()
  "Stop the MUD server."
  (stop-mud-server))
