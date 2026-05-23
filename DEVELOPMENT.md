# Development Guide

This guide explains how to extend and develop the MUD server.

## Adding New Commands

Commands are defined using the `define-command` macro in `command-handler.lisp`.

### Example: Adding a "drop" command

```lisp
(define-command "drop" (player args)
  (if (zerop (length args))
      (player-send-message player "Drop what?")
      (let* ((item-name (format nil "~{~A~^ ~}" args))
             (inventory (player-inventory player))
             (item (loop for obj across inventory
                         when (string-equal (object-name obj) item-name)
                         return obj)))
        (if item
            (progn
              (player-inventory-remove player item)
              (object-move item (object-location player))
              (player-send-message player (format nil "You drop the ~A." item-name)))
            (player-send-message player "You don't have that.")))))
```

## Adding New Object Types

Create a new class inheriting from `mud-object`:

```lisp
(defclass mud-weapon (mud-object)
  ((damage :initarg :damage
           :accessor weapon-damage
           :initform 5)))

(defun create-weapon (&key (name "weapon") (damage 5))
  (make-instance 'mud-weapon
                 :id (mud.utils:make-id)
                 :name name
                 :type 'weapon
                 :damage damage))
```

## Adding World Building Functions

Add helper functions to `world.lisp`:

```lisp
(defun create-forest-area (area-name start-x start-y width height)
  "Create a grid of forest rooms."
  (let ((rooms (make-array (list width height))))
    (dotimes (x width)
      (dotimes (y height)
        (let ((room (create-room :name (format nil "~A (~D,~D)" area-name x y))))
          (world-add-room room)
          (setf (aref rooms x y) room))))
    rooms))
```

## Message Broadcasting

Send messages to all players:

```lisp
(world-broadcast "A great earthquake shakes the land!")
```

Send to all players except one:

```lisp
(world-broadcast "A wizard teleports away!" exclude-player)
```

## Object Properties

Objects have a flexible property storage system using hash tables. Use it to store:

```lisp
;; Set properties
(object-set-property room "description" "A beautiful garden")
(object-set-property player "level" 5)
(object-set-property player "experience" 1000)

;; Get properties
(object-get-property room "description")
(object-get-property player "level")
```

## Extending Player Information

Player class already has extensible properties. Store extra data like this:

```lisp
(defun player-get-level (player)
  (or (object-get-property player "level") 1))

(defun player-set-level (player level)
  (object-set-property player "level" level))
```

## Adding Timed Events

Use threading for timed events:

```lisp
(defun start-world-heartbeat (interval)
  "Start a periodic world update."
  (bordeaux-threads:make-thread
    (lambda ()
      (loop while mud:*server-running* do
        (sleep interval)
        ;; Update logic here
        (dolist (room (mud:world-all-rooms))
          ;; Do something with each room
          )))
    :name "world-heartbeat"))
```

## Verification

The system can be verified by running:

```bash
sbcl --non-interactive --load test-system.lisp
```

This checks that all required files are present and ready.

## Performance Considerations

1. **Object lookup** - Currently rooms are stored in a hash table keyed by ID for O(1) lookup
2. **Player iteration** - `world-all-players` creates a list on each call; cache if used frequently
3. **Property storage** - Using hash tables for properties is good for sparse data
4. **Socket I/O** - Currently blocking; consider event-driven I/O for better scalability

## Debugging

Enable debug mode:

```lisp
(setf mud:*debug-mode* t)
```

This logs informational messages. Log custom messages:

```lisp
(mud.utils:log-message "Custom message: ~A" some-value)
(mud.utils:log-error "Error message: ~A" error-value)
```

## Next Steps for Development

### Short Term
1. Implement basic inventory commands (take, drop, get, put)
2. Add examine command with room/object descriptions
3. Create simple NPC system
4. Add persistence layer (save/load world)

### Medium Term
1. In-world code execution (REPL in-game)
2. Hot code reloading
3. Object scripting system
4. More complex interactions

### Long Term
1. DGD-style driver with privilege levels
2. Full Lisp REPL accessible in-game
3. Persistent world snapshots
4. Multiplayer dungeon crawling gameplay

## Resources

- Common Lisp HyperSpec: http://www.lispworks.com/documentation/HyperSpec/
- ASDF (Another System Definition Facility): https://common-lisp.net/project/asdf/
- Bordeaux Threads: https://common-lisp.net/project/bordeaux-threads/
- usocket: https://common-lisp.net/project/usocket/
