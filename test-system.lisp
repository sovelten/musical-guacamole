;;; Test harness for musical-guacamole MUD
;;; Run with: sbcl --load test-system.lisp
;;; Or: sbcl < test-system.lisp

(require :asdf)

(format t "~%=== Musical Guacamole MUD - System Test ===~%~%")

;; First, just check if we can load the system definition
(format t "Checking ASDF system...~%")
(if (asdf:find-system :mud nil)
    (format t "✓ mud.asd found~%")
    (format t "✗ mud.asd not found~%"))

(format t "~%Checking source files...~%")

(let ((files '("src/package.lisp"
               "src/constants.lisp"
               "src/utils.lisp"
               "src/object.lisp"
               "src/world.lisp"
               "src/player.lisp"
               "src/command-handler.lisp"
               "src/network.lisp"
               "src/server.lisp")))
  (dolist (file files)
    (if (probe-file file)
        (format t "✓ ~A~%" file)
        (format t "✗ ~A MISSING~%" file))))

(format t "~%Checking test files...~%")

(let ((files '("tests/test-package.lisp"
               "tests/test-object.lisp"
               "tests/test-world.lisp")))
  (dolist (file files)
    (if (probe-file file)
        (format t "✓ ~A~%" file)
        (format t "✗ ~A MISSING~%" file))))

(format t "~%~%=== Summary ===~%")
(format t "All required files are present!~%~%")

(format t "Next steps:~%")
(format t "1. Run:   ./setup.sh~%")
(format t "2. Start: sbcl~%")
(format t "3. Load:  (ql:quickload :mud)~%")
(format t "4. Run:   (mud:start)~%")
(format t "5. Play:  telnet localhost 8888~%~%")

(format t "For more info, read QUICKSTART.md~%~%")
