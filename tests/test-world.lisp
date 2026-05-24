(in-package #:mud.tests)

(in-suite mud-tests)

(test world-initialization
  "Test that the world initializes properly"
  (mud:world-initialize)
  (is (not (null mud:*start-room*)))
  (is (> (hash-table-count mud:*world*) 0)))

(test room-connectivity
  "Test that rooms are properly connected"
  (mud:world-initialize)
  (let ((room1 (mud:create-room :name "Room 1"))
        (room2 (mud:create-room :name "Room 2")))
    (mud:room-add-exit room1 "north" room2)
    (mud:room-add-exit room2 "south" room1)
    (is (eq (mud:room-get-exit room1 "north") room2))
    (is (eq (mud:room-get-exit room2 "south") room1))))
