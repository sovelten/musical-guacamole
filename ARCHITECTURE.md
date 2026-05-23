# MUD Architecture Overview

## System Architecture Diagram

```
                          ┌─────────────────────────────┐
                          │   Network I/O (network.lisp) │
                          │  TCP Server on :8888        │
                          └──────────────┬──────────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
            ┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
            │  Player Thread  │  │  Player Thread │  │  Player Thread │
            │   (Client 1)    │  │   (Client 2)   │  │   (Client N)   │
            └───────┬────────┘  └────────┬────────┘  └────────┬────────┘
                    │                    │                    │
                    └────────────────────┼────────────────────┘
                                         │
                          ┌──────────────▼──────────────┐
                          │  Command Handler            │
                          │  (command-handler.lisp)     │
                          └──────────────┬──────────────┘
                                         │
            ┌────────────────────────────┼────────────────────────────┐
            │                            │                            │
    ┌───────▼──────────┐      ┌──────────▼─────────┐     ┌───────────▼──┐
    │   Player System  │      │  Command System    │     │  World State │
    │ (player.lisp)    │      │ • look             │     │(world.lisp)  │
    │ • Inventory      │      │ • go               │     │ • Rooms      │
    │ • Location       │      │ • say              │     │ • Players    │
    │ • Messages       │      │ • inventory        │     │ • Registry   │
    │ • Properties     │      │ • exits            │     │ • Broadcast  │
    └────────┬─────────┘      │ • help             │     └───────┬──────┘
             │                │ • quit             │             │
             │                └────────┬───────────┘             │
             │                         │                         │
             └─────────────────────────┼─────────────────────────┘
                                       │
                          ┌────────────▼──────────────┐
                          │   Object System           │
                          │  (object.lisp)            │
                          │                           │
                          │  mud-object               │
                          │  ├─ ID (unique)           │
                          │  ├─ Name                  │
                          │  ├─ Type                  │
                          │  ├─ Location              │
                          │  └─ Properties (hash)     │
                          │                           │
                          │  mud-room (extends obj)   │
                          │  ├─ Contents             │
                          │  └─ Exits                │
                          │                           │
                          │  mud-player (extends obj) │
                          │  ├─ Socket               │
                          │  └─ Inventory            │
                          └───────────────────────────┘
                                       │
                          ┌────────────▼──────────────┐
                          │   Utilities               │
                          │  (utils.lisp)             │
                          │                           │
                          │  • ID generation (locked) │
                          │  • Logging               │
                          │  • Message formatting    │
                          └───────────────────────────┘
```

## Data Flow: Player Command Processing

```
    ┌─────────────────────────────────────────┐
    │ Network I/O                             │
    │ Receive: "go north" from telnet client  │
    └────────────────┬────────────────────────┘
                     │
    ┌────────────────▼────────────────────────┐
    │ parse-command                           │
    │ "go north" → ("go" ("north"))           │
    └────────────────┬────────────────────────┘
                     │
    ┌────────────────▼────────────────────────┐
    │ process-command                         │
    │ Lookup "go" in command handler table    │
    └────────────────┬────────────────────────┘
                     │
    ┌────────────────▼────────────────────────┐
    │ Execute "go" command handler            │
    │ • Get current room                      │
    │ • Look up "north" exit                  │
    │ • Move player to target room            │
    │ • Send messages to affected players     │
    └────────────────┬────────────────────────┘
                     │
    ┌────────────────▼────────────────────────┐
    │ Network I/O                             │
    │ Send room description & prompt to player│
    └─────────────────────────────────────────┘
```

## Object Model

```
                    ┌──────────────────┐
                    │   mud-object     │
                    │  (base class)    │
                    ├──────────────────┤
                    │ - id: integer    │
                    │ - name: string   │
                    │ - type: symbol   │
                    │ - location: ref  │
                    │ - properties: ht │
                    └──────┬───────────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
      ┌─────▼────────┐            ┌──────▼──────────┐
      │  mud-room    │            │  mud-player     │
      │(location)    │            │(character)      │
      ├──────────────┤            ├─────────────────┤
      │ - contents[] │            │ - socket        │
      │ - exits{}    │            │ - inventory[]   │
      │              │            │ - input-buffer  │
      └──────────────┘            └─────────────────┘

Additional planned types:
      ┌──────────────┐            ┌──────────────┐
      │  mud-item    │            │   mud-npc    │
      │(inventory)   │            │(character)   │
      ├──────────────┤            ├──────────────┤
      │ - weight     │            │ - behaviors[]│
      │ - value      │            │ - dialogue[] │
      └──────────────┘            └──────────────┘
```

