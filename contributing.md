# Design Guidelines

This code represents a common-lisp MUD server. If actual code contradicts this document, this document should take precedence, as it represents the designer intention rather than the actual implementation with the shortcuts we had to take along the way.

## Key Features

1. **Persistent Objects** - Game objects are persisted and changes are logged to enable recovery.
2. **All power to the user** - You can eval lisp code directly within the game (could/should be restricted to admins in the future)
3. **Hot Reloading** - No need to ever shut the server down for maintenance (WIP)

## Architecture

These are the main layers of the code base:

### Network - Includes network related logic

  * network.lisp (main entry point, server start and thread control)
  * session.lisp (single user session object, input/output and helpers)

### World - Main world model. Keeps track of world objects and configuration.

  * world.lisp

### Persistent World - Deals with persistence storage.

  * persistent-world.lisp

### Command Parser - This one is tricky, since commands receive input from user, manipulate the world and respond user. As much as possible we want to avoid exposure to the network. It should also not depend on the persistence layer.

  * command-handler.lisp 

### Utils

  * utils.lisp

### World Objects - objects inheriting from mud-object and their helpers. Characters are tricky because they are associated with a user session. In the future we want to rely on generic methods to avoid exposing the network layer.

  * remaining files (object, guestbook, character, room etc.)

## Design Best Practices

We value functional programming design, therefore:
* Avoid sharing global mutable state.
* Prefer passing down values as arguments rather than referring to a global variable

### Separation of Concerns

* Aim for code to be generic and extensible.

### Testing

* Unit testing should be about a single data structure/function/object. If you need to mock the network or another side effect, likely you are doing something wrong.
* Integration tests are about testing the whole program behavior. They should either rely on test versions of the generic methods (not implemented as of this moment) or mirror production. 
* All integration tests should have initialization and tear down of anything that requires stateful change or network interaction. In other words, tests should be isolated and not affect other tests.
* Integration tests live in test-integration.lisp and the other test files are to be seen as unit.
