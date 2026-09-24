#!/bin/bash
# 04_cleanup.sh
# Tears down everything built for the test service, in reverse order.
# Idempotent - safe to run even if an earlier step already failed partway through.

SVC_NAME="bgdsvc_Mobin"
TMPDIR="/mnt/${SVC_NAME}_tmp"

echo "=== 1. Killing any processes owned by $SVC_NAME ==="
sudo pkill -u "$SVC_NAME" 2>/dev/null
echo "Done."

echo "=== 2. Removing automation (cron, logrotate, scripts) ==="
sudo crontab -r -u "$SVC_NAME" 2>/dev/null
sudo rm -f "/etc/logrotate.d/$SVC_NAME"
sudo rm -f "/usr/local/bin/${SVC_NAME}_monitor.sh"
sudo rm -f "/usr/local/bin/${SVC_NAME}_cleanup_old_files.sh"
echo "Done."

echo "=== 3. Unmounting storage (tmpfs) ==="
if mount | grep -q "$TMPDIR"; then
    sudo umount "$TMPDIR"
    echo "tmpfs unmounted."
else
    echo "tmpfs not mounted, skipping."
fi
sudo rmdir "$TMPDIR" 2>/dev/null

echo "=== 4. Removing logs ==="
sudo rm -rf "/var/log/$SVC_NAME"
echo "Done."

echo "=== 5. Removing the service identity ==="
if id "$SVC_NAME" &>/dev/null; then
    sudo userdel -r "$SVC_NAME" 2>/dev/null
    echo "User $SVC_NAME removed."
else
    echo "User $SVC_NAME already removed."
fi

echo ""
echo "=== Verification: crime scene should be clean ==="
id "$SVC_NAME" 2>&1
mount | grep "$SVC_NAME"
ps -u "$SVC_NAME" 2>&1
echo "Cleanup complete."
