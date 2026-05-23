# musical-guacamole

A MUD server written in Common Lisp, inspired by Dworkin's Game Driver (DGD) and LMUD.

## Inspirations

- https://www.dworkin.nl/dgd/
- https://noahgibbs.github.io/self_conscious_dgd/
- https://lmud.common-lisp.dev/

## Vision & Features

### Current Features
* **Object-oriented world** - Base MUD object system with extensible properties
* **Multi-player support** - Multiple players can connect simultaneously via telnet
* **Room system** - Navigable rooms with directional exits and contents
* **Command system** - Extensible command handler with built-in commands
* **Multi-threaded architecture** - Each player runs in its own thread

### Planned Features (DGD & LMUD Inspired)
* **Persisting living image** - Similar to Smalltalk and Lisp REPL environments
* **In-world programming** - Ability to program and modify code while inside the system
* **Dynamic object loading** - Hot-reload code without server restart
* **Persistent state** - Save/load world state to disk
* **NPC support** - Non-player characters with behaviors
* **Item system** - Movable objects with properties
* **Scripting engine** - Extend MUD behavior with Lisp

## Quick Start

See [QUICKSTART.md](QUICKSTART.md) for installation and usage instructions.

## Project Structure

```
musical-guacamole/
├── src/
│   ├── package.lisp          # Package definitions
│   ├── constants.lisp        # Configuration constants
│   ├── utils.lisp            # Utility functions (IDs, logging)
│   ├── object.lisp           # Base object system & rooms
│   ├── world.lisp            # World management
│   ├── player.lisp           # Player characters
│   ├── command-handler.lisp  # Command parsing & built-in commands
│   ├── network.lisp          # Network I/O & threading
│   └── server.lisp           # Server startup/shutdown
├── tests/
│   ├── test-package.lisp     # Test framework setup
│   ├── test-object.lisp      # Object system tests
│   └── test-world.lisp       # World system tests
├── mud.asd                   # ASDF system definition
├── QUICKSTART.md             # Getting started guide
└── README.md                 # This file
```

## Architecture

### Core Concepts

**MUD Objects**: Every entity in the world (rooms, players, items) is a `mud-object` with:
- Unique ID
- Configurable name
- Extensible property storage
- Type classification

**Rooms**: Specialized objects that can contain other objects and have directional exits

**Players**: Player characters that:
- Connect via telnet
- Have inventory
- Receive/send messages
- Process commands

**Commands**: Extensible command system with easy macro-based definition

### Threading Model

- Main thread: Accepts incoming connections
- Per-player threads: Handle input/output for each player
- Thread-safe: Object ID generation and player tracking use locks

## Dependencies

- `usocket` - Network communication
- `bordeaux-threads` - Multi-threading support
- `fiveam` - Testing framework (optional)

## Building & Testing

Load the system:
```lisp
(ql:quickload :mud)
```

Run tests:
```lisp
(ql:quickload :mud/tests)
(mud.tests:run-tests)
```

## Contributing

Current focus areas:
1. **Persistence layer** - Save world state between sessions
2. **In-world code execution** - Implement Lisp evaluation in-game
3. **More built-in commands** - take, drop, examine, etc.
4. **Item system** - Full item implementation with properties
5. **NPC system** - Basic NPC support

