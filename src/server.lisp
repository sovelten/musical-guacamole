(in-package #:mud)

;; Entry point to start the MUD server
(defun start ()
  "Start the MUD server with default settings."
  (start-mud-server))

(defun status ()
  "Print the server status."
  (format t "~A" (get-server-status)))

(defun stop ()
  "Stop the MUD server."
  (stop-mud-server))
