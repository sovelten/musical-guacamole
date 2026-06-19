(in-package #:mud-test)

(in-suite mud-tests)

(test room-creation
  "Test that we can create rooms"
  (let ((room (mud:new-room :name "Test Room")))
    (is (typep room 'mud:mud-room))
    (is (equal (mud:object-name room) "Test Room"))))

(test room-contents
  "Test room contents management"
  (let ((room (mud:new-room))
        (obj (mud:new-room)))
    (mud:room-add-object room obj)
    (is (> (length (mud:room-contents room)) 0))))

(test room-exits
  "Test room exit management"
  (let ((room1 (mud:new-room :name "Room 1"))
        (room2 (mud:new-room :name "Room 2")))
    (mud:room-add-exit room1 "north" room2)
    (is (eq (mud:room-get-exit room1 "north") room2))))

(test room-add-exits
  "Test room exit management"
  (let ((room1 (mud:new-room :name "Room 1"))
        (room2 (mud:new-room :name "Room 2")))
    (mud:room-add-exits room1 "north" room2 "south")
    (is (eq (mud:room-get-exit room1 "north") room2))
    (is (eq (mud:room-get-exit room2 "south") room1))))
