(in-package #:mud.tests)

(in-suite mud-tests)

(test object-creation
  "Test that we can create basic objects"
  (let ((obj (mud:create-object :name "Test Object")))
    (is (stringp (mud:object-describe obj)))
    (is (equal (mud:object-name obj) "Test Object"))))

(test object-properties
  "Test object property storage"
  (let ((obj (mud:create-object)))
    (mud:object-set-property obj "test-prop" "test-value")
    (is (equal (mud:object-get-property obj "test-prop") "test-value"))))

(test room-creation
  "Test that we can create rooms"
  (let ((room (mud:create-room :name "Test Room")))
    (is (typep room 'mud:mud-room))
    (is (equal (mud:object-name room) "Test Room"))))

(test room-contents
  "Test room contents management"
  (let ((room (mud:create-room))
        (obj (mud:create-object)))
    (mud:room-add-object room obj)
    (is (> (length (mud:room-contents room)) 0))))

(test room-exits
  "Test room exit management"
  (let ((room1 (mud:create-room :name "Room 1"))
        (room2 (mud:create-room :name "Room 2")))
    (mud:room-add-exit room1 "north" room2)
    (is (eq (mud:room-get-exit room1 "north") room2))))
