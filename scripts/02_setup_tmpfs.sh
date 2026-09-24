#!/bin/bash
# 02_setup_tmpfs.sh
# Sets up a 256M tmpfs scratch space for the service account (idempotent)

SVC_NAME="bgdsvc_Mobin"
TMPDIR="/mnt/${SVC_NAME}_tmp"

sudo mkdir -p "$TMPDIR"

if mount | grep -q "$TMPDIR"; then
    echo "tmpfs already mounted at $TMPDIR."
else
    sudo mount -t tmpfs -o size=256M tmpfs "$TMPDIR"
    echo "tmpfs mounted at $TMPDIR."
fi

sudo chown "$SVC_NAME:$SVC_NAME" "$TMPDIR"

echo "---- Verification ----"
df -h "$TMPDIR"
