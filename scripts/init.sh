#!/bin/sh

proot_bin=""
arch=""

# Look for the specific proot binaries and determine architecture
for suffix in amd64 arm64; do
    f="./proot_$suffix"
    if [ -f "$f" ] && [ -x "$f" ]; then
        proot_bin="$f"
        arch="$suffix"
        break
    fi
done

if [ -z "$proot_bin" ]; then
    echo "Error: No executable proot_amd64 or proot_arm64 found in current directory" >&2
    exit 1
fi

# Set alpine directory based on the detected proot architecture
alpine_dir="../OOS_$arch"

if [ ! -d "$alpine_dir" ]; then
    alpine_dir="../alpine_minirootfs_$arch"
fi

if [ ! -d "$alpine_dir" ]; then
    echo "Error: $alpine_dir does not exist" >&2
    exit 1
fi

if [ ! -d "$alpine_dir/home" ]; then
    echo "Error: $alpine_dir/home does not exist" >&2
    exit 1
fi

HOME=/home
export HOME

echo "Executing: HOME=/home $proot_bin -w /home -b $alpine_dir/home/:/home -r $alpine_dir/"
exec "$proot_bin" -w /home -b "$alpine_dir/home/:/home" -r "$alpine_dir/"
