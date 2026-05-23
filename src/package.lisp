(defpackage #:mud
  (:use #:cl)
  (:export
   ;; Core exports
   #:*mud-version*
   #:*debug-mode*
   
   ;; Object system
   #:mud-object
   #:create-object
   #:object-id
   #:object-name
   #:object-location
   #:object-properties
   #:object-get-property
   #:object-set-property
   #:object-move
   #:object-describe
   
   ;; World system
   #:mud-room
   #:create-room
   #:room-contents
   #:room-add-object
   #:room-remove-object
   #:room-exits
   #:room-add-exit
   #:room-get-exit
   
   ;; Player system
   #:mud-player
   #:create-player
   #:player-socket
   #:player-location
   #:player-inventory
   #:player-inventory-add
   #:player-inventory-remove
   #:player-send-message
   
   ;; Command system
   #:process-command
   
   ;; Network/Server
   #:start-mud-server
   #:stop-mud-server
   #:get-server-status))

(defpackage #:mud.utils
  (:use #:cl)
  (:export
   #:make-id
   #:format-message
   #:log-message
   #:log-error))

(defpackage #:mud.tests
  (:use #:cl #:fiveam)
  (:export #:run-tests))
