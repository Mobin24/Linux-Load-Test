#!/bin/bash
# 01_create_user.sh
# Creates the BongoDev service account (idempotent - safe to run twice)

SVC_NAME="bgdsvc_Mobin"

if id "$SVC_NAME" &>/dev/null; then
    echo "User $SVC_NAME already exists."
else
    sudo useradd -r -m -s /usr/sbin/nologin "$SVC_NAME"
    echo "User $SVC_NAME created."
fi

echo "---- Verification ----"
id "$SVC_NAME"
getent passwd "$SVC_NAME"
