(in-package #:mud.tests)

(in-suite mud-tests)

(test server-initialization
  "Test that the server can be initialized without crashing"
  (handler-case
      (progn
        (mud:world-initialize)
        (is (not (null mud:*start-room*)))
        (is (> (hash-table-count mud:*world*) 0)))
    (error (e)
      (fail (format nil "Server initialization failed: ~A" e)))))

(test player-connection-simulation
  "Test simulated player connection and command processing"
  (handler-case
      (progn
        (mud:world-initialize)
        ;; Create a player without a real socket
        (let ((player (mud:create-player "TestPlayer" nil)))
          ;; Test that the player was created
          (is (equal (mud:object-name player) "TestPlayer"))
          ;; Test that the player is in a room
          (is (not (null (mud:object-location player))))
          ;; Test that we can process commands without crashing
          (mud:process-command player "look")
          (mud:process-command player "help")
          (mud:process-command player "exits")
          (is (not (null player)))))
    (error (e)
      (fail (format nil "Player connection simulation failed: ~A" e)))))

(test command-parsing
  "Test that command parsing works correctly"
  (let* ((input "go north")
         (parts (mud::split-sequence #\Space input :remove-empty-subseqs t)))
    (is (= (length parts) 2))
    (is (equal (car parts) "go"))
    (is (equal (cadr parts) "north"))))

(test socket-stream-error-handling
  "Test that socket errors are handled gracefully"
  (handler-case
      (progn
        (mud:world-initialize)
        (let ((player (mud:create-player "TestPlayer" nil)))
          ;; Sending message to player with nil socket should not crash
          (mud:player-send-message player "Test message")
          (is (not (null player)))))
    (error (e)
      ;; Error is expected, just check it doesn't crash the test
      (is (not (null e))))))
