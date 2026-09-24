# Linux Deep Dive — SysAdmin & Stress Testing Lab

A hands-on Linux/DevOps lab covering **user isolation, tmpfs storage, system stress testing, SSH hardening, monitoring, log rotation, and cleanup**.

## 📁 Project Structure

```text
.
├── screenshots/
│   ├── 02.01_afterFill.png
│   ├── 02.02_afterFill.png
│   ├── 03.01_cpu_stress.png
│   ├── 03.02_Top_cpu_stress.png
│   ├── 03.03_memory_stress.png
│   ├── 03.04_Top_memory_stress.png
│   ├── 04.00_SSH.png
│   ├── 04.01_SSH_aceess.png
│   ├── 05.00_crontab.png
│   ├── 06.00_Logrotate.png
│   └── 07.00_CleanUp.png
├── scripts/
│   ├── 01_create_user.sh
│   ├── 02_setup_tmpfs.sh
│   ├── 03_stress_and_populate.sh
│   └── 04_cleanup.sh
├── observations.md
└── README.md
```

## 1. Service User

Creates an isolated system user:

```bash
sudo useradd -r -m -s /usr/sbin/nologin bgdsvc_mobin
```

Verify:

```bash
id bgdsvc_mobin
getent passwd bgdsvc_mobin
```

---

## 2. tmpfs Scratch Storage

Creates a **256 MB RAM-backed filesystem**:

```bash
sudo mount -t tmpfs -o size=256M tmpfs /mnt/bgdsvc_mobin_tmp
```

Verify:

```bash
df -h /mnt/bgdsvc_mobin_tmp
```

---

## 3. Stress Testing

Script:

```text
scripts/03_stress_and_populate.sh
```

Supported modes:

```bash
./03_stress_and_populate.sh --disk
./03_stress_and_populate.sh --cpu
./03_stress_and_populate.sh --mem
./03_stress_and_populate.sh --all
```

### Disk

Fills the 256 MB `tmpfs` until:

```text
No space left on device
```

### CPU / Memory

Uses `stress-ng` for controlled resource pressure.

```bash
stress-ng --vm 1 --vm-bytes 200M
```

Monitor:

```bash
top
free -h
```

OOM check:

```bash
sudo dmesg | grep -i oom
```

---

## 4. SSH Hardening

SSH configuration:

```text
Port 2222
PermitRootLogin no
PasswordAuthentication no
AllowUsers bgdsvc_mobin
```

Key permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Test:

```bash
ssh -i ~/.ssh/bgdsvc_mobin_key -p 2222 bgdsvc_mobin@localhost
```

---

## 5. Cron Monitoring

Every 5 minutes:

```cron
*/5 * * * * /usr/local/bin/bgdsvc_mobin_monitor.sh
```

Daily cleanup:

```cron
0 2 * * * /usr/local/bin/bgdsvc_mobin_cleanup_old_files.sh
```

Verify:

```bash
crontab -l -u bgdsvc_mobin
```

---

## 6. Logrotate

Configuration:

```text
/etc/logrotate.d/bgdsvc_mobin
```

Test:

```bash
sudo logrotate -f /etc/logrotate.d/bgdsvc_mobin
```

Logs:

```text
/var/log/bgdsvc_mobin/
```

Configured for rotation, compression, size limits, and retention.

---

## 7. Cleanup

Script:

```text
scripts/04_cleanup.sh
```

Cleanup includes:

* Running processes
* Cron jobs
* SSH/config files
* Logrotate configuration
* tmpfs mount
* Logs
* Service user

Example:

```bash
sudo pkill -u bgdsvc_mobin
sudo umount /mnt/bgdsvc_mobin_tmp
sudo userdel -r bgdsvc_mobin
```

Verify:

```bash
id bgdsvc_mobin
mount | grep bgdsvc_mobin
```

---

##  Verification

Screenshots document:

* tmpfs capacity and disk saturation
* CPU stress
* memory stress
* SSH configuration/access
* cron jobs
* logrotate
* complete cleanup

All evidence is available in:

```text
screenshots/
```

---

## Key Learnings

* Linux service-user isolation
* `tmpfs` and filesystem management
* CPU, memory, and disk stress testing
* SSH security hardening
* Cron automation
* Logrotate
* Bash scripting and idempotency
* Safe system teardown
* Basic Linux resource management

## Lifecycle

```text
Create User
    ↓
Setup tmpfs
    ↓
Stress Test
    ↓
Monitor
    ↓
Harden SSH
    ↓
Rotate Logs
    ↓
Cleanup
```
