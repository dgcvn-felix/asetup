#!/bin/bash
# AnetHRM Community - Quick Install
# Usage: curl -fsSL https://raw.githubusercontent.com/dgcvn-felix/asetup/main/install.sh | bash

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/dgcvn-felix/asetup/main"

echo ""
echo "  Installing AnetHRM Community..."

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)  BINARY="hrm-deploy-amd64" ;;
    aarch64|arm64) BINARY="hrm-deploy-arm64" ;;
    *) echo "  Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo "  Detected: $ARCH -> $BINARY"

# Download binary
curl -fsSL "$BASE_URL/$BINARY" -o hrm-deploy || { echo "  Download failed"; exit 1; }
chmod +x hrm-deploy

echo "  Done!"
echo ""

# Run it
exec ./hrm-deploy "$@"
