#!/bin/bash

# ============================================================
# OOS Build Script
# ============================================================

# Check if rtracker exists
if [ ! -f "./rtracker" ]; then
    echo "Error: ./rtracker not found in the root directory."
    exit 1
fi

# Setup rtracker aliases
shopt -s expand_aliases
alias rt="./rtracker"

# ------------------------------------------------------------
# Step 1: Select Architecture
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
# Step 2: Preparation
# ------------------------------------------------------------
# Clean previous build if exists
if [ -d "$BUILD_DIR" ]; then
    rt "Cleaning previous build directory..." \
    %% rm -rf "$BUILD_DIR"
fi

# ------------------------------------------------------------
# Step 3: Copy Rootfs
# ------------------------------------------------------------
rt "Copying Alpine rootfs files..." \
%% cp -a "$SRC_ROOTFS/." "$BUILD_DIR/"

# ------------------------------------------------------------
# Step 4: Copy PRoot Binary
# ------------------------------------------------------------
# Check if source binary exists
if [ ! -f "$PROOT_BIN" ]; then
    echo "Error: Binary $PROOT_BIN not found."
    exit 1
fi

rt "Copying PRoot binary..." \
%% cp "$PROOT_BIN" "$BUILD_DIR/$PROOT_DEST_NAME"

# ------------------------------------------------------------
# Step 5: Copy Init Script
# ------------------------------------------------------------
if [ ! -f "scripts/init.sh" ]; then
    echo "Error: scripts/init.sh not found."
    exit 1
fi

rt "Copying init script..." \
%% cp "scripts/init.sh" "$BUILD_DIR/init.sh"

# ------------------------------------------------------------
# Step 6: Archiving
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
