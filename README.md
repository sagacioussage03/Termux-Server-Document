# 📱 Xiaomi 11 Lite 5G NE — Headless Server Node

> A documentation of transforming a Snapdragon 778G Android device into a 24/7 dedicated, rooted headless server.

---

## Table of Contents

- [Hardware Specs](#-hardware-specs)
- [Setup Chronology](#-setup-chronology)
- [File System Architecture](#-file-system-architecture)
- [Active Services & Management](#️-active-services--management)
- [Remote Access (SSH)](#-remote-access-ssh)
- [Boot Automation](#-boot-automation-termuxboot)
- [Project Synapse](#-project-synapse)

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

---

## ⚙️ Active Services & Management

| Service               | Detail                                                                     |
| --------------------- | -------------------------------------------------------------------------- |
| **SSH Daemon**        | Started via `sshd` for remote PC access                                    |
| **Python Environment** | Python 3.x initialized                                                   |
| **Process Monitoring** | `btop` (root-enabled) for real-time per-core clock speed & thermal tracking |
| **Power Management**  | ACCA (Advanced Charging Controller) — battery bypass at 60% charge for 24/7 longevity |

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

---

## 🧠 Project Synapse

**Project Synapse** is the primary *Smart Hub* application running on this node.

| Aspect                  | Detail                                                              |
| ----------------------- | ------------------------------------------------------------------- |
| **Role**                | Headless "Jarvis"-style controller                                  |
| **Stack**               | FastAPI backend + React (Vite) frontend                             |
| **Hardware Integration** | `termux-api` for physical hardware interaction (vibration, TTS, sensors) |

---

<!-- 
## 📝 Notes & TODO
- [ ] Add SSH key setup guide
- [ ] Document ACCA configuration in detail
- [ ] Expand Project Synapse section as it develops
-->