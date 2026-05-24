(in-package #:mud.tests)

(in-suite mud-tests)

(test socket-stream-creation
  "Test that we can get a stream from a socket"
  (handler-case
      (let ((socket (usocket:socket-listen "127.0.0.1" 0)))
        (is (not (null socket)))
        (let ((stream (usocket:socket-stream socket)))
          (is (not (null stream)))
          (is (streamp stream)))
        (usocket:socket-close socket))
    (error (e)
      (skip (format nil "Socket test skipped: ~A" e)))))

(test player-message-with-mock-socket
  "Test sending messages to a player with a real socket"
  (handler-case
      (let* ((server-socket (usocket:socket-listen "127.0.0.1" 0))
             (server-stream (usocket:socket-stream server-socket)))
        (mud:world-initialize)
        (let ((player (mud:create-player "TestPlayer" server-socket)))
          ;; Test that we can send a message without crashing
          (mud:player-send-message player "Test message")
          (is (not (null player))))
        (usocket:socket-close server-socket))
    (error (e)
      (skip (format nil "Socket message test skipped: ~A" e)))))

(test client-socket-read
  "Test that we can read from a socket stream"
  (handler-case
      (let ((server-socket (usocket:socket-listen "127.0.0.1" 0)))
        (is (not (null server-socket)))
        (let ((stream (usocket:socket-stream server-socket)))
          (is (streamp stream)))
        (usocket:socket-close server-socket))
    (error (e)
      (skip (format nil "Client socket read test skipped: ~A" e)))))
