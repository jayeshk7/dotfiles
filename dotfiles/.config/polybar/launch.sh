#!/usr/bin/env bash
# ── Polybar launch script ──────────────────────────────────
# Kills any running polybar instances then relaunches.

killall -q polybar

# Wait until all polybar processes die
while pgrep -u $UID -x polybar > /dev/null; do sleep 0.1; done

# Launch main bar
polybar main 2>&1 | tee -a /tmp/polybar-main.log & disown

echo "Polybar launched"
