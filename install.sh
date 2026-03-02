#!/bin/bash
# AnetHRM Community - Quick Install & Auto-Update
#
# Fresh install:  curl -fsSL .../install.sh | bash
# Update only:    curl -fsSL .../install.sh | bash -s -- --update
#
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/dgcvn-felix/asetup/main"
INSTALL_DIR="$(pwd)"
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

# Detect: fresh install or existing installation
# Check: binary exists OR .env exists OR HRM containers running
IS_FRESH=true
if [[ -f "$INSTALL_DIR/$BINARY_NAME" ]] || \
   [[ -f "$INSTALL_DIR/.env" ]] || \
   docker inspect fibe-api &>/dev/null 2>&1; then
    IS_FRESH=false
fi

echo "  Remote version: $REMOTE_VERSION"
echo "  Local version:  ${LOCAL_VERSION:-not installed}"

# Decide whether to download
NEED_DOWNLOAD=true
if ! $IS_FRESH && [[ -n "$LOCAL_VERSION" ]] && [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
    echo ""
    echo "  Already up to date (v$LOCAL_VERSION)"
    NEED_DOWNLOAD=false
fi

if $NEED_DOWNLOAD; then
    if $IS_FRESH; then
        echo "  Downloading $BINARY..."
    else
        echo "  Updating: $LOCAL_VERSION -> $REMOTE_VERSION ..."
    fi

    curl -fsSL "$BASE_URL/$BINARY" -o "$INSTALL_DIR/$BINARY_NAME" || {
        echo "  Download failed"; exit 1
    }
    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    # Save version locally
    echo "$REMOTE_VERSION" > "$VERSION_FILE"

    if $IS_FRESH; then
        echo "  Installed v$REMOTE_VERSION"
    else
        echo "  Updated to v$REMOTE_VERSION"
    fi
fi

echo ""

# Fresh install → run deploy
# Existing install → only update binary, don't re-deploy
if $IS_FRESH; then
    echo "  Starting deployment..."
    echo ""
    exec "$INSTALL_DIR/$BINARY_NAME" "$@"
else
    echo "  Binary updated. Services are still running."
    echo ""
    echo "  To update services:  ./hrm-deploy update"
    echo "  To check status:     ./hrm-deploy status"
    echo ""
fi
