#!/usr/bin/env sbcl --script
;;; Test harness for musical-guacamole MUD
;;; Run this file to verify the MUD system is properly set up

(require :asdf)
(push #p"./" asdf:*central-registry*)

(format t "~%=== Musical Guacamole MUD - System Test ===~%~%")

;; Load dependencies
(format t "Loading dependencies...~%")
(handler-case
    (ql:quickload (list "usocket" "bordeaux-threads"))
  (error (e)
    (format t "ERROR: Failed to load dependencies: ~A~%" e)
    (quit 1)))

;; Load MUD system
(format t "Loading MUD system...~%")
(handler-case
    (asdf:load-system :mud)
  (error (e)
    (format t "ERROR: Failed to load MUD system: ~A~%" e)
    (quit 1)))

(format t "~%=== Running Tests ===~%~%")

;; Run basic tests
(let ((test-count 0)
      (pass-count 0))
  
  ;; Test 1: Object creation
  (incf test-count)
  (format t "Test 1: Object creation... ")
  (handler-case
      (let ((obj (mud:create-object :name "Test Object")))
        (if (and (stringp (mud:object-describe obj))
                 (equal (mud:object-name obj) "Test Object"))
            (progn (incf pass-count) (format t "PASS~%"))
            (format t "FAIL~%")))
    (error (e) (format t "FAIL: ~A~%" e)))
  
  ;; Test 2: Object properties
  (incf test-count)
  (format t "Test 2: Object properties... ")
  (handler-case
      (let ((obj (mud:create-object)))
        (mud:object-set-property obj "test" "value")
        (if (equal (mud:object-get-property obj "test") "value")
            (progn (incf pass-count) (format t "PASS~%"))
            (format t "FAIL~%")))
    (error (e) (format t "FAIL: ~A~%" e)))
  
  ;; Test 3: Room creation
  (incf test-count)
  (format t "Test 3: Room creation... ")
  (handler-case
      (let ((room (mud:create-room :name "Test Room")))
        (if (typep room 'mud:mud-room)
            (progn (incf pass-count) (format t "PASS~%"))
            (format t "FAIL~%")))
    (error (e) (format t "FAIL: ~A~%" e)))
  
  ;; Test 4: Room contents
  (incf test-count)
  (format t "Test 4: Room contents... ")
  (handler-case
      (let ((room (mud:create-room))
            (obj (mud:create-object)))
        (mud:room-add-object room obj)
        (if (> (length (mud:room-contents room)) 0)
            (progn (incf pass-count) (format t "PASS~%"))
            (format t "FAIL~%")))
    (error (e) (format t "FAIL: ~A~%" e)))
  
  ;; Test 5: Room exits
  (incf test-count)
  (format t "Test 5: Room exits... ")
  (handler-case
      (let ((room1 (mud:create-room :name "Room 1"))
            (room2 (mud:create-room :name "Room 2")))
        (mud:room-add-exit room1 "north" room2)
        (if (eq (mud:room-get-exit room1 "north") room2)
            (progn (incf pass-count) (format t "PASS~%"))
            (format t "FAIL~%")))
    (error (e) (format t "FAIL: ~A~%" e)))
  
  ;; Test 6: World initialization
  (incf test-count)
  (format t "Test 6: World initialization... ")
  (handler-case
      (progn
        (mud:world-initialize)
        (if (and (not (null mud::*start-room*))
                 (> (hash-table-count mud::*world*) 0))
            (progn (incf pass-count) (format t "PASS~%"))
            (format t "FAIL~%")))
    (error (e) (format t "FAIL: ~A~%" e)))
  
  ;; Test 7: Command parsing
  (incf test-count)
  (format t "Test 7: Command parsing... ")
  (handler-case
      (multiple-value-bind (cmd args) (mud::parse-command "go north")
        (if (and (equal cmd "go") (equal args '("north")))
            (progn (incf pass-count) (format t "PASS~%"))
            (format t "FAIL~%")))
    (error (e) (format t "FAIL: ~A~%" e)))
  
  ;; Print summary
  (format t "~%~%=== Test Summary ===~%")
  (format t "Passed: ~D/~D~%" pass-count test-count)
  (if (= pass-count test-count)
      (format t "~%✓ All tests passed! The MUD system is ready to use.~%~%")
      (format t "~%✗ Some tests failed. Please check the system.~%~%")))

(format t "To start the server:~%")
(format t "  (ql:quickload :mud)~%")
(format t "  (mud:start)~%~%")
(format t "Then connect with: telnet localhost 8888~%~%")

(quit 0)
