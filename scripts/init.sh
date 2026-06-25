#!/bin/sh

# Find proot binary (handles any suffix after proot_)
proot_bin=""
for f in ./proot_*; do
    if [ -f "$f" ] && [ -x "$f" ]; then
        proot_bin="$f"
        break
    fi
done

# Verify proot binary found
if [ -z "$proot_bin" ]; then
    echo "Error: No executable proot_* binary found in current directory" >&2
    exit 1
fi

# Find alpine minirootfs directory
alpine_dir=""
for d in ../alpine_minirootfs_*; do
    if [ -d "$d" ]; then
        alpine_dir="$d"
        break
    fi
done

# Verify alpine directory found
if [ -z "$alpine_dir" ]; then
    echo "Error: No alpine_minirootfs_* directory found in parent directory" >&2
    exit 1
fi

# Verify required paths exist
if [ ! -d "$alpine_dir/home" ]; then
    echo "Error: $alpine_dir/home does not exist" >&2
    exit 1
fi

# Construct and execute command
# Use printf for safe path handling, then eval carefully or use exec
HOME=/home
export HOME

echo "Executing: HOME=/home $proot_bin -w /home -b $alpine_dir/home/:/home -r $alpine_dir/"
exec "$proot_bin" -w /home -b "$alpine_dir/home/:/home" -r "$alpine_dir/"
