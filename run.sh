#!/bin/bash
# Build and run GoodTimer
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
swift build -c release 2>&1
BINARY="$(swift build -c release --show-bin-path 2>/dev/null)/GoodTimer"
echo "Launching GoodTimer..."
exec "$BINARY"
