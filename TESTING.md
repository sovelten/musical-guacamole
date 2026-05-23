# Testing the MUD System

## Quick Verification

To verify that all project files are present and the system is ready:

```bash
sbcl --non-interactive --load test-system.lisp
```

This will:
- Check that all required source files are present
- Check that all test files are present
- Verify the project structure
- Give you next steps

**Output will be:**
```
=== Musical Guacamole MUD - System Test ===

Checking ASDF system...
✓ mud.asd found

Checking source files...
✓ src/package.lisp
✓ src/constants.lisp
... (all files)

=== Summary ===
All required files are present!

Next steps:
1. Run:   ./setup.sh
2. Start: sbcl
3. Load:  (ql:quickload :mud)
4. Run:   (mud:start)
5. Play:  telnet localhost 8888
```

## Full System Test (with Quicklisp)

If you want to actually load and test the MUD system:

```bash
sbcl
> (ql:quickload :mud)
> (ql:quickload :mud/tests)
> (mud.tests:run-tests)
```

This will run the unit test suite.

## Manual Testing

Once the server is running:

```bash
# Terminal 1:
sbcl
> (ql:quickload :mud)
> (mud:start)

# Terminal 2:
telnet localhost 8888
# Try commands: look, go north, say hello, quit
```

## Troubleshooting Tests

**Issue:** `sbcl --script test-system.lisp` doesn't work

**Solution:** Use `--load` instead:
```bash
sbcl --non-interactive --load test-system.lisp
```

Or run interactively:
```bash
sbcl
> (load "test-system.lisp")
```

## Files

- `test-system.lisp` - File verification script (this one)
- `tests/test-package.lisp` - Test framework
- `tests/test-object.lisp` - Object system tests
- `tests/test-world.lisp` - World system tests
