#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# Stand-Up Reminder — TTS Voice Alert
# ============================================================
# Triggered by crond every hour from 8 AM to 10 PM.
# Cron expression: 0 8-22 * * *
#
# Uses termux-tts-speak to audibly remind you to stand up.
# The message is spoken multiple times with pauses in between
# to make sure you actually hear it.
# ============================================================

LOG_FILE="$HOME/projects/cron-jobs/reminder.log"

# Log the trigger time
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stand-up reminder triggered" >> "$LOG_FILE"

# Vibrate first to get attention (two short bursts)
termux-vibrate -d 400
sleep 0.5
termux-vibrate -d 400

# First announcement
termux-tts-speak "Hey! Time to get up from your chair. You've been sitting for an hour."
sleep 3

# Second reminder (in case you ignored the first)
termux-tts-speak "Come on, stand up. Stretch your legs. Walk around for a couple of minutes."
sleep 3

# Final nudge
termux-tts-speak "Your body will thank you. Get moving!"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stand-up reminder completed" >> "$LOG_FILE"
