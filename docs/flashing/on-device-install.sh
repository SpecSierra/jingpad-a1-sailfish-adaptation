#!/bin/sh
set -eu

ROOTFS_URL="${1:-}"
ROOTFS_ARCHIVE="/data/sailfishos-rootfs.tar.bz2"
ROOTFS_DEST="/data/.stowaways/sailfishos"

if [ -z "${ROOTFS_URL}" ]; then
    echo "usage: sh on-device-install.sh <rootfs-url>"
    exit 1
fi

if ! mount | grep -q " on /data "; then
    echo "/data is not mounted"
    exit 1
fi

fetch_file() {
    url="$1"
    dst="$2"

    if command -v wget >/dev/null 2>&1; then
        wget -O "$dst" "$url"
        return 0
    fi

    if command -v busybox >/dev/null 2>&1; then
        if busybox wget -O "$dst" "$url"; then
            return 0
        fi
    fi

    if command -v curl >/dev/null 2>&1; then
        curl -L "$url" -o "$dst"
        return 0
    fi

    echo "No supported downloader found (need wget, busybox wget, or curl)"
    exit 1
}

echo "Creating Sailfish rootfs directory..."
rm -rf "$ROOTFS_DEST"
mkdir -p "$ROOTFS_DEST"

echo "Downloading rootfs archive..."
rm -f "$ROOTFS_ARCHIVE"
fetch_file "$ROOTFS_URL" "$ROOTFS_ARCHIVE"

echo "Extracting rootfs..."
tar --numeric-owner -xvjf "$ROOTFS_ARCHIVE" -C "$ROOTFS_DEST"

echo "Cleaning up..."
rm -f "$ROOTFS_ARCHIVE"
sync

echo "Done. Sailfish rootfs staged in $ROOTFS_DEST"
