#!/bin/bash

# ============================================================
# OOS Build Script
# ============================================================

# Exit after ANY non-zero status code
set -e

ROOT=$(pwd)

# Check if rtracker exists
if [ ! -f "./rtracker" ]; then
    echo "Error: ./rtracker not found in the root directory."
    exit 1
fi

# Setup rtracker aliases
shopt -s expand_aliases
alias rt="${ROOT}/rtracker"

# ------------------------------------------------------------
# Select Architecture
# ------------------------------------------------------------
echo "Select architecture to build:"
echo "1) amd64"
echo "2) arm64"
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        ARCH="amd64"
        SRC_ROOTFS="alpine_minirootfs_amd64"
        PROOT_BIN="proot/proot_amd64"
        ;;
    2)
        ARCH="arm64"
        SRC_ROOTFS="alpine_minirootfs_arm64"
        PROOT_BIN="proot/proot_arm64"
        ;;
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac

# Define Build Output Directory
BUILD_DIR="OOS_${ARCH}"
PROOT_DEST_NAME="proot_${ARCH}"

# ------------------------------------------------------------
# Check and Build Dependencies
# ------------------------------------------------------------

# 1. Build PRoot if missing
if [ ! -f "$PROOT_BIN" ]; then
    echo "PRoot binary not found ($PROOT_BIN). Building..."
    cd proot
    rt "Building proot ($ARCH)" \
        %% ./build.sh "$ARCH"
    cd $ROOT
fi

# 2. Download Rootfs if missing
if [ ! -d "$SRC_ROOTFS" ]; then
    echo "Rootfs directory not found ($SRC_ROOTFS). Downloading..."
    rt "Downloading rootfs ($ARCH)" \
        %% ./download_rootfs.sh "$ARCH"
fi

# ------------------------------------------------------------
# Preparation
# ------------------------------------------------------------
# Clean previous build if exists
if [ -d "$BUILD_DIR" ]; then
    rt "Cleaning previous build directory..." \
    %% rm -rf "$BUILD_DIR"
fi

# ------------------------------------------------------------
# Copy Rootfs
# ------------------------------------------------------------
rt "Copying Alpine rootfs files..." \
%% cp -a "$SRC_ROOTFS/." "$BUILD_DIR/"

# ------------------------------------------------------------
# Copy resolv.conf
# ------------------------------------------------------------
rt "Copying resolv.conf..." \
%% cp configs/resolv.conf "$BUILD_DIR/"

# ------------------------------------------------------------
# Copy PRoot Binary
# ------------------------------------------------------------
# Check if source binary exists
if [ ! -f "$PROOT_BIN" ]; then
    echo "Error: Binary $PROOT_BIN not found."
    exit 1
fi

rt "Copying PRoot binary..." \
%% cp "$PROOT_BIN" "$BUILD_DIR/$PROOT_DEST_NAME"

# ------------------------------------------------------------
# Copy Init Script
# ------------------------------------------------------------
if [ ! -f "scripts/init.sh" ]; then
    echo "Error: scripts/init.sh not found."
    exit 1
fi

rt "Copying init script..." \
%% cp "scripts/init.sh" "$BUILD_DIR/init.sh"

# ------------------------------------------------------------
# Archiving
# ------------------------------------------------------------
read -p "Do you want to archive the build? (y/n): " archive_choice

if [[ "$archive_choice" =~ ^[Yy]$ ]]; then
    ARCHIVE_NAME="OOS_${ARCH}.tar.gz"

    rt "Creating archive $ARCHIVE_NAME..." \
    %% tar -czf "$ARCHIVE_NAME" "$BUILD_DIR"

    echo "Archive created: $ARCHIVE_NAME"
else
    echo "Skipping archiving."
fi

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------
echo ""
echo "Build complete: $BUILD_DIR"
