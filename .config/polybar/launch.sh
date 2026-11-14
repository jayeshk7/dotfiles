#!/usr/bin/env bash
# ── Polybar launch script ──────────────────────────────────
# Kills any running polybar instances then relaunches.

killall -q polybar

# Wait until all polybar processes die
while pgrep -u $UID -x polybar > /dev/null; do sleep 0.1; done

# Launch main bar
polybar main 2>&1 | tee -a /tmp/polybar-main.log & disown

# Reserve the bar's space. override-redirect=true hides the bar from i3, so it
# has no strut and windows would tile underneath it. i3 restart (mod+shift+r)
# resets runtime gaps, so this has to be reapplied here — i3 calls this script
# via exec_always, so it re-runs on every restart. Not a `gaps top` line in the
# i3 config itself: that combination broke unrelated things last time.
# 55 = offset-y(12) + height(35) + 8 clearance; `gaps inner 7` adds the rest.
i3-msg gaps top all set 50 > /dev/null

echo "Polybar launched"
