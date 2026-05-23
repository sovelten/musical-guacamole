(defpackage #:mud.tests
  (:use #:cl #:fiveam)
  (:export #:run-tests))

(in-package #:mud.tests)

(def-suite mud-tests :description "Tests for the MUD server")

(defun run-tests ()
  "Run all MUD tests."
  (run! 'mud-tests))
