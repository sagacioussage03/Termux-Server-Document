# 🧠 Synapse — Cron Jobs Tab Integration Context

> This document provides all the context needed to build a "Cron Jobs" management tab in **Project Synapse** (FastAPI + React/Vite). Hand this to another AI along with the Synapse codebase.

---

## What This Feature Does

Adds a new **"Cron Jobs"** tab to the Synapse dashboard that lets you:
- **View** all registered cron jobs (name, schedule, status, last run time)
- **Toggle** individual cron jobs on/off via a switch
- **See** a human-readable description of what each job does and when it runs

---

## How Cron Works on the Server

### The Stack

```
crond (daemon) ──reads──▶ crontab (schedule file) ──triggers──▶ bash scripts (in ~/projects/cron-jobs/)
```

- **`crond`**: Background daemon that checks the crontab every minute. Started on boot via `~/.termux/boot/start-crond`.
- **`crontab`**: A per-user schedule file. Managed via the `crontab` CLI tool.
- **Scripts**: Bash scripts stored in `~/projects/cron-jobs/`. Each script is a self-contained task.

### Key CLI Commands (What the Backend Will Execute)

```bash
# List all cron entries
crontab -l

# Add a new cron entry (append without destroying existing ones)
(crontab -l 2>/dev/null; echo "0 8-22 * * * ~/projects/cron-jobs/stand_up_reminder.sh") | crontab -

# Remove a cron entry by script name
crontab -l | grep -v "stand_up_reminder.sh" | crontab -

# Disable a cron entry (comment it out — keeps it in the crontab but inactive)
crontab -l | sed 's|^\(.*stand_up_reminder.sh\)$|#\1|' | crontab -

# Enable a cron entry (uncomment it)
crontab -l | sed 's|^#\(.*stand_up_reminder.sh\)$|\1|' | crontab -

# Check if crond is running
pgrep crond && echo "running" || echo "stopped"

# Start / stop crond
crond          # start
pkill crond    # stop
```

---

## Recommended Architecture

### Data Model

Each cron job is represented by a **metadata JSON file** stored alongside the script. This avoids needing a database for cron state.

**File**: `~/projects/cron-jobs/jobs.json`

```json
[
  {
    "id": "stand_up_reminder",
    "name": "Stand-Up Reminder",
    "description": "Speaks a TTS reminder to get up from your chair every hour.",
    "script": "stand_up_reminder.sh",
    "cron_expression": "0 8-22 * * *",
    "enabled": true,
    "created_at": "2026-06-20T16:00:00+05:30"
  }
]
```

| Field | Type | Description |
|---|---|---|
| `id` | `string` | Unique slug identifier |
| `name` | `string` | Human-readable display name |
| `description` | `string` | What this job does |
| `script` | `string` | Filename of the bash script (relative to `~/projects/cron-jobs/`) |
| `cron_expression` | `string` | The 5-field cron schedule |
| `enabled` | `boolean` | Whether the job is currently active in the crontab |
| `created_at` | `string` | ISO 8601 timestamp |

### Why a JSON File Instead of a Database?

