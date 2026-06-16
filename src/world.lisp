(in-package #:mud)

(defvar *players* (make-hash-table :test #'equal)
  "Hash table storing all active players, keyed by player object ID")

(defvar *system-location* #p"./prevalence/")
(defvar *system* nil)
(defvar *world* nil
  "The single MUD world instance holding all persistent state")

(defclass mud-world ()
    ((id-counter :initarg :id-counter
                 :accessor world-id-counter
                 :initform 0
                 :documentation "id counter")
     (config :initarg config
             :accessor world-config
             :initform (make-hash-table)
             :documentation "Configuration hash map")
     (rooms :initarg :rooms
            :accessor world-rooms
            :initform (make-hash-table)
            :documentation "All rooms")
     (objects :initarg :objects
              :accessor world-objects
              :initform (make-hash-table)
              :documentation "All objects")
     (players :initarg :players
              :accessor world-players
              :initform (make-hash-table)
              :documentation "All players")))

(defun new-world () (make-instance 'mud-world))

(defun world-gen-id (world)
  ;; Increment id counter and return new id
  (incf (world-id-counter world)))

(defun world-add-room (world room)
  (let ((id (world-gen-id world)))
    (setf (object-id room) id)
    (setf (gethash id (world-rooms world)) room)))

(defun world-add-object (world object)
  (let ((id (world-gen-id world)))
    (setf (object-id object) id)
    (setf (gethash id (world-objects world)) object)))

(defun world-set-starting-room (world room)
  (setf (gethash :starting-room-id (world-config world)) (object-id room)))

(defun initial-world ()
  (let ((tavern (new-room :name "The Tavern" :description "There is a guestbook on top of a table. Hint: type \"write\" to write an entry on the guestbook."))
        (forest (new-room :name "A Dense Forest"))
        (guestbook (new-guestbook :name "a guestbook"))
        (world (new-world)))
    (room-add-object tavern guestbook)
    (room-add-exit tavern "north" forest)
    (room-add-exit forest "south" tavern)
    (world-add-object world guestbook)
    (world-add-room world tavern)
    (world-add-room world forest)
    (world-set-starting-room world tavern)
    world))

;; BKNR

(make-instance 'bknr.datastore:mp-store :directory #p"./bknr/"
               :subsystems (list (make-instance 'bknr.datastore:store-object-subsystem)))

;; NOT PERSISTED

(defun total-players ()
  (hash-table-count *players*))

(defun add-character (character)
  "Add a player to the world."
  (setf (gethash (object-id character) *players*) character))

(defun remove-character (character)
  "Remove a player from the world."
  (mud.utils:log-message "Character ~A leaving" (object-name character))
  (let ((room (object-location character)))
    (mud.utils:log-message "Removing from ~A" (object-name room))
    ;; Remove from room
    (when (typep room 'mud-room)
      (room-remove-object room character))
    ;; Remove from world
    (mud.utils:log-message "Removing ~A from world" (object-name character))
    (remhash (object-id character) *players*)
    (mud.utils:log-message "Removed")))

(defun character-by-id (char-id)
  "Get a player by ID."
  (gethash char-id *players*))

(defun characters ()
  "Get all active players."
  (loop for player being the hash-values of *players*
        collect player))

(defun find-character-in-room (room player-name)
  "Find a player in a room by name."
  (loop for obj across (room-contents room)
        when (and (typep obj 'mud-character)
                  (string-equal (object-name obj) player-name))
        return obj))

(defun world-broadcast (message &optional exclude-player)
  "Broadcast a message to all players (optionally excluding one)."
  (dolist (player (characters))
    (unless (and exclude-player (eq (object-id player) (object-id exclude-player)))
      (player-send-message player message))))

;; CL-PREVALENCE SNAPSHOT PERSISTENCE

(defun sync-world ()
  "Persist the current world state to cl-prevalence via snapshot."
  (setf (cl-prevalence:get-root-object *system* :world) *world*)
  (cl-prevalence:snapshot *system*)
  t)

;; WORLD ACCESSORS

(defun total-rooms ()
  "Get the total number of rooms in the world."
  (hash-table-count (world-rooms *world*)))

(defun room-by-id (room-id)
  "Get a room from the world by ID."
  (gethash room-id (world-rooms *world*)))

(defun rooms ()
  "Get all rooms in the world."
  (let ((rooms (world-rooms *world*)))
    (if rooms
        (loop for room being the hash-values of rooms
              collect room)
        nil)))

(defun get-config-key (key)
  "Get a configuration value from the world config."
  (gethash key (world-config *world*)))

(defun starting-room ()
  "Get the starting room of the world."
  (room-by-id (get-config-key :starting-room-id)))

(defun world-restore-or-initialize (&key force-new (location *system-location*))
  "Restore the world from prevalence or initialize a new one.
If FORCE-NEW is true, any existing persisted data is cleared first."
  (when force-new
    (mud.utils:log-message "Forcing new world generation, clearing existing prevalence data...")
    (uiop:delete-directory-tree location :validate (constantly t) :if-does-not-exist :ignore))
  (setf *system* (cl-prevalence:make-prevalence-system location))
  (let ((restored (cl-prevalence:get-root-object *system* :world)))
    (if (and restored (typep restored 'mud-world))
        (progn
          (setf *world* restored)
          (when *debug-mode* (mud.utils:log-message "World restored from prevalence.")))
        (progn
          (setf *world* (initial-world))
          (sync-world)
          (when *debug-mode* (mud.utils:log-message "New world created and persisted.")))))
  *world*)

(defun world-new-character (character)
  "Add a character to the world."
  (let ((room (starting-room)))
    (setf (object-location character) room)
    (room-add-object room character)
    (add-character character)))
