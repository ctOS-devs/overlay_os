#!/bin/bash

# Define the list of architectures to build
# You can manually define them: ARCHS=("amd64" "arm64")
# Or automatically detect them based on files present:
ARCHS=()
for f in docker-compose-*.yml; do
    # Extract architecture name (e.g., 'amd64' from 'docker-compose-amd64.yml')
    arch_name=$(echo "$f" | sed 's/docker-compose-//g' | sed 's/.yml//g')
    ARCHS+=("$arch_name")
done

echo "Found architectures to build: ${ARCHS[*]}"

# Ensure the single build script exists and is executable
BUILD_SCRIPT="./build.sh"
if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "Error: $BUILD_SCRIPT not found."
    exit 1
fi

# Make sure the build script is executable
chmod +x "$BUILD_SCRIPT"

# Loop through each architecture and build
for ARCH in "${ARCHS[@]}"; do
    echo "----------------------------------------"
    echo "Processing architecture: $ARCH"
    echo "----------------------------------------"

    # Execute the single build script
    "$BUILD_SCRIPT" "$ARCH"

    # Check if the build for this arch was successful
    if [ $? -ne 0 ]; then
        echo "Build failed for $ARCH. Continuing with next architecture..."
    else
        echo "Build completed for $ARCH."
    fi
done

echo "----------------------------------------"
echo "All builds processed."
ls -l proot_*
