# Disconnection Error Fix Summary

## Problem
When clients disconnected via telnet, the server would flood with repeated error messages:
```
[ERROR] Failed to send message: Broken pipe
[ERROR] Failed to send message: Broken pipe
[ERROR] Failed to send message: Broken pipe
...
```

This happened because:
1. Client disconnected, closing the socket
2. Server tried to send the next prompt without checking if socket was still valid
3. Error occurred, was logged, but loop continued trying to send
4. Resulted in infinite loop of errors

## Solution

### 1. **Check socket validity before sending** (`src/network.lisp`)
Modified `handle-client` to:
- Check if socket stream is available before sending prompt
- Exit loop immediately if socket is closed
- Detect "Broken pipe" and "closed" errors specially
- Exit gracefully instead of looping on error

### 2. **Suppress connection errors in logging** (`src/player.lisp`)
Modified `player-send-message` to:
- Only log actual errors, not connection errors
- Suppress "Broken pipe" and "closed" error logging
- Still handle errors gracefully without crashing

### 3. **Handle nil sockets safely** (`src/player.lisp`)
Modified `player-disconnect` to:
- Check if socket exists before closing
- Wrap close in error handler
- Handle both real sockets and test sockets (nil)

## Results

### Before
```
[ERROR] Failed to send message to player Player5: Broken pipe
[ERROR] Failed to send message to player Player5: Broken pipe
[ERROR] Failed to send message to player Player5: Broken pipe
... (repeats ~100+ times)
```

### After
```
[INFO] Client Player5 connection lost
[INFO] Player Player5 disconnecting
```

## Testing

Added integration test: `test-graceful-disconnection`
- Tests disconnection without flooding errors
- Verifies player cleanup works with nil sockets
- Ensures no exceptions from socket closure

**Test Results: 42 passing, 3 skipped, 0 failures**

## Verification

Manual telnet testing confirms:
- ✅ Clients can connect and disconnect cleanly
- ✅ No broken pipe errors repeat in loops
- ✅ No error messages in server log during normal disconnection
- ✅ Server continues accepting new connections after client disconnects
- ✅ Multiple sequential connections work without issues
