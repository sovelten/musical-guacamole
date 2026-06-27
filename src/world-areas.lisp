(in-package #:mud)

(defun register-room (world room)
  (world-set-object-id! world room))

(defun register-npc (world room npc)
  (room-add-object room npc)
  (world-set-object-id! world npc))

(defun set-challenge-gate (room exit-direction question answer flag)
  (object-set-property room "challenge-exit" exit-direction)
  (object-set-property room "challenge-question" question)
  (object-set-property room "challenge-answer" answer)
  (object-set-property room "challenge-flag" flag))

(defun set-flag-gate (room exit-direction flag &optional message)
  (object-set-property room (format nil "gate-~A" (string-downcase exit-direction)) flag)
  (when message
    (object-set-property room
                         (format nil "gate-~A-message" (string-downcase exit-direction))
                         message)))

(defun build-shopping-mall (world desert)
  "Add the Desert Oasis Mall, linked from the desert via a shimmering door."
  (let* ((door-flavor " A shimmering glass door materializes from the heat haze — frosted letters read 'DESERT OASIS MALL'.")
         (mall (new-persistent-room
                :name "Desert Oasis Mall"
                :description
                "A gleaming air-conditioned shopping mall defies the desert outside. Escalators hum, pop music echoes off polished tile, and neon signs advertise everything from potions to plush monsters. Shoppers wander between kiosks while a fountain burbles in the centre."))
         (food-court (new-persistent-room
                      :name "Food Court"
                      :description
                      "Rows of fast-food counters line this open plaza. The smell of fried Magikarp sticks and berry smoothies fills the air. Picnic tables are packed with tired trainers on lunch break."))
         (arcade (new-persistent-room
                  :name "Arcade Zone"
                  :description
                  "Flashing cabinets and claw machines dominate this wing. A 'Team Rocket Cavern Adventure' ride sits behind a velvet rope — a maintenance hatch beside it is slightly ajar, leaking cold underground air."))
         (fashion (new-persistent-room
                   :name "Fashion Wing"
                   :description
                   "Mannequins display the latest trainer gear: cargo shorts, fingerless gloves, and hats that somehow never fall off during battle. A sale banner screams '50% OFF REPEL!'.")))
    (setf (object-description desert)
          (concatenate 'string (object-description desert) door-flavor))
    (room-add-exits desert "door" mall "desert")
    (room-add-exits mall "north" food-court "south")
    (room-add-exits mall "east" arcade "west")
    (room-add-exits mall "west" fashion "east")
    (room-add-exits arcade "maintenance" (build-team-rocket-cavern world) "mall")
    (dolist (room (list mall food-court arcade fashion))
      (register-room world room))
    mall))

(defun build-team-rocket-cavern (world)
  "Build the Team Rocket cavern maze with fights and challenges."
  (let* ((entrance (new-persistent-room
                    :name "Team Rocket Cavern Mouth"
                    :description
                    "You squeeze through the maintenance hatch into a rough-hewn cavern. A crimson 'R' is spray-painted on the wall. Distant voices chant 'Prepare for trouble!' echo off the stone."))
         (crossroads (new-persistent-room
                      :name "Cavern Crossroads"
                      :description
                      "Three tunnels branch off here. Faint footprints and discarded candy wrappers mark the paths. A scratched sign reads: 'Trespassers will be recruited!'."))
         (grunt-patrol (new-persistent-room
                        :name "Grunt Patrol Route"
                        :description
                        "A narrow patrol corridor lit by flickering torches. Pallets of stolen goods are stacked against the walls."))
         (riddle-gallery (new-persistent-room
                          :name "Riddle Gallery"
                          :description
                          "Portraits of villainous-looking cats and snakes line the walls. A plaque reads: 'Speak the name of the coin-loving feline to proceed east.'"))
         (cat-alley (new-persistent-room
                     :name "Cat Alley"
                     :description
                     "A dead-end alcove with a bronze Meowth statue. It glares at you with gem eyes. 'I'm not saying anything,' it seems to say."))
         (mirror-maze (new-persistent-room
                       :name "Mirror Maze"
                       :description
                       "Reflective panels create endless copies of you. Every turn looks the same. Only one path leads onward."))
         (elite-patrol (new-persistent-room
                        :name "Elite Patrol Post"
                        :description
                        "This checkpoint is heavily guarded. A chalkboard lists 'Today's Evil Plan: Steal ALL the rare candies.'"))
         (password-gate (new-persistent-room
                         :name "Password Gate"
                         :description
                         "A steel door blocks the north tunnel. A keypad blinks beside a note: 'Enter the organization password to proceed.'"))
         (hidden-lab (new-persistent-room
                      :name "Hidden Lab"
                      :description
                      "Abandoned lab equipment and broken Poké Ball molds litter this side chamber. Someone left a half-eaten donut on a centrifuge."))
         (boss-chamber (new-persistent-room
                        :name "Boss G's Chamber"
                        :description
                        "A vast cavern with a raised platform. Boss G stands with arms crossed, a Persian at his feet. 'So you've made it this far, brat,' he sneers."))
         (treasure (new-persistent-room
                    :name "Rocket Treasure Vault"
                    :description
                    "Gold coins, rare candies, and a golden 'R' badge glint in the torchlight. A banner reads: 'Congratulations — you ruined our entire operation!'."))
         (grunt (new-persistent-npc
                 :name "a Team Rocket grunt"
                 :description "A uniformed goon in a white W and black R cap."
                 :hp 15 :max-hp 15
                 :attack-min 3 :attack-max 6
                 :defeat-message "The grunt drops a handful of coins and flees, yelling 'We're blasting off again!'"
                 :victory-flag "beat-grunt-1"))
         (elite (new-persistent-npc
                 :name "an elite Rocket agent"
                 :description "A smug agent with mirrored shades and a stolen Master Ball on his belt."
                 :hp 25 :max-hp 25
                 :attack-min 5 :attack-max 9
                 :defeat-message "The elite agent stumbles backward. 'Impossible! Boss G will hear about this!'"
                 :victory-flag "beat-elite"))
         (boss (new-persistent-npc
                :name "Boss G"
                :description "The infamous leader of this shady outfit, stroking his Persian."
                :hp 45 :max-hp 45
                :attack-min 7 :attack-max 12
                :defeat-message "Boss G crumples. 'This isn't over... I'll be back... with a better evil plan!' The cavern rumbles as secret exits open."
                :victory-flag "beat-boss-g")))
    ;; Maze layout
    (room-add-exits entrance "north" crossroads "south")
    (room-add-exits crossroads "north" grunt-patrol "south")
    (room-add-exits crossroads "east" riddle-gallery "west")
    (room-add-exits crossroads "west" mirror-maze "east")
    (room-add-exits crossroads "south" cat-alley "north")
    (room-add-exits grunt-patrol "north" elite-patrol "south")
    (room-add-exits riddle-gallery "east" password-gate "west")
    (room-add-exits mirror-maze "south" crossroads "north")
    (room-add-exits mirror-maze "west" hidden-lab "east")
    (room-add-exits elite-patrol "north" password-gate "south")
    (room-add-exits password-gate "north" boss-chamber "south")
    (room-add-exits boss-chamber "north" treasure "south")

    ;; Challenges
    (set-challenge-gate riddle-gallery "east"
                        "A voice echoes: 'What feline crook loves coins above all else?' Try: answer <name>"
                        "meowth"
                        "solved-meowth-riddle")
    (set-challenge-gate password-gate "north"
                        "The keypad demands: 'Enter the organization password.' Try: answer <password>"
                        "rocket"
                        "solved-rocket-password")

    ;; Fight gates
    (set-flag-gate grunt-patrol "north" "beat-grunt-1"
                   "The grunt blocks the north tunnel. Defeat them first! Try: attack grunt")
    (set-flag-gate elite-patrol "north" "beat-elite"
                   "The elite agent stands firm. Try: attack agent")
    (set-flag-gate boss-chamber "north" "beat-boss-g"
                   "Boss G laughs. 'Defeat me first, child!' Try: attack boss")

    ;; NPC placement
    (register-npc world grunt-patrol grunt)
    (register-npc world elite-patrol elite)
    (register-npc world boss-chamber boss)

    (register-room world entrance)
    (register-room world crossroads)
    (register-room world grunt-patrol)
    (register-room world riddle-gallery)
    (register-room world cat-alley)
    (register-room world mirror-maze)
    (register-room world elite-patrol)
    (register-room world password-gate)
    (register-room world hidden-lab)
    (register-room world boss-chamber)
    (register-room world treasure)
    entrance))
