#!/bin/bash
# AnetHRM Community - Quick Install
# Usage: curl -fsSL https://dl.yourcompany.com/install.sh | bash

set -euo pipefail

# UPDATE THIS URL
BINARY_URL="${HRM_URL:-https://YOUR_SERVER.com/hrm-deploy}"

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
