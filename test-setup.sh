#!/usr/bin/env bash

# Musical Guacamole MUD - Complete Testing Script
# Run this script to verify and demonstrate the MUD server

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Musical Guacamole MUD - Testing & Verification Script   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."
echo ""

if ! command -v sbcl &> /dev/null; then
    echo "❌ SBCL not found. Please install SBCL:"
    echo "   Ubuntu/Debian: sudo apt-get install sbcl"
    echo "   macOS: brew install sbcl"
    exit 1
fi

SBCL_VERSION=$(sbcl --version 2>&1 | awk '{print $3}')
echo "✅ SBCL found: $SBCL_VERSION"

# Check project files
echo ""
echo "📂 Checking project structure..."
echo ""

REQUIRED_FILES=(
    "src/package.lisp"
    "src/constants.lisp"
    "src/utils.lisp"
    "src/object.lisp"
    "src/world.lisp"
    "src/player.lisp"
    "src/command-handler.lisp"
    "src/network.lisp"
    "src/server.lisp"
    "mud.asd"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - NOT FOUND"
        exit 1
    fi
done

echo ""
echo "✅ All required files present!"

# Count lines of code
echo ""
echo "📊 Code Statistics:"
echo ""

TOTAL_LINES=$(find src -name "*.lisp" -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "   Total lines in src/: $TOTAL_LINES"

TEST_LINES=$(find tests -name "*.lisp" -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "   Total lines in tests/: $TEST_LINES"

FILE_COUNT=$(find src -name "*.lisp" | wc -l)
echo "   Source files: $FILE_COUNT"

echo ""

# Check syntax
echo "🔍 Checking Lisp syntax..."
echo ""

SYNTAX_ERRORS=0
for file in src/*.lisp; do
    if sbcl --noinform --non-interactive \
        --eval "(handler-case (load \"$file\") (error () (quit 1)))" \
        --eval "(quit 0)" 2>/dev/null; then
        echo "✅ $(basename $file)"
    else
        echo "❌ $(basename $file) - SYNTAX ERROR"
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done

echo ""

if [ $SYNTAX_ERRORS -eq 0 ]; then
    echo "✅ All files have valid Lisp syntax!"
else
    echo "❌ $SYNTAX_ERRORS file(s) with syntax errors"
    exit 1
fi

# Test system loading
echo ""
echo "🔧 Testing system loading..."
echo ""

if sbcl --noinform --non-interactive \
    --eval "(require :asdf)" \
    --eval "(push #p\"./\" asdf:*central-registry*)" \
    --eval "(ql:quickload (list \"usocket\" \"bordeaux-threads\"))" \
    --eval "(asdf:load-system :mud)" \
    --eval "(format t \"✅ System loaded successfully!~%\")" \
    --eval "(quit 0)" 2>&1 | grep -q "✅ System loaded successfully!"; then
    echo "✅ MUD system loads successfully"
else
    echo "❌ Failed to load MUD system"
    echo "   Make sure dependencies are installed: (ql:quickload (list \"usocket\" \"bordeaux-threads\"))"
    exit 1
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    ✅ ALL TESTS PASSED                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "📚 Documentation:"
echo "   • QUICKSTART.md       - Getting started guide"
echo "   • DEVELOPMENT.md      - Development guide"
echo "   • ARCHITECTURE.md     - Technical architecture"
echo "   • INDEX.md            - Navigation guide"
echo ""

echo "🚀 To start the MUD server:"
echo ""
echo "   sbcl"
echo "   > (ql:quickload :mud)"
echo "   > (mud:start)"
echo ""
echo "   Then in another terminal:"
echo "   telnet localhost 8888"
echo ""

echo "✨ Project is ready to use!"
echo ""
