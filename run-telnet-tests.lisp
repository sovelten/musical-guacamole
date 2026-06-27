(unless (find-package :quicklisp)
  (load "/home/sophia/.quicklisp/setup.lisp"))

(push #p"./" asdf:*central-registry*)

(asdf:load-asd #P"./apeiron.asd")
(asdf:load-asd #P"./apeiron-test.asd")
(ql:quickload :apeiron-test)

(in-package #:apeiron-test)

;; Run only the telnet unit tests
(let ((tests '(telnet-read-char-plain-ascii
               telnet-read-char-multiple-ascii
               telnet-read-char-first-byte-is-iac
               telnet-read-char-skips-iac-will-echo
               telnet-read-char-iac-iac-literal-255
               telnet-read-line-plain
               telnet-read-line-skips-initial-negotiation
               telnet-read-line-utf8-multibyte
               telnet-read-line-utf8-split-across-reads
               telnet-read-line-bare-lf
               telnet-naws-subnegotiation-updates-window
               telnet-terminal-type-subnegotiation
               telnet-iac-escape-doubles-iac
               telnet-read-char-eof
               telnet-write-read-roundtrip
               ;; Backspace / erase handling
               telnet-read-line-bs-erases-char
               telnet-read-line-del-erases-char
               telnet-read-line-bs-at-empty-buffer
               telnet-read-line-iac-ec-erases-char
               telnet-read-line-iac-el-erases-line
               telnet-read-line-multiple-bs
               ;; Negotiation
               telnet-init-negotiation-includes-will-echo
               telnet-do-after-will-no-loop
               telnet-dont-after-will-clears-pending)))
  (dolist (test tests)
    (format t "~%=== ~S ===~%" test)
    (handler-case
        (run! test)
      (error (e)
        (format t "ERROR: ~A~%" e)))))

;; Exit cleanly
(sb-ext:exit :code 0)
