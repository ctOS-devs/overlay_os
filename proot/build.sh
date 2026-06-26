#!/bin/bash

# Check if architecture argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <architecture>"
    echo "Example: $0 amd64 or $0 arm64"
    exit 1
fi

ARCH="$1"
COMPOSE_FILE="docker-compose-${ARCH}.yml"
BINARY_NAME="proot_${ARCH}"

# Check if the docker-compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Error: Docker compose file '$COMPOSE_FILE' not found."
    exit 1
fi

echo "Starting build for architecture: $ARCH"

mkdir "proot_${ARCH}_build"

# Build using docker-compose
docker-compose -f "$COMPOSE_FILE" up

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Error: Docker build failed for $ARCH."
    exit 1
fi

# Define the source path based on architecture
# Logic derived from your request:
# amd64 -> proot_amd64/proot/src/proot
# arm64 -> proot_arm64/proot/src/proot
SOURCE_DIR="proot_${ARCH}_build/proot/src"
SOURCE_FILE="${SOURCE_DIR}/proot"

# Check if the binary was created
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Binary not found at $SOURCE_FILE"
    exit 1
fi

# Copy binary to root folder with new name
echo "Copy binary to ./${BINARY_NAME}"
cp "$SOURCE_FILE" "./${BINARY_NAME}"

if [ $? -eq 0 ]; then
    echo "Success! Binary copied at: ./${BINARY_NAME}"
else
    echo "Error: Failed to copy binary."
    exit 1
fi
