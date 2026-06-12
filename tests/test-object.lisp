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

(test guestbook-creation-and-methods
  "Test that we can create a guestbook, add entries, and format them"
  (let ((gb (mud::new-guestbook :name "test guestbook")))
    (is (typep gb 'mud::mud-guestbook))
    (is (equal (mud:object-name gb) "test guestbook"))
    (is (null (mud::guestbook-entries gb)))
    
    ;; Test adding an entry
    (mud::guestbook-add-entry gb "Sophia" "Hello, MUD!")
    (let ((entries (mud::guestbook-entries gb)))
      (is (= (length entries) 1))
      (is (equal (getf (first entries) :author) "Sophia"))
      (is (equal (getf (first entries) :message) "Hello, MUD!"))
      (is (numberp (getf (first entries) :timestamp))))
    
    ;; Test formatted output
    (let ((formatted (mud::guestbook-format-entries gb)))
      (is (search "test guestbook" formatted))
      (is (search "Sophia wrote:" formatted))
      (is (search "Hello, MUD!" formatted)))))

(test guestbook-commands
  "Test the read and write commands for a guestbook"
  (mud:world-restore-or-initialize :force-new t)
  (let ((player (mud:new-character "TestPlayer" (make-instance 'mud:mud-session :socket nil)))
        (captured-messages '()))
    (mud:world-new-character player)
    (let ((original-send-message (fdefinition 'mud:player-send-message)))
      (unwind-protect
           (progn
             (setf (fdefinition 'mud:player-send-message)
                   (lambda (p msg &key newline)
                     (declare (ignore p newline))
                     (push msg captured-messages)))
             
             ;; 1. Check reading empty/initial guestbook in Tavern
             (setf captured-messages '())
             (mud:process-command player "read guestbook")
             (is (= 1 (length captured-messages)))
             (is (search "The guestbook is currently empty" (car captured-messages)))
             
             ;; 2. Write a message to the guestbook
             (setf captured-messages '())
             (mud:process-command player "write guestbook Hello World!")
             ;; Should acknowledge writing
             (is (member "You write your message in the guestbook." captured-messages :test #'string=))
             
             ;; 3. Read guestbook again to verify message is there
             (setf captured-messages '())
             (mud:process-command player "read")
             (is (= 1 (length captured-messages)))
             (is (search "TestPlayer wrote:" (car captured-messages)))
             (is (search "Hello World!" (car captured-messages)))

             ;; 4. Test "write" with no message
             (setf captured-messages '())
             (mud:process-command player "write")
             (is (search "Write what?" (car captured-messages))))
        (setf (fdefinition 'mud:player-send-message) original-send-message)))))

(test guestbook-persistence
  "Test that guestbook entries are persistent across world reloads"
  (let ((original-id-counter mud.utils::*id-counter*)
        (original-system mud:*system*))
    (unwind-protect
         (progn
           ;; 1. Force a new world initialization
           (setf mud.utils::*id-counter* 0)
           (mud:world-restore-or-initialize :force-new t)
           
           ;; Find the tavern and the guestbook inside it
           (let* ((tavern (mud:room-by-id 1))
                  (guestbook (find-if (lambda (obj) (typep obj 'mud::mud-guestbook)) (mud:room-contents tavern))))
             (is (not (null guestbook)))
             
             ;; 2. Write a persistent entry using the transaction function
             (mud::write-guestbook-entry! 1 (mud:object-id guestbook) "Sophia" "Persistent message!")
             
             ;; 3. Close the prevalence system and reload from disk (simulating server restart)
             (cl-prevalence:close-open-streams mud:*system*)
             (setf mud.utils::*id-counter* 0)
             (mud:world-restore-or-initialize :force-new nil)
             
             ;; 4. Check that the reloaded room contains the guestbook with the message
             (let* ((reloaded-tavern (mud:room-by-id 1))
                    (reloaded-guestbook (find-if (lambda (obj) (typep obj 'mud::mud-guestbook)) (mud:room-contents reloaded-tavern))))
               (is (not (null reloaded-guestbook)))
               (let ((entries (mud::guestbook-entries reloaded-guestbook)))
                 (is (= (length entries) 1))
                 (is (equal (getf (first entries) :author) "Sophia"))
                 (is (equal (getf (first entries) :message) "Persistent message!"))))))
      ;; Restore original state
      (setf mud.utils::*id-counter* original-id-counter)
      (setf mud:*system* original-system))))
