(in-package :mud)

(defclass name-mixin ()
    ((name :initarg :name
           :accessor name)))

(defclass number-mixin ()
    ((number :initarg :number
           :accessor get-number)))

(defclass sephiroth (name-mixin number-mixin)
  ())

(defclass path (name-mixin number-mixin)
  ((letter :initarg :letter
           :accessor path-letter)
   (key :initarg :letter
        :accessor path-key)))

(defun sephiroth-room (sephiroth)
  (new-room :name (name sephiroth)
            :description (write-to-string (get-number sephiroth))))

(defvar keter (make-instance 'sephiroth :name "Keter" :number 1))
(defvar chokmah (make-instance 'sephiroth :name "Chokmah" :number 2))
(defvar binah (make-instance 'sephiroth :name "Binah" :number 3))
(defvar chesed (make-instance 'sephiroth :name "Chesed" :number 4))
(defvar geburah (make-instance 'sephiroth :name "Geburah" :number 5))
(defvar tiphareth (make-instance 'sephiroth :name "Tiphareth" :number 6))
(defvar netzach (make-instance 'sephiroth :name "Netzach" :number 7))
(defvar hod (make-instance 'sephiroth :name "Hod" :number 8))
(defvar yesod (make-instance 'sephiroth :name "Yesod" :number 9))
(defvar malkuth (make-instance 'sephiroth :name "Malkuth" :number 10))

(defvar path1 (make-instance 'path :name "The Magician" :number 1 :letter "Beth"))
(defvar path11 (make-instance 'path :name "The Fool" :number 11 :letter "Aleph"))

(defun tree-of-life ()
  (let ((world (make-instance 'new-world))
        (keter (new-room :name "Keter" :description "1"))
        (chokmah (new-room :name "Chokmah" :description "2"))
        (binah (new-room :name "Binah" :description "3"))
        (chesed (new-room :name "Chesed" :description "4"))
        (geburah (new-room :name "Geburah" :description "5"))
        (tiphareth (new-room :name "Tiphareth" :description "6"))
        (netzach (new-room :name "Netzach" :description "7"))
        (hod (new-room :name "Hod" :description "8"))
        (yesod (new-room :name "Yesod" :description "9"))
        (malkuth (new-room :name "Malkuth" :description "10")))))
