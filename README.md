# 📱 Xiaomi 11 Lite 5G NE | Personal Headless Node

A documentation of the transformation of a Snapdragon 778G Android device into a 24/7 dedicated, rooted headless server.

## 🛠 Hardware Specs
- **Model:** Xiaomi 11 Lite 5G NE (lisa - India)
- **CPU:** Snapdragon 778G (Octa-core)
- **RAM:** 8GB LPDDR4X
- **Storage:** 128GB UFS 2.2
- **Status:** **Bootloader Unlocked** | **Rooted (Magisk)**

## 🏗 Setup Chronology

### Phase 1: The "Surgery" (Hardware Unshackling)
1. **Bootloader Unlocking:** Completed 168-hour security cooldown on March 8, 2026.
2. **Kernel Patching:** - Sourced official Fastboot ROM `V14.0.8.0.TKOINXM`.
   - Extracted `boot.img` and patched via Magisk v26+.
   - Flashed via PC: `fastboot flash boot magisk_patched.img`.
3. **Superuser Activation:** Installed `tsu` (Termux SuperUser) to bridge Android root to the Linux environment.

### Phase 2: Server Foundation (Current State)
- **Connectivity:** `openssh` configured on port `8022`. 
- **Persistence:** `termux-wake-lock` active to prevent CPU frequency scaling/deep sleep.
- **Hardware Bridge:** `termux-api` integrated for system-level hardware calls.
- **Root Access:** Superuser permissions granted to Termux for low-level system control.

## ⚙️ Active Services & Management
- **SSH Daemon:** Started via `sshd` for remote PC access.
- **Environment:** Python 3.x environment initialized.
- **Process Monitoring:** `btop` (Root-enabled) used for real-time per-core clock speed and thermal tracking.
- **Power Management:** ACCA (Advanced Charging Controller) configured to bypass battery at 60% charge to ensure 24/7 hardware longevity.

---

## 🧠 Project Synapse (Ongoing)
*Project Synapse* is the primary "Smart Hub" application residing on this node.
- **Role:** Headless "Jarvis" style controller.
- **Stack:** FastAPI Backend + React (Vite) Frontend.
- **Hardware Integration:** Utilizes `termux-api` for physical hardware interaction (vibration, TTS, sensors).
- **Execution:** Managed via `PM2` within a dedicated Python virtual environment (`venv-Synapse`).
