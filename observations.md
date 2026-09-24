# Linux Deep Dive — Observations

## 1. User Isolation

Created a dedicated system user:

```text
bgdsvc_mobin
```

The user was configured with `/usr/sbin/nologin` to prevent normal interactive shell access.

**Observation:**
The service account successfully exists separately from regular users, reducing unnecessary privileges and improving workload isolation.

---

## 2. tmpfs Storage

A 256 MB RAM-backed filesystem was mounted at:

```text
/mnt/bgdsvc_mobin_tmp
```

### Before Stress

```text
Size:      256M
Used:      0
Available: 256M
Use:       0%
```

### After Disk Stress

```text
Size:      256M
Used:      256M
Available: 0
Use:       100%
```

**Observation:**
The filesystem stopped accepting additional data after reaching its 256 MB limit and returned:

```text
No space left on device
```

The host system remained operational.

---

## 3. CPU Stress

CPU load was generated using `stress-ng`.

**Observation:**
CPU utilization increased significantly while the stress process was running. `top` was used to monitor the active processes and resource consumption.

---

## 4. Memory Stress

Memory pressure was generated using:

```bash
stress-ng --vm 1 --vm-bytes 200M
```

**Observation:**
Memory usage increased during the test, but the workload remained within the configured safety boundary.

OOM check:

```bash
sudo dmesg | grep -i oom
```

No OOM-killer event was observed during the test.

---

## 5. SSH Hardening

SSH was configured to use port:

```text
2222
```

Security settings included:

```text
PermitRootLogin no
PasswordAuthentication no
AllowUsers bgdsvc_mobin
```

**Observation:**
SSH access was restricted to the configured user and key-based authentication was used.

> Note: Since `bgdsvc_mobin` uses `/usr/sbin/nologin`, an interactive SSH shell is intentionally unavailable unless the shell configuration is changed for the lab.

---

## 6. Cron Monitoring

Two scheduled jobs were configured:

```cron
*/5 * * * * /usr/local/bin/bgdsvc_mobin_monitor.sh
0 2 * * * /usr/local/bin/bgdsvc_mobin_cleanup_old_files.sh
```

**Observation:**
Cron provides automatic monitoring every five minutes and scheduled cleanup of old files.

---

## 7. Logrotate

Logrotate was configured for:

```text
/var/log/bgdsvc_mobin/
```

The configuration provides log rotation, compression, size limits, and retention.

**Observation:**
Manual execution with `logrotate -f` successfully triggered the configured rotation behavior.

---

## 8. Cleanup

The cleanup script removed:

* Running service processes
* Cron jobs
* Temporary files
* `tmpfs` mount
* Logs
* Logrotate configuration
* Service user

Final checks confirmed that the service environment could be removed without leaving the intended lab resources behind.

---

## 9. Overall Observation

The lab successfully demonstrated a complete Linux service lifecycle:

```text
User Creation
     ↓
Resource Isolation
     ↓
tmpfs Setup
     ↓
Stress Testing
     ↓
Monitoring
     ↓
SSH Hardening
     ↓
Log Management
     ↓
System Cleanup
```

The main practical lessons were **resource isolation, controlled stress testing, security hardening, automation, and idempotent system administration**.
