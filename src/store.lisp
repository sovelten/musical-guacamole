(in-package :mud)

;; BKNR

(defclass simple-object ()
  ((name :initarg :name
         :accessor object-name
         :initform "unnamed object"
         :documentation "Display name of the object")
   (description :initarg :description
                :accessor object-description
                :initform ""
                :documentation "Object description")))

(defclass wrapping-persistent-class (bknr.datastore:persistent-class)
  ((transient-slots :initarg :transient-slots
                    :initform nil
                    :accessor class-transient-slots
                    :documentation "List of slot names inherited from
                    non-persistent parents that should be treated as
                    transient (not stored in the datastore)."))
  (:default-initargs)
  (:documentation
   "A persistent-class that can safely inherit slots from a non-persistent
    standard-class parent."))

(defmethod sb-mop:validate-superclass
    ((sub   wrapping-persistent-class)
     (super sb-mop:standard-class))
  t)

(defmethod sb-mop:compute-effective-slot-definition :around
    ((class wrapping-persistent-class) name direct-slots)
  ;; Convert any inherited standard-direct-slot-definition instances into
  ;; persistent-direct-slot-definition instances so that bknr's own :around
  ;; method (on persistent-class) can safely read the :transient slot.
  ;; Slots listed in (class-transient-slots class) are marked as transient;
  ;; all others are persistent.
  (let* ((transient-slot-names (class-transient-slots class))
         (fixed-slots
          (mapcar (lambda (slotd)
                    (if (typep slotd 'sb-mop:standard-direct-slot-definition)
                        (let ((slot-name (sb-mop:slot-definition-name slotd)))
                          (make-instance 'bknr.datastore::persistent-direct-slot-definition
                            :name slot-name
                            :initform (sb-mop:slot-definition-initform slotd)
                            :initfunction (sb-mop:slot-definition-initfunction slotd)
                            :type (sb-mop:slot-definition-type slotd)
                            :allocation (sb-mop:slot-definition-allocation slotd)
                            :readers (sb-mop:slot-definition-readers slotd)
                            :writers (sb-mop:slot-definition-writers slotd)
                            :initargs (sb-mop:slot-definition-initargs slotd)
                            :transient (if (member slot-name transient-slot-names)
                                           t
                                           nil)))
                        slotd))
                  direct-slots)))
    (call-next-method class name fixed-slots)))

(defmethod (setf sb-mop:slot-value-using-class) :around
    (newval (class wrapping-persistent-class) object
            (slotd bknr.datastore::persistent-effective-slot-definition))
  ;; Automatically wrap persistent slot writes in a transaction so that
  ;; vanilla accessor functions like (setf (object-name obj) "x") work
  ;; without explicit transaction wrapping.
  ;; Transient slots are left alone — they can be set freely already.
  ;; The auto-wrap transaction gets a descriptive label so it shows up
  ;; informatively in the transaction log.
  (if (or (bknr.datastore:in-transaction-p)
          (bknr.datastore::transient-slot-p slotd))
      (call-next-method)
      (bknr.datastore:with-transaction
          ((format nil "auto-wrap ~A" (sb-mop:slot-definition-name slotd)))
        (call-next-method))))

(defmacro defwrapping-persistent-class (class superclasses slots &rest class-options)
  "Like BKNR.DATASTORE:DEFPERSISTENT-CLASS but uses
WRAPPING-PERSISTENT-CLASS as the metaclass, so SUPERCLASSES can include
vanilla STANDARD-CLASS parents whose slots lack :TRANSIENT annotations.
STORE-OBJECT is automatically prepended to the superclass list.

Class option `:transient-slots` — list of slot names inherited from
non-persistent parents that should NOT be stored in the datastore.
All other inherited slots are persistent by default.

Example:
  (defwrapping-persistent-class my-persistent (my-class)
    ()
    (:transient-slots name cached-data))"
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (defclass ,class ,(append superclasses '(bknr.datastore:store-object))
       ,slots
       (:metaclass wrapping-persistent-class)
       ,@class-options)))

(defwrapping-persistent-class simple-object-store (simple-object)
  ()
  (:transient-slots description))

(defvar *store* (make-instance 'bknr.datastore:mp-store :directory #p"./bknr/"
                               :subsystems (list (make-instance 'bknr.datastore:store-object-subsystem))))
