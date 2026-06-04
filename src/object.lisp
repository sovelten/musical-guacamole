(in-package #:mud)

;; Base mud-object class
(defclass mud-object ()
  ((id :initarg :id
       :accessor object-id
       :documentation "Unique identifier for this object")
   (name :initarg :name
         :accessor object-name
         :initform "unnamed object"
         :documentation "Display name of the object")
   (type :initarg :type
         :accessor object-type
         :initform +object-type-generic+
         :documentation "Type of object (generic, room, player, item, etc.)")
   (location :initarg :location
             :accessor object-location
             :initform nil
             :documentation "Location/container of this object")
   (properties :initarg :properties
               :accessor object-properties
               :initform (make-hash-table :test #'equal)
               :documentation "Extensible property storage"))
  (:documentation "Base class for all MUD objects"))

(defun create-object (&key (name "object") (type +object-type-generic+) (location nil))
  "Create a new MUD object."
  (make-instance 'mud-object
                 :id (mud.utils:make-id)
                 :name name
                 :type type
                 :location location))

(defun object-get-property (obj property-name)
  "Get a property value from an object."
  (gethash property-name (object-properties obj)))

(defun object-set-property (obj property-name value)
  "Set a property value on an object."
  (setf (gethash property-name (object-properties obj)) value))

(defun object-move (obj new-location)
  "Move an object to a new location."
  (let ((old-location (object-location obj)))
    ;; Remove from old location if it's a room
    (when (and old-location (typep old-location 'mud-room))
      (room-remove-object old-location obj))
    ;; Set new location
    (setf (object-location obj) new-location)
    ;; Add to new location if it's a room
    (when (typep new-location 'mud-room)
      (room-add-object new-location obj))
    t))

(defun object-describe (obj)
  "Get a description of an object."
  (format nil "~A (ID: ~D)" (object-name obj) (object-id obj)))

;; Print object in REPL with useful information
(defmethod print-object ((obj mud-object) stream)
  (print-unreadable-object (obj stream :type t)
    (format stream "~A (ID: ~D)"
            (object-name obj)
            (object-id obj))))

;; Room class - a specialized mud-object
(defclass mud-room (mud-object)
  ((contents :initarg :contents
             :accessor room-contents
             :initform (make-array 0 :adjustable t :fill-pointer t)
             :documentation "Objects contained in this room")
   (exits :initarg :exits
          :accessor room-exits
          :initform (make-hash-table :test #'equal)
          :documentation "Map of exit names to target rooms"))
  (:documentation "A location/room in the MUD"))

(defun create-room (&key (name "A Room"))
  "Create a new room."
  (make-instance 'mud-room
                 :id (mud.utils:make-id)
                 :name name
                 :type +object-type-room+
                 :location nil))

(defun room-add-object (room obj)
  "Add an object to a room."
  (vector-push-extend obj (room-contents room)))

(defun room-remove-object (room obj)
  "Remove an object from a room."
  (let ((contents (room-contents room)))
    (loop for i from 0 below (fill-pointer contents)
          do (when (eq (aref contents i) obj)
               (loop for j from i below (1- (fill-pointer contents))
                     do (setf (aref contents j) (aref contents (1+ j))))
               (decf (fill-pointer contents))
               (return)))))

(defun room-add-exit (room direction target-room)
  "Add an exit from a room to another room."
  (setf (gethash (string-downcase direction) (room-exits room)) target-room))

(defun room-get-exit (room direction)
  "Get the target room for an exit."
  (gethash (string-downcase direction) (room-exits room)))

(defun room-describe (room)
  "Get a full description of a room including contents and exits."
  (format nil "~%=== ~A ===~%~%You see:~%~{  - ~A~%~}~%~%Exits: ~{~A~^, ~}~%"
          (object-name room)
          (map 'list #'object-describe (room-contents room))
          (loop for key being the hash-keys of (room-exits room)
                collect key)))
