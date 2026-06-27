;;;; src/core/combat.lisp — Player combat system

(in-package #:apeiron.core)

(defconstant +player-default-hp+ 30)
(defconstant +player-default-attack-min+ 4)
(defconstant +player-default-attack-max+ 9)

(defun player-hp (player)
  (or (object-get-property player "hp") +player-default-hp+))

(defun player-max-hp (player)
  (or (object-get-property player "max-hp") +player-default-hp+))

(defun (setf player-hp) (value player)
  (object-set-property player "hp" (max 0 value)))

(defun player-ensure-combat-stats (player)
  (unless (object-get-property player "max-hp")
    (object-set-property player "max-hp" +player-default-hp+))
  (unless (object-get-property player "hp")
    (object-set-property player "hp" (player-max-hp player))))

(defun player-roll-attack (player)
  (+ +player-default-attack-min+
     (random (1+ (- +player-default-attack-max+ +player-default-attack-min+)))))

(defun player-defeated-p (player)
  (<= (player-hp player) 0))

(defun player-heal-full (player)
  (setf (player-hp player) (player-max-hp player)))

(defun combat-attack-npc (world player npc)
  "Player attacks an NPC. Returns messages to send to the player."
  (player-ensure-combat-stats player)
  (let ((messages (list)))
    (when (npc-defeated-p npc)
      (return-from combat-attack-npc
        (list (format nil "~A is already defeated." (object-name npc)))))
    (let ((damage (player-roll-attack player)))
      (setf (npc-hp npc) (- (npc-hp npc) damage))
      (push (format nil "You strike ~A for ~D damage!" (object-name npc) damage)
            messages)
      (if (<= (npc-hp npc) 0)
          (progn
            (npc-defeat! npc)
            (push (npc-defeat-message npc) messages)
            (when (npc-victory-flag npc)
              (object-set-property player (npc-victory-flag npc) t)
              (push (format nil "You earned a victory mark: ~A." (npc-victory-flag npc))
                    messages)))
          (let ((counter (npc-roll-attack npc)))
            (setf (player-hp player) (- (player-hp player) counter))
            (push (format nil "~A hits you for ~D damage! (Your HP: ~D/~D)"
                          (object-name npc) counter
                          (player-hp player) (player-max-hp player))
                  messages)
            (when (player-defeated-p player)
              (push "You black out and wake up at the cavern entrance, bruised but alive."
                    messages)
              (player-heal-full player)
              (let ((entrance (find-if (lambda (r)
                                         (search "Cavern Mouth" (object-name r)))
                                       (world-rooms world))))
                (when entrance
                  (object-move player entrance)))))))
    (nreverse messages)))

(defun room-exit-blocked-p (room player direction)
  "Return a blocking message if the player cannot use this exit yet."
  (let* ((dir (string-downcase direction))
         (required-flag (object-get-property room (format nil "gate-~A" dir))))
    (when (and required-flag (not (object-get-property player required-flag)))
      (or (object-get-property room (format nil "gate-~A-message" dir))
          (format nil "Something blocks the ~A exit. You are not ready to pass."
                  direction)))))

(defun room-challenge-blocked-p (room player direction)
  "Return a blocking message if a riddle/password gate blocks this exit."
  (let* ((dir (string-downcase direction))
         (challenge-exit (object-get-property room "challenge-exit"))
         (challenge-flag (object-get-property room "challenge-flag")))
    (when (and challenge-exit challenge-flag
               (string= dir (string-downcase challenge-exit))
               (not (object-get-property player challenge-flag)))
      (or (object-get-property room "challenge-question")
          "A challenge blocks your way. Try: answer <your answer>"))))
