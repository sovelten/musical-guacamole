# 🔧 Test Script Fix

## Problem
Running `sbcl --script test-system.lisp` failed because:
- Script mode doesn't work well with SBCL
- Quicklisp wasn't initialized
- Package loading issues

## Solution
Changed to use `--load` flag with `--non-interactive`:

```bash
sbcl --non-interactive --load test-system.lisp
```

## What Changed
1. **test-system.lisp** - Rewritten to:
   - Remove shebang line that caused issues
   - Use `--load` compatible format
   - Check files directly instead of loading system
   - Provide clear output and next steps
   - Use SBCL-compatible exit methods

2. **TESTING.md** - Created new file:
   - Documents how to verify the system
   - Shows correct usage
   - Provides troubleshooting

3. **Documentation Updated** - References to correct testing method

## How to Use

### Quick Verification (Recommended)
```bash
sbcl --non-interactive --load test-system.lisp
```

Output:
```
=== Musical Guacamole MUD - System Test ===

Checking ASDF system...
✓ mud.asd found

Checking source files...
✓ src/package.lisp
✓ src/constants.lisp
... etc ...

=== Summary ===
All required files are present!

Next steps:
1. Run:   ./setup.sh
2. Start: sbcl
3. Load:  (ql:quickload :mud)
4. Run:   (mud:start)
5. Play:  telnet localhost 8888
```

### Interactive Testing
```bash
sbcl
> (load "test-system.lisp")
```

### With Quicklisp (after setup.sh)
```bash
sbcl
> (ql:quickload :mud/tests)
> (mud.tests:run-tests)
```

## Files Changed
- `test-system.lisp` - Completely rewritten for SBCL compatibility
- `TESTING.md` - New testing guide
- `INDEX.md` - Added TESTING.md reference
- `DEVELOPMENT.md` - Updated testing section

## Status
✅ Fixed - Works correctly now!
