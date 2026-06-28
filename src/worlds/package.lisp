;;;; src/worlds/package.lisp — Package definition for transient world builders

(defpackage #:apeiron.worlds
  (:use #:cl
        #:apeiron.core)
  (:export
   ;; World definition entry point
   #:initial-world

   ;; Builder helpers (used internally, but exported for extensibility)
   #:register-room
   #:register-npc
   #:set-challenge-gate
   #:set-flag-gate
   #:build-shopping-mall
   #:build-team-rocket-cavern))
