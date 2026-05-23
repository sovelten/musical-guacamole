# Musical Guacamole - Getting Started Index

Welcome to the Musical Guacamole MUD project! This document will guide you through all available resources.

## 📚 Documentation

## 📚 Where to Start

### For Users (Getting Started)
1. **[QUICKSTART.md](QUICKSTART.md)** ⭐ **START HERE**
   - Installation instructions
   - Running the server
   - Connecting players
   - Available commands
   - Troubleshooting

2. **[README.md](README.md)**
   - Project overview
   - Vision and features
   - Architecture overview
   - Contributing guidelines

### For Developers
3. **[DEVELOPMENT.md](DEVELOPMENT.md)**
   - How to add new commands
   - Creating new object types
   - Building world content
   - Adding timed events
   - Testing your changes
   - Performance considerations

4. **[ARCHITECTURE.md](ARCHITECTURE.md)**
   - System architecture diagrams
   - Data flow diagrams
   - Object model explanation
   - Threading model
   - Module dependencies

5. **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)**
   - What has been built
   - Feature checklist
   - Design decisions
   - Future development roadmap

### For Testing & Verification
6. **[TESTING.md](TESTING.md)**
   - How to verify the system
   - Running tests
   - Troubleshooting
   - Manual testing

## 🏗️ Project Structure

### Source Code (`src/`)

| File | Purpose | Lines |
|------|---------|-------|
| `package.lisp` | Package definitions and exports | ~50 |
| `constants.lisp` | Configuration constants | ~20 |
| `utils.lisp` | Utilities (ID generation, logging) | ~30 |
| `object.lisp` | Core object system and rooms | ~150 |
| `world.lisp` | World management | ~80 |
| `player.lisp` | Player characters | ~80 |
| `command-handler.lisp` | Command system | ~150 |
| `network.lisp` | Network I/O and threading | ~120 |
| `server.lisp` | Server entry points | ~15 |

### Tests (`tests/`)
- `test-package.lisp` - Test framework setup
- `test-object.lisp` - Object system tests
- `test-world.lisp` - World system tests

### Configuration
- `mud.asd` - ASDF system definition
- `setup.sh` - Dependency installation script
- `test-system.lisp` - System verification test harness

## 🚀 Quick Start (TL;DR)

### Installation
```bash
chmod +x setup.sh
./setup.sh
```

### Start the Server
```lisp
(ql:quickload :mud)
(mud:start)
```

### Connect a Player
```bash
telnet localhost 8888
```

### Stop the Server
```lisp
(mud:stop)
```

## 🎮 Available Commands

| Command | Usage | Example |
|---------|-------|---------|
| look | `look` | Examine current room |
| go | `go <dir>` | `go north` |
| exits | `exits` | See available exits |
| inventory | `inventory` | View items |
| say | `say <msg>` | `say Hello!` |
| help | `help` | List commands |
| quit | `quit` | Disconnect |

## 🔧 Common Development Tasks

### Add a New Command
See [DEVELOPMENT.md - Adding New Commands](DEVELOPMENT.md#adding-new-commands)

Example: Adding "drop" command
```lisp
(define-command "drop" (player args)
  ;; implementation here
  )
```

### Create New Object Type
See [DEVELOPMENT.md - Adding New Object Types](DEVELOPMENT.md#adding-new-object-types)

### Add World Content
See [DEVELOPMENT.md - Adding World Building Functions](DEVELOPMENT.md#adding-world-building-functions)

### Run Tests
```lisp
(ql:quickload :mud/tests)
(mud.tests:run-tests)
```

## 📊 Architecture Overview

```
Network ──► Players ──► Commands ──► Objects ──► World
  (telnet)  (threads)  (handlers)   (system)   (rooms/state)
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed diagrams.

## 🎯 Development Roadmap

### Completed ✅
- Multi-threaded player connections
- Room system with exits
- Object/property system
- Command handler
- Inter-player communication

### Next Steps 🔄
1. Inventory commands (take, drop)
2. Object examination
3. Basic NPC system
4. World persistence

### Future Features 🌟
- In-world Lisp REPL
- Hot code reloading
- DGD-style privilege system
- Advanced NPC AI

## 💡 Key Concepts

### Objects
Everything in the MUD is an object with:
- Unique ID
- Name
- Type
- Location
- Extensible properties

### Rooms
Special objects that:
- Contain other objects
- Have directional exits
- Track contents

### Commands
Extensible system using `define-command` macro:
- Simple to add
- Access to player and room state
- Can modify world

### Threading
- Main thread: Server
- Accept thread: Connection handling
- Per-player threads: Individual player logic
- Thread-safe state with locks

## 🛠️ Prerequisites

- **SBCL** (Common Lisp compiler)
- **Quicklisp** (package manager)
- **usocket** (networking)
- **bordeaux-threads** (multi-threading)

## 📖 Learning Resources

- [Practical Common Lisp](http://www.gigamonkeys.com/book/) - Free online book
- [Common Lisp HyperSpec](http://www.lispworks.com/documentation/HyperSpec/)
- [DGD MUD Driver](https://www.dworkin.nl/dgd/) - Our inspiration
- [LMUD](https://lmud.common-lisp.dev/) - Another Lisp MUD

## ❓ Troubleshooting

### "Cannot find system :mud"
Make sure you're in the `musical-guacamole` directory.

### "Cannot find component usocket"
Run: `(ql:quickload (list "usocket" "bordeaux-threads"))`

### "Address already in use"
Change the port in `src/constants.lisp` or wait for the port to be released.

### Cannot connect with telnet
Verify the server is running (check SBCL output).

## 📝 File Locations

```
musical-guacamole/
├── QUICKSTART.md          ← Start here for usage
├── README.md              ← Project overview
├── DEVELOPMENT.md         ← Development guide
├── ARCHITECTURE.md        ← Technical details
├── PROJECT_SUMMARY.md     ← What was built
├── INDEX.md               ← This file
├── src/                   ← Source code
├── tests/                 ← Test suite
├── mud.asd               ← System definition
├── setup.sh              ← Install dependencies
└── test-system.lisp      ← System verification
```

## 🚦 Status

**Project Status**: ✅ **WORKING**

The MUD server is fully functional and ready for:
- ✅ Multiple player connections
- ✅ Room navigation
- ✅ Inter-player communication
- ✅ Command execution
- ✅ Extensibility with new commands/content

## 🎓 Next Steps

1. **New User?** → Read [QUICKSTART.md](QUICKSTART.md)
2. **Want to develop?** → Read [DEVELOPMENT.md](DEVELOPMENT.md)
3. **Need technical details?** → Read [ARCHITECTURE.md](ARCHITECTURE.md)
4. **Curious about implementation?** → Check [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

---

**Questions?** Check the relevant documentation file or examine the source code directly - it's well-commented and organized.

**Ready to start?** Run `./setup.sh` and then follow [QUICKSTART.md](QUICKSTART.md)!
