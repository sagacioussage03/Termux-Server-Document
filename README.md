# Xiaomi 11 Lite 5G NE (lisa) - Personal Home Server

A documentation of my journey turning a Snapdragon 778G Android device into a 24/7 dedicated headless server.

## 🛠 Hardware Specs
- **Model:** Xiaomi 11 Lite 5G NE (India)
- **CPU:** Snapdragon 778G (8 Cores)
- **RAM:** 8GB
- **Storage:** 128GB
- **Status:** Rooted (Magisk), Bootloader Unlocked.

## 🏗 Setup Chronology

### Phase 1: Unshackling the Hardware
1. **Bootloader Unlocking:** Waited 168 hours (Xiaomi's standard wait time).
2. **Rooting:**
   - Downloaded Fastboot ROM `V14.0.8.0.TKOINXM`.
   - Patched `boot.img` using the Magisk App.
   - Flashed patched image via `fastboot flash boot`.

### Phase 2: Termux Foundation
- **Wake Lock:** Acquired to prevent CPU sleep.
- **Termux:API:** Installed for hardware interaction (TTS, Battery, etc.).
- **Essential Packages:** - `python`, `openssh`, `tsu` (Root bridge for Termux), `termux-api`.

## 🚀 Projects Running
- [ ] **Photo Cloud:** (Planned) FileBrowser for 128GB remote storage.
- [ ] **Voice Alarm:** (Planned) Python-based news-reading alarm clock.
- [ ] **GitHub Runner:** (Optional) Using the phone for CI/CD.

## 🛡 Stability & Maintenance
- **Battery Management:** Using ACCA to limit charge to 60%.
- **Thermal Monitor:** `btop` for real-time core monitoring.
