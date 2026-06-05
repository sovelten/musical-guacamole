(in-package #:mud)

(defvar *commands* (make-hash-table :test #'equal))

(defmacro define-command (name (session args) &body body)
  `(setf (gethash ,name *commands*)
         (lambda (,session ,args)
           (let ((character (session-character ,session)))
             (if character (progn ,@body)
                 (player-send-message ,session "Log in first!"))))))

(define-command "look" (session args)
  (declare (ignore args))
  (let ((room (object-location (session-character session))))
    (player-send-message (session-character session) (room-describe room))))

(defun process-command (session command-string)
  (multiple-value-bind (command args) (parse-command command-string)
    (let ((handler (gethash command *commands*)))
      (if handler (funcall handler session args)
          (player-send-message (session-character session) "Unknown command.")))))

(defun parse-command (input)
  (let ((trimmed (string-trim '(#\Space #\Tab) input)))
    (if (zerop (length trimmed)) (values nil "")
        (let ((space-pos (position #\Space trimmed)))
          (if space-pos
              (values (string-downcase (subseq trimmed 0 space-pos))
                      (string-trim '(#\Space #\Tab) (subseq trimmed (1+ space-pos))))
              (values (string-downcase trimmed) ""))))))