## Threading & Concurrency Model

```
    ┌─────────────────────────────────────┐
    │  Main Thread: Server Startup        │
    │  • Create server socket             │
    │  • Initialize world                 │
    │  → Spawn accept-connections thread  │
    └──────────────┬──────────────────────┘
                   │
    ┌──────────────▼──────────────────────┐
    │ Accept Connections Thread           │
    │ • Listen for incoming telnet        │
    │ • Create player on connection       │
    │ → Spawn per-player thread           │
    │ (repeats)                           │
    └──────────────┬──────────────────────┘
                   │
    ┌──────────────┴──────────────────────────┐
    │                                          │
    ┌─────────────▼──────────┐  ┌──────────────▼──────┐
    │ Player Thread 1         │  │ Player Thread 2      │
    │ • Send/recv from socket │  │ • Send/recv from     │
    │ • Process commands      │  │   socket             │
    │ • Update player state   │  │ • Process commands   │
    │ • Loop until disconnect │  │ • Update player      │
    └─────────────┬──────────┘  │   state              │
                  │             │ • Loop until disc.   │
                  │             └──────┬───────────────┘
                  │                    │
                  └────────┬───────────┘
                           │
                  ┌────────▼──────────┐
                  │ Shared State      │
                  │ (Protected by     │
                  │  locks)           │
                  │ • World rooms     │
                  │ • Player list     │
                  │ • ID counter      │
                  └───────────────────┘
```

## State Persistence Architecture (Planned)

```
    ┌──────────────────────────┐
    │   Runtime World State    │
    │   (in-memory objects)    │
    └────────────┬─────────────┘
                 │
                 │ Serialize
                 ▼
    ┌──────────────────────────┐
    │  Lisp S-expressions      │
    │  or Binary Format        │
    │  (room/object data)      │
    └────────────┬─────────────┘
                 │
                 │ Write
                 ▼
    ┌──────────────────────────┐
    │  Disk Storage            │
    │  world.dat or SQLite     │
    │  (persistent state)      │
    └──────────────────────────┘
```

## Module Dependencies

```
        ┌─────────────┐
        │  package    │  (definitions)
        │ (exports)   │
        └──────┬──────┘
               │
        ┌──────▼──────────┐
        │  constants      │  (configuration)
        └──────┬──────────┘
               │
        ┌──────▼────────────┐
        │  utils            │  (ID generation, logging)
        └──────┬────────────┘
               │
    ┌──────────┴────────────────────────┐
    │                                    │
  ┌─▼────────┐  ┌──────────┐  ┌────────▼──┐
  │ object   │◄─┤ world    │  │ player     │
  │(core)    │  │(registry)│  │(characters)│
  └────────┬─┘  └────┬─────┘  └────┬──────┘
           │         │             │
           └────┬────┴─────────┬───┘
                │              │
        ┌───────▼──────────────▼─────┐
        │  command-handler           │  (commands)
        │  (defines game logic)       │
        └──────────────┬──────────────┘
                       │
        ┌──────────────▼──────────────┐
        │  network                    │  (I/O & threading)
        │  (client management)        │
        └──────────────┬──────────────┘
                       │
        ┌──────────────▼──────────────┐
        │  server                     │  (entry point)
        │  (start/stop)               │
        └─────────────────────────────┘
```

## Command Processing Flow

```
    Input: "say Hello!"
           │
           ▼
    parse-command
    • Split by spaces
    • Downcase command
    Result: ("say" ("Hello!"))
           │
           ▼
    process-command
    • Check length
    • Lookup in *commands* hash
    • Found: "say" handler
           │
           ▼
    (define-command "say" handler)
    • Format message
    • Send to player: "You say: Hello!"
    • Iterate room contents
    • Send to other players: "<Player> says: Hello!"
           │
           ▼
    player-send-message
    • Use usocket to send
    • Add newline
    • Handle errors
           │
           ▼
    player-send-prompt
    • Send "> " to next prompt
```

This architecture provides a solid, extensible foundation inspired by DGD and LMUD, with room for adding more advanced features like persistence, in-world coding, and complex game systems.
