if [ "$EUID" == 0 ]; then
    echo "This script should runed as default user."
    echo "(default all.sh does it as: sudo -u $USER ./script.sh)"
    exit 1
fi

# Define variables
LOCAL_BINARY="rtracker"
REMOTE_URL="https://gitea.del.pw/justuser-31/run_tracker/releases/download/latest/rtracker_x86"
TEMP_FILE="rtracker_temp"

# Function to download the latest binary
download_latest() {
    curl -L -o "$TEMP_FILE" "$REMOTE_URL"
    if [ $? -eq 0 ]; then
        mv "$TEMP_FILE" "$LOCAL_BINARY"
        chmod +x "$LOCAL_BINARY"
    else
        echo "[RT DOWN] Failed to download rtracker."
        return 1
    fi
}

# Check if the local binary exists
if [ -f "$LOCAL_BINARY" ]; then
    # Get the local file hash
    LOCAL_HASH=$(sha256sum "$LOCAL_BINARY" | awk '{ print $1 }')

    # Check if the remote version is accessible
    if curl --output /dev/null --silent --head --fail "$REMOTE_URL"; then
        # Get the remote file hash
        REMOTE_HASH=$(curl -s "$REMOTE_URL" | sha256sum | awk '{ print $1 }')

        # Compare hashes
        if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
            #echo "A newer version is available."
            download_latest
        fi
    fi
else
    download_latest
fi
