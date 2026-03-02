#!/bin/bash
# AnetHRM Community - Quick Install & Auto-Update
# Usage: curl -fsSL https://raw.githubusercontent.com/dgcvn-felix/asetup/main/install.sh | bash

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/dgcvn-felix/asetup/main"
INSTALL_DIR="${1:-$(pwd)}"
BINARY_NAME="hrm-deploy"
VERSION_FILE="$INSTALL_DIR/${BINARY_NAME}.version.local"

echo ""
echo "  AnetHRM Community Installer"
echo ""

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)  BINARY="${BINARY_NAME}-amd64" ;;
    aarch64|arm64) BINARY="${BINARY_NAME}-arm64" ;;
    *) echo "  Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo "  Arch: $ARCH -> $BINARY"

# Check remote version
REMOTE_VERSION=$(curl -fsSL "$BASE_URL/${BINARY_NAME}.version" 2>/dev/null || echo "unknown")
LOCAL_VERSION=""
if [[ -f "$VERSION_FILE" ]]; then
    LOCAL_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "")
fi

echo "  Remote version: $REMOTE_VERSION"
echo "  Local version:  ${LOCAL_VERSION:-not installed}"

# Decide whether to download
NEED_DOWNLOAD=true
if [[ -f "$INSTALL_DIR/$BINARY_NAME" ]] && [[ -n "$LOCAL_VERSION" ]]; then
    if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
        echo ""
        echo "  Already up to date (v$LOCAL_VERSION)"
        NEED_DOWNLOAD=false
    else
        echo ""
        echo "  Update available: $LOCAL_VERSION -> $REMOTE_VERSION"
    fi
fi

if $NEED_DOWNLOAD; then
    echo "  Downloading $BINARY..."
    curl -fsSL "$BASE_URL/$BINARY" -o "$INSTALL_DIR/$BINARY_NAME" || {
        echo "  Download failed"; exit 1
    }
    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    # Save version locally
    echo "$REMOTE_VERSION" > "$VERSION_FILE"

    echo "  Installed v$REMOTE_VERSION"
fi

echo ""

# Run it (pass through any extra arguments)
exec "$INSTALL_DIR/$BINARY_NAME" "$@"
