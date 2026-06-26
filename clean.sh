#!/bin/bash

# Script to clean OOS build artifacts for specific architectures or both

# Function to display help
show_help() {
    cat << 'EOF'
Usage: ./clean [OPTION]

Clean OOS build artifacts from the project directory.

Options:
    amd64       Clean only amd64 artifacts (OOS_amd64 directory and OOS_amd64.tar.gz)
    arm64       Clean only arm64 artifacts (OOS_arm64 directory and OOS_arm64.tar.gz)
    --help, -h  Display this help message and exit

If no option is provided, both amd64 and arm64 artifacts will be cleaned.
EOF
}

# Function to clean amd64 artifacts
clean_amd64() {
    rm -rf "OOS_amd64"
    rm -f "OOS_amd64.tar.gz"
}

# Function to clean arm64 artifacts
clean_arm64() {
    rm -rf "OOS_arm64"
    rm -f "OOS_arm64.tar.gz"
}

# Function to clean both architectures
clean_both() {
    clean_amd64
    clean_arm64
}

# Main script logic

# Check for help option
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

# Process based on arguments
case "$1" in
    amd64)
        echo "Cleaning amd64 artifacts..."
        clean_amd64
        ;;
    arm64)
        echo "Cleaning arm64 artifacts..."
        clean_arm64
        ;;
    "")
        # No arguments provided, clean both
        echo "Cleaning all artifacts (amd64 and arm64)..."
        clean_both
        ;;
    *)
        # Unknown option
        echo "Error: Unknown option '$1'" >&2
        echo "" >&2
        show_help >&2
        exit 1
        ;;
esac

exit 0
