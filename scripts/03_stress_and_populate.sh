#!/bin/bash
# 03_stress_and_populate.sh
# Simulates disk, CPU, and memory pressure on the test service.
# Usage: ./03_stress_and_populate.sh [--cpu|--mem|--disk|--all]

SVC_NAME="bgdsvc_Mobin"
TMPDIR="/mnt/${SVC_NAME}_tmp"

fill_disk() {
    echo "=== Filling disk (tmpfs) ==="
    for i in $(seq 1 20); do
        dd if=/dev/urandom of="${TMPDIR}/file_$i.dat" bs=1M count=10
        df -h "$TMPDIR"
    done
}

push_cpu() {
    echo "=== Pushing CPU ==="
    if command -v stress-ng &>/dev/null; then
        sudo -u "$SVC_NAME" stress-ng --cpu 2 --timeout 30s --temp-path "$TMPDIR"
    else
        echo "stress-ng not found, improvising with yes..."
        yes > /dev/null &
        yes > /dev/null &
        sleep 30
        kill %1 %2 2>/dev/null
    fi
}

squeeze_memory() {
    echo "=== Squeezing memory ==="
    if command -v stress-ng &>/dev/null; then
        sudo -u "$SVC_NAME" stress-ng --vm 1 --vm-bytes 200M --timeout 30s --temp-path "$TMPDIR"
    else
        echo "stress-ng not installed. Please run: sudo apt install stress-ng -y"
    fi
}

run_all() {
    echo "=== Running CPU + Memory + Disk load together ==="
    sudo -u "$SVC_NAME" stress-ng --cpu 2 --vm 1 --vm-bytes 200M --timeout 30s --temp-path "$TMPDIR" &
    for i in $(seq 1 20); do
        dd if=/dev/urandom of="${TMPDIR}/load_$i.dat" bs=1M count=10
    done
    wait
    echo "=== Post-load observation ==="
    free -h
    dmesg | grep -i oom
}

case "$1" in
    --cpu)
        push_cpu
        ;;
    --mem)
        squeeze_memory
        ;;
    --disk)
        fill_disk
        ;;
    --all)
        run_all
        ;;
    *)
        echo "Usage: $0 [--cpu|--mem|--disk|--all]"
        exit 1
        ;;
esac
