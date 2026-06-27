(in-package #:mud-test)

(in-suite mud-tests)

(test shopping-mall-from-desert
  "Desert has a door exit to the shopping mall."
  (let* ((world (mud:world-restore-or-initialize :force-new t))
         (desert (find-if (lambda (r) (search "Desert" (mud:object-name r)))
                          (mud:rooms))))
    (is (not (null desert)))
    (is (not (null (mud:room-get-exit desert "door"))))
    (is (search "DESERT OASIS MALL" (mud:object-description desert)))))

(test team-rocket-cavern-maze
  "Arcade connects to Team Rocket cavern with NPCs and challenges."
  (let* ((world (mud:world-restore-or-initialize :force-new t))
         (rooms (mud:rooms))
         (arcade (find-if (lambda (r) (string= "Arcade Zone" (mud:object-name r))) rooms))
         (entrance (find-if (lambda (r) (search "Cavern Mouth" (mud:object-name r))) rooms))
         (grunt-room (find-if (lambda (r) (string= "Grunt Patrol Route" (mud:object-name r))) rooms))
         (npcs (remove-if-not (lambda (obj) (typep obj 'mud:mud-npc)) (mud:world-all-objects world))))
    (is (not (null arcade)))
    (is (not (null entrance)))
    (is (eq entrance (mud:room-get-exit arcade "maintenance")))
    (is (>= (length rooms) 15))
    (is (>= (length npcs) 3))
    (is (not (null grunt-room)))
    (let ((grunt (find-if (lambda (obj)
                            (and (typep obj 'mud:mud-npc)
                                 (search "grunt" (string-downcase (mud:object-name obj)))))
                          (mud:room-contents grunt-room))))
      (is (not (null grunt))))))

(test combat-attack-grunt
  "Player can attack and defeat a grunt."
  (let* ((world (mud:world-restore-or-initialize :force-new t))
         (player (mud:new-character "Fighter" (make-instance 'mud:mud-session :socket nil)))
         (grunt-room (find-if (lambda (r) (string= "Grunt Patrol Route" (mud:object-name r)))
                              (mud:rooms)))
         (grunt (find-if (lambda (obj) (typep obj 'mud:mud-npc))
                          (mud:room-contents grunt-room))))
    (mud:object-move player grunt-room)
    (is (not (mud:npc-defeated-p grunt)))
    (loop repeat 20
          until (mud:npc-defeated-p grunt)
          do (mud:combat-attack-npc player grunt))
    (is (mud:npc-defeated-p grunt))
    (is (mud:object-get-property player "beat-grunt-1"))))

(test challenge-answer-riddle
  "Answering a riddle unlocks the challenge flag."
  (let* ((world (mud:world-restore-or-initialize :force-new t))
         (player (mud:new-character "Solver" (make-instance 'mud:mud-session :socket nil)))
         (gallery (find-if (lambda (r) (string= "Riddle Gallery" (mud:object-name r)))
                           (mud:rooms))))
    (mud:object-move player gallery)
    (is (not (null (mud:room-challenge-blocked-p gallery player "east"))))
    (mud:object-set-property player "solved-meowth-riddle" t)
    (is (null (mud:room-challenge-blocked-p gallery player "east")))))
