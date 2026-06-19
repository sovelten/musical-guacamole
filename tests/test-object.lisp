(in-package #:mud-test)

(in-suite mud-tests)

(test object-creation
  "Test that we can create basic objects"
  (let ((obj (mud:new-object :name "Test Object")))
    (is (stringp (mud:object-describe obj)))
    (is (equal (mud:object-name obj) "Test Object"))))

(test object-properties
  "Test object property storage"
  (let ((obj (mud:new-object)))
    (mud:object-set-property obj "test-prop" "test-value")
    (is (equal (mud:object-get-property obj "test-prop") "test-value"))))

(test print-object-mud-object
      "Test print-object for mud-object"
      (let* ((obj (mud:new-object :name "Test Object"))
             (out (with-output-to-string (s) (print-object obj s))))
        (is (string-equal (format nil "#<MUD:MUD-OBJECT Test Object (ID: ~D)>" (mud:object-id obj))
                          out))))

(test print-object-mud-room
  "Test print-object for mud-room"
  (let ((room (mud:new-room :name "Test Room")))
    (is (string-equal
         (format nil "#<MUD:MUD-ROOM Test Room (ID: ~D)>" (mud:object-id room))
         (with-output-to-string (s) (print-object room s))))))

(test world-object-lookup
  "Test that objects registered in a world are findable via world-level queries"
  (let ((world (mud:new-world)))
    (let ((obj (mud:new-object :name "Test Object"))
          (obj2 (mud:new-object :name "Test Object 2")))
      (mud:world-set-object-id! world obj)
      (mud:world-set-object-id! world obj2)
      (is (equal obj (mud:world-object-by-id world (mud:object-id obj))))
      (is (equal obj2 (first (mud:world-object-with-name world "Test Object 2"))))
      (is (= 2 (length (mud:world-all-objects world)))))))
