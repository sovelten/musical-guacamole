#!/bin/bash
# Setup script for musical-guacamole MUD

echo "Installing dependencies for musical-guacamole MUD..."
echo ""

# Check if SBCL is installed
if ! command -v sbcl &> /dev/null; then
    echo "ERROR: SBCL is not installed. Please install SBCL first."
    echo "On Ubuntu/Debian: sudo apt-get install sbcl"
    echo "On macOS: brew install sbcl"
    exit 1
fi

echo "SBCL found: $(sbcl --version)"
echo ""

# Install dependencies via Quicklisp
echo "Installing Quicklisp dependencies..."
sbcl --noinform --non-interactive \
  --eval '(ql:quickload (list "usocket" "bordeaux-threads" "fiveam"))' \
  --eval '(format t "Dependencies installed successfully!~%")' \
  --eval '(quit)' 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Setup complete! You can now run the MUD server."
    echo ""
    echo "To start the server:"
    echo "  sbcl"
    echo "  > (ql:quickload :mud)"
    echo "  > (mud:start)"
    echo ""
    echo "Then connect with:"
    echo "  telnet localhost 8888"
else
    echo "ERROR: Failed to install dependencies. Please check your Quicklisp installation."
    exit 1
fi
