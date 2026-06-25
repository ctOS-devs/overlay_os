#!/bin/bash

# Enable alias expansion
shopt -s expand_aliases

# Define the alias for rtracker
alias rt="./rtracker"

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <amd64|arm64>"
    exit 1
fi

ARCH="$1"
BASE_URL="https://dl-cdn.alpinelinux.org/alpine/v3.24/releases"

# Set variables depending on architecture
case "$ARCH" in
    amd64)
        DIR_NAME="alpine_minirootfs_amd64"
        FILENAME="alpine-minirootfs-3.24.1-x86_64.tar.gz"
        URL="${BASE_URL}/x86_64/${FILENAME}"
        ;;
    arm64)
        DIR_NAME="alpine_minirootfs_arm64"
        FILENAME="alpine-minirootfs-3.24.1-aarch64.tar.gz"
        URL="${BASE_URL}/aarch64/${FILENAME}"
        ;;
    *)
        echo "Error: Invalid architecture '$ARCH'. Please use 'amd64' or 'arm64'."
        exit 1
        ;;
esac

# 1. Download rootfs (using %% for long process)
rt Downloading $ARCH rootfs... \
    %% wget -q "$URL" -O "$FILENAME"

# 2. Unarchive rootfs (using %% for long process)
# Create directory specifically to avoid tar confusion with existing folders
rt Creating directory $DIR_NAME... \
    %o mkdir -p "$DIR_NAME"

rt Unarchiving rootfs... \
    %% tar -xzf "$FILENAME" -C "$DIR_NAME"

# 3. Delete original archive on success (using %o for quick command)
rt Cleaning up archive... \
    %o rm "$FILENAME"

echo "Done. Rootfs available at: $DIR_NAME"
