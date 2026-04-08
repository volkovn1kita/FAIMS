#!/bin/bash
# Automatically detects the host machine's local IP address
# and runs the Flutter app with the correct API_HOST.
#
# Usage:
#   ./scripts/run_flutter.sh [additional flutter run arguments]
#
# Examples:
#   ./scripts/run_flutter.sh                      # Run on default device
#   ./scripts/run_flutter.sh -d chrome             # Run in Chrome
#   ./scripts/run_flutter.sh --release             # Run in release mode

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Detect local IP address (works on Linux/macOS)
if command -v ip &> /dev/null; then
    # Linux
    HOST_IP=$(ip route get 1 | awk '{print $7; exit}')
elif command -v ipconfig &> /dev/null; then
    # Windows (Git Bash / WSL)
    HOST_IP=$(ipconfig | grep -A 10 "Wi-Fi\|Ethernet\|Wireless" | grep "IPv4" | head -1 | awk '{print $NF}' | tr -d '\r')
elif command -v ifconfig &> /dev/null; then
    # macOS
    HOST_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
fi

# Fallback
if [ -z "$HOST_IP" ]; then
    echo "WARNING: Could not detect local IP address automatically."
    echo "Using fallback: 192.168.1.102"
    echo "You can pass it manually: API_HOST=<your-ip> $0"
    HOST_IP="192.168.1.102"
fi

# Allow override via environment variable
HOST_IP="${API_HOST:-$HOST_IP}"
API_PORT="${API_PORT:-5076}"

echo "============================================"
echo " FAIMS Flutter App Launcher"
echo "============================================"
echo " API Host: $HOST_IP"
echo " API Port: $API_PORT"
echo " API URL:  http://$HOST_IP:$API_PORT/api"
echo "============================================"

cd "$FRONTEND_DIR"

flutter run \
    --dart-define=API_HOST="$HOST_IP" \
    --dart-define=API_PORT="$API_PORT" \
    --dart-define=API_BASE_URL="http://$HOST_IP:$API_PORT/api" \
    "$@"
