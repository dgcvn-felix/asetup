#!/bin/bash
# AnetHRM Community - Quick Install
# Usage: curl -fsSL https://raw.githubusercontent.com/dgcvn-felix/asetup/main/install.sh | bash

set -euo pipefail

BINARY_URL="https://raw.githubusercontent.com/dgcvn-felix/asetup/main/hrm-deploy"

echo ""
echo "  Installing AnetHRM Community..."
echo ""

# Download binary
curl -fsSL "$BINARY_URL" -o hrm-deploy || { echo "Download failed"; exit 1; }
chmod +x hrm-deploy

echo "  Done! Run: ./hrm-deploy"
echo ""

# Run it
exec ./hrm-deploy "$@"