1. Cron jobs are few in number (you'll have maybe 5-10 max)
2. The **actual source of truth** for "is this running?" is always the crontab itself
3. The JSON provides **display metadata** (name, description) that the crontab doesn't have
4. No migration headaches — just read/write a file

---

### Backend API (FastAPI)

Add these endpoints to the Synapse FastAPI backend:

#### `GET /api/cron-jobs`

Returns all registered cron jobs with their current status.

**Implementation:**
1. Read `~/projects/cron-jobs/jobs.json` for metadata
2. Run `crontab -l` via `subprocess.run()` to get the live crontab
3. For each job in `jobs.json`, check if its script appears uncommented in the crontab → set `enabled` accordingly
4. Return the merged list

**Response:**
```json
[
  {
    "id": "stand_up_reminder",
    "name": "Stand-Up Reminder",
    "description": "Speaks a TTS reminder to get up from your chair every hour.",
    "script": "stand_up_reminder.sh",
    "cron_expression": "0 8-22 * * *",
    "cron_human": "Every hour from 8 AM to 10 PM",
    "enabled": true,
    "created_at": "2026-06-20T16:00:00+05:30"
  }
]
```

#### `POST /api/cron-jobs/{job_id}/toggle`

Enables or disables a specific cron job.

**Request Body:**
```json
{
  "enabled": true
}
```

**Implementation:**
1. Read the current crontab via `subprocess.run(["crontab", "-l"], capture_output=True)`
2. If `enabled: true` → uncomment the line containing the job's script name
3. If `enabled: false` → comment out the line containing the job's script name
4. Write the modified crontab back via `subprocess.run(["crontab", "-"], input=modified_crontab)`
5. Update `jobs.json` to reflect the new state
6. Return the updated job object

**Python sketch:**
```python
import subprocess
import json
from pathlib import Path

CRON_JOBS_DIR = Path.home() / "projects" / "cron-jobs"
JOBS_FILE = CRON_JOBS_DIR / "jobs.json"

def get_crontab() -> str:
    """Read the current crontab."""
    result = subprocess.run(
        ["crontab", "-l"],
        capture_output=True, text=True
    )
    return result.stdout if result.returncode == 0 else ""

def set_crontab(content: str):
    """Write a new crontab."""
    subprocess.run(
        ["crontab", "-"],
        input=content, text=True, check=True
    )

def toggle_cron_job(script_name: str, enable: bool):
    """Enable or disable a cron job by commenting/uncommenting its line."""
    crontab = get_crontab()
    lines = crontab.strip().split("\n")
    new_lines = []

    for line in lines:
        if script_name in line:
            if enable:
                # Remove leading # to enable
                new_lines.append(line.lstrip("#").lstrip())
            else:
                # Add # to disable
                if not line.startswith("#"):
                    new_lines.append(f"#{line}")
                else:
                    new_lines.append(line)
        else:
            new_lines.append(line)

    set_crontab("\n".join(new_lines) + "\n")
```

#### `GET /api/cron-jobs/daemon-status`

Checks if `crond` is running.

**Implementation:**
```python
def is_crond_running() -> bool:
    result = subprocess.run(["pgrep", "crond"], capture_output=True)
    return result.returncode == 0
```

---

### Frontend (React)

Add a new tab/page to the Synapse React frontend.

#### UI Layout

```
┌─────────────────────────────────────────────────────┐
│  ⏰ Cron Jobs                      crond: 🟢 Active │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │ 🪑 Stand-Up Reminder              [🔵 ON ]  │    │
│  │ Every hour from 8 AM to 10 PM               │    │
│  │ Speaks a TTS reminder to get up             │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │ 💧 Hydration Reminder             [⚪ OFF]  │    │
│  │ Every 30 minutes, 9 AM to 5 PM             │    │
│  │ Reminds you to drink water                  │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

#### Key Components

| Component | Description |
|---|---|
| `CronJobsPage` | Main page/tab container. Fetches jobs from `GET /api/cron-jobs` |
| `CronJobCard` | Individual job card showing name, human-readable schedule, description, and toggle |
| `DaemonStatus` | Small indicator showing if `crond` is running (polls `GET /api/cron-jobs/daemon-status`) |

#### Toggle Interaction

```
User flips toggle → POST /api/cron-jobs/{id}/toggle → Backend comments/uncomments crontab line → Refetch jobs list → UI updates
```

---

## Security Considerations

> [!WARNING]
> **Never allow arbitrary command execution.** The backend should only operate on:
> 1. Scripts that exist in `~/projects/cron-jobs/`
> 2. Jobs registered in `jobs.json`
>
> Validate that the `script` field matches an actual file in the cron-jobs directory before any crontab modification.

> [!IMPORTANT]
> **Path validation**: Always resolve the script path and confirm it's within `~/projects/cron-jobs/` to prevent path traversal attacks (e.g., `../../etc/passwd`).

---

## Existing Server Context

| Property | Value |
|---|---|
| **Server** | Xiaomi 11 Lite 5G NE (Termux) |
| **Backend Framework** | FastAPI (Python) |
| **Frontend Framework** | React (Vite) |
| **Cron daemon** | `cronie` package → `crond` |
| **Scripts directory** | `~/projects/cron-jobs/` |
| **Metadata file** | `~/projects/cron-jobs/jobs.json` |
| **API base URL** | Determined by Synapse's existing config |

---

## Files to Reference

- [stand_up_reminder.sh](./stand_up_reminder.sh) — Example cron job script (TTS-based)
- [SETUP.md](./SETUP.md) — Server-side setup guide with all CLI commands
- Synapse codebase — for existing API patterns, router structure, and frontend component conventions
