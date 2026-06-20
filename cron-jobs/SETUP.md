# 🔧 Cron Jobs — Setup & Deployment Guide

> How to deploy and manage cron jobs on the Xiaomi 11 Lite 5G NE Termux server.

---

## Prerequisites

You need two packages:

```bash
pkg install cronie termux-api
```

- **`cronie`** — Provides the `crond` daemon and `crontab` command.
- **`termux-api`** — Provides `termux-tts-speak`, `termux-vibrate`, `termux-notification`, etc. (likely already installed).

> [!NOTE]
> Make sure the **Termux:API** Android app is also installed from F-Droid/GitHub — the `termux-api` package alone won't work without it.

---

## Deploying a Cron Job (Step by Step)

### 1. Copy the Script to the Server

From your PC (where this repo lives), use `scp`:

```bash
scp cron-jobs/stand_up_reminder.sh xiaomi-server:~/projects/cron-jobs/
```

### 2. Make It Executable

SSH into the server and run:

```bash
ssh xiaomi-server
chmod +x ~/projects/cron-jobs/stand_up_reminder.sh
```

### 3. Test It Manually First

```bash
~/projects/cron-jobs/stand_up_reminder.sh
```

You should hear the phone speak the reminders aloud. If not, test TTS directly:

```bash
termux-tts-speak "Hello, this is a test."
```

### 4. Add the Crontab Entry

```bash
crontab -e
```

This opens your crontab file in an editor. Add this line:

```
0 8-22 * * * ~/projects/cron-jobs/stand_up_reminder.sh
```

**Reading it**: "At minute 0, for every hour from 8 through 22, every day of every month, every day of the week — run `stand_up_reminder.sh`."

Save and exit. Verify with:

```bash
crontab -l
```

### 5. Start the Cron Daemon

```bash
crond
```

That's it. `crond` runs in the background and will execute your jobs on schedule.

Verify it's running:

```bash
pgrep crond
```

---

## Boot Automation — Starting `crond` on Reboot

Create a separate boot script so `crond` starts automatically when the phone boots:

```bash
cat > ~/.termux/boot/start-crond << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Start the cron daemon on boot
crond
EOF

chmod +x ~/.termux/boot/start-crond
```

> [!TIP]
> Boot scripts execute in alphabetical order. `start-crond` runs after `start-sshd`, which is fine — there are no ordering dependencies between them.

---

## Managing Cron Jobs Manually

This section covers how to add, remove, enable, and disable individual cron jobs from the command line — useful for understanding how the Synapse backend would do it programmatically.

### List All Active Cron Jobs

```bash
crontab -l
```

Output example:
```
0 8-22 * * * ~/projects/cron-jobs/stand_up_reminder.sh
*/30 * * * * ~/projects/cron-jobs/some_other_job.sh
```

### Add a New Cron Job

```bash
# Append a new entry without opening an editor
(crontab -l 2>/dev/null; echo "*/15 9-17 * * 1-5 ~/projects/cron-jobs/hydration_reminder.sh") | crontab -
```

**Breaking this down:**
1. `crontab -l 2>/dev/null` — Get existing entries (suppress error if empty)
2. `; echo "..."` — Append the new entry
3. `| crontab -` — Pipe the combined output back as the new crontab

### Remove a Specific Cron Job

```bash
# Remove a specific line by grep-ing it out
crontab -l | grep -v "stand_up_reminder.sh" | crontab -
```

This prints all lines *except* the one matching `stand_up_reminder.sh`, then sets that as the new crontab.

### Disable a Cron Job (Comment Out)

```bash
# Comment out a specific job (disable without removing)
crontab -l | sed 's|^\(.*stand_up_reminder.sh\)$|#\1|' | crontab -
```

### Enable a Cron Job (Uncomment)

```bash
# Re-enable a commented-out job
crontab -l | sed 's|^#\(.*stand_up_reminder.sh\)$|\1|' | crontab -
```

### Check if `crond` Is Running

```bash
pgrep crond && echo "Running" || echo "Not running"
```

### Start / Stop / Restart `crond`

```bash
# Start
crond

# Stop
pkill crond

# Restart
pkill crond && crond
```

---

## Cron Expression Cheat Sheet

| Expression | Meaning |
|---|---|
| `0 8-22 * * *` | Every hour from 8 AM to 10 PM |
| `*/15 * * * *` | Every 15 minutes |
| `0 9 * * 1-5` | 9 AM, Monday through Friday |
| `30 6 * * *` | 6:30 AM every day |
| `0 */2 * * *` | Every 2 hours |
| `0 0 1 * *` | Midnight on the 1st of every month |

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Job doesn't run | Is `crond` running? Check `pgrep crond` |
| TTS doesn't speak | Test `termux-tts-speak "test"` directly. Check Termux:API app is installed |
| Script runs but no sound | Phone might be on silent. Check media volume |
| `crontab: command not found` | Install cronie: `pkg install cronie` |
| Jobs work manually but not from cron | Use full paths in scripts. Cron has a minimal `$PATH` |
