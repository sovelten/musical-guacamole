# macOS Backspace Fix

## Problem

macOS `telnet` (BSD) sends DEL (0x7F) as raw data inside the line it delivers
to the server. Linux telnet handles BS/DEL locally before sending the final
line. The server's `telnet-read-line` accumulates every byte verbatim, so on
macOS backspace characters appear as literal `^?` in the received line.

## Root Cause

The server is in client-side line mode (no `WILL ECHO` sent). In this mode the
client is responsible for local editing. Linux telnet strips BS/DEL before
sending; macOS BSD telnet passes them through as data bytes.

## Fix (minimal — keep line mode)

In `telnet-read-line` (connection.lisp), add a clause that matches BS (0x08)
and DEL (0x7F) and pops the last character from the accumulator instead of
appending the control character. No negotiation change needed.
