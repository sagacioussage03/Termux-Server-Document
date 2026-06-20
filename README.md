# 📱 Xiaomi 11 Lite 5G NE — Headless Server Node

> A documentation of transforming a Snapdragon 778G Android device into a 24/7 dedicated, rooted headless server.

---

## Table of Contents

- [Hardware Specs](#-hardware-specs)
- [Setup Chronology](#-setup-chronology)
- [File System Architecture](#-file-system-architecture)
- [Active Services & Projects](#️-active-services--projects)
- [Scheduled Tasks (Cron Jobs)](#-scheduled-tasks-cron-jobs)
- [Remote Access (SSH)](#-remote-access-ssh)
- [Boot Automation](#-boot-automation-termuxboot)

---

## 🛠 Hardware Specs

| Component | Detail                                        |
| --------- | --------------------------------------------- |
| **Model** | Xiaomi 11 Lite 5G NE (`lisa` — India)         |
| **CPU**   | Snapdragon 778G (Octa-core)                   |
| **RAM**   | 8 GB LPDDR4X                                  |
| **Storage** | 128 GB UFS 2.2                              |
| **Status** | Bootloader Unlocked · Rooted (Magisk)        |

---

## 🏗 Setup Chronology

### Phase 1 — Hardware Unshackling

1. **Bootloader Unlocking** — Completed 168-hour security cooldown on **March 8, 2026**.
2. **Kernel Patching**
   - Sourced official Fastboot ROM `V14.0.8.0.TKOINXM`.
   - Extracted `boot.img` and patched via **Magisk v26+**.
   - Flashed via PC:
     ```bash
     fastboot flash boot magisk_patched.img
     ```
3. **Superuser Activation** — Use `su` to enter super-user mode and `exit` to leave.

### Phase 2 — Server Foundation

| Layer              | Detail                                                                 |
| ------------------ | ---------------------------------------------------------------------- |
| **Connectivity**   | `openssh` configured on port `8022`                                    |
| **Persistence**    | `termux-wake-lock` active (prevents CPU scaling / deep sleep)          |
| **Hardware Bridge** | `termux-api` integrated for system-level hardware calls               |
| **Root Access**    | Superuser permissions granted to Termux for low-level system control   |

---

## 📂 File System Architecture

| Path                                            | Description                                                         |
| ----------------------------------------------- | ------------------------------------------------------------------- |
| `/data/data/com.termux/files/`                  | App root                                                            |
| `~/` (`/data/data/com.termux/files/home`)       | User home (`$HOME`)                                                 |
| `/data/data/com.termux/files/usr/`              | System prefix (`$PREFIX`) — where packages like `python` are installed (viewable under superuser) |
| `~/storage/shared` → `/storage/emulated/0/`    | Shared storage (Android internal storage)                           |
| `~/projects/cron-jobs/`                         | Cron job scripts & metadata (scheduled tasks)                       |

---
## 🎨 Ambient Visuals (The "Wall-Mount" Mode)

To prevent AMOLED burn-in and maintain a "Cyberpunk" aesthetic, a rotation script is used to alternate between procedural art and system visuals.

### Visual Configuration:
- **Digital Forest:** `cbonsai -l -i -w 3`
  - Procedural ASCII growth with a 3-second interval between generations.
- **Matrix Rain:** `cmatrix -s -b`
  - Bolded digital rain in screensaver mode.

## 🔄 Process Control: The Cycle Logic

- **Execution Strategy:** Backgrounding with PID tracking.
- **Workflow:** 
  - `cbonsai ... &`: Launches procedural art as a background task.
  - `$!`: Captures the Process ID for targeted termination.
  - `kill $PID`: Ensures clean exit of ncurses-based animations before the next cycle.
- **Stability:** Using `sleep` instead of `timeout` to prevent IO-blocking and blank screens on Android 13/14.

## ⚙️ Active Services & Projects

This node hosts several foundational services and full-stack projects.

### 🛠️ Core Utilities

| Service               | Detail                                                                     |
| --------------------- | -------------------------------------------------------------------------- |
| **SSH Daemon**        | Started via `sshd` for remote PC access                                    |
| **Python Environment**| Python 3.x initialized                                                     |
| **Process Monitoring**| `btop` (root-enabled). Path: `/data/data/com.termux/files/usr/bin/btop` (Type `su` first, then run absolute path) |
| **Power Management**  | ACCA (Advanced Charging Controller) — battery bypass at 60% charge (40-60)         |

### 🐘 PostgreSQL Database Service

Primary relational database service running locally on Xiaomi 11 Lite 5G NE via Termux.

| Property | Value |
| :--- | :--- |
| **Engine** | PostgreSQL 18.2 (`aarch64-android`) |
| **Host** | `127.0.0.1` |
| **Port** | `5432` |
| **User** | `u0_a21` |
| **Data Path** | `/data/data/com.termux/files/usr/var/lib/postgresql` |

**Service Management:**
- **Start:** `pg_ctl -D $PREFIX/var/lib/postgresql start`
- **Stop:** `pg_ctl -D $PREFIX/var/lib/postgresql stop`
- **Status:** `pg_ctl -D $PREFIX/var/lib/postgresql status`

> [!NOTE]
> The service is bound to localhost for security. To access from a PC in the future, use an SSH tunnel on port `8022`.

### 🦙 OLLAMA - Local LLM Server

Local Large Language Model server running on the device.

**Service Management:**
- **Start:** 
  ```bash
  nohup env OLLAMA_HOST=0.0.0.0 ollama serve > ollama.log 2>&1 &
  ```
  *(Starts in the background and logs output to `ollama.log` in the current directory)*
- **Stop:** `pkill ollama`
- **Port:** `11434`

### 🧠 Project Synapse

**Project Synapse** is the primary *Smart Hub* application running on this node.

| Aspect                  | Detail                                                              |
| ----------------------- | ------------------------------------------------------------------- |
| **Role**                | Headless "Jarvis"-style controller                                  |
| **Stack**               | FastAPI backend + React (Vite) frontend                             |
| **Hardware Integration**| `termux-api` for physical hardware interaction (vibration, TTS, sensors) |

### 🌿 Dendrite-LLM

A self-hosted LLM chat application built for **Android (Termux)**, powered by **Ollama** and **PostgreSQL**.

| Layer    | Technology                                   |
|----------|----------------------------------------------|
| Frontend | React 19, Vite 6, Tailwind CSS v4            |
| Backend  | Python 3.13, FastAPI, SQLAlchemy, httpx      |
| Database | PostgreSQL                                   |
| LLM      | Ollama (llama3.2:3b, configurable)           |
| Platform | Android Termux (aarch64)                     |

---

## ⏰ Scheduled Tasks (Cron Jobs)

Recurring tasks are managed by **`crond`** (from the `cronie` package), which reads the user's crontab and executes bash scripts on a defined schedule.

### How It Works

```
crond (daemon) ──reads──▶ crontab (schedule file) ──triggers──▶ scripts (~/projects/cron-jobs/)
```

### Service Management

| Action | Command |
|---|---|
| **Start** | `crond` |
| **Stop** | `pkill crond` |
| **Status** | `pgrep crond && echo "Running" \|\| echo "Not running"` |
| **View jobs** | `crontab -l` |
| **Edit jobs** | `crontab -e` |

> [!NOTE]
> `crond` is started automatically on boot via `~/.termux/boot/start-crond`.

### Active Cron Jobs

| Job | Schedule | Expression | Description |
|---|---|---|---|
| **Stand-Up Reminder** | Every hour, 8 AM – 10 PM | `0 8-22 * * *` | TTS voice alert reminding you to get up from your chair |

> [!TIP]
> Scripts, setup instructions, and Synapse integration context are in the [`cron-jobs/`](cron-jobs/) directory of this repository.

---

## 🔑 Remote Access (SSH)

### Quick Connect

SSH is pre-configured so you can connect with a single command:

```bash
ssh xiaomi-server
```

This works because of the SSH config entry at `C:\Users\achyu\.ssh\config`:

```
Host xiaomi-server
    HostName 192.168.1.112
    User u0_a386
    Port 8022
```

> [!NOTE]
> The `HostName` IP may change if the phone reconnects to the network. Update it as needed.

### Optional: SSH Key Authentication

Set up SSH keys to skip the password prompt on every connection. *(Guide TBD)*

---

## 🚀 Boot Automation (Termux:Boot)

[Termux:Boot](https://wiki.termux.com/wiki/Termux:Boot) runs scripts automatically when the device boots.

### Setup

1. Create the boot scripts directory:
   ```bash
   mkdir -p ~/.termux/boot
   ```
2. Add a script (e.g. `~/.termux/boot/start-sshd`):
   ```bash
   #!/data/data/com.termux/files/usr/bin/bash
   termux-wake-lock
   sshd
   ```
3. Make it executable:
   ```bash
   chmod +x ~/.termux/boot/start-sshd
   ```

> [!TIP]
> If multiple scripts exist in `~/.termux/boot/`, they execute in **sorted (alphabetical) order**.

### Active Boot Scripts

| Script | Purpose |
|---|---|
| `start-sshd` | Acquires wake-lock and starts the SSH daemon |
| `start-crond` | Starts the cron daemon for scheduled tasks |
