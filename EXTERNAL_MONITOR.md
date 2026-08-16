# External monitor support for the i3 setup

## Context

Plugging an external monitor into the laptop's HDMI port produces no output under i3,
while the exact same hardware works out of the box under Cinnamon.

Diagnosis (all verified on this machine):

- The HDMI port is wired to the **NVIDIA GTX 1050 Ti**, not the Intel iGPU.
  `xrandr --listproviders` shows `modesetting` (Intel, cap `0x9` = Source Output |
  Sink Offload) driving the screen, and `NVIDIA-G0` (cap `0x2` = Sink Output) owning
  the HDMI connector. DRM confirms it: `card1-eDP-1` is Intel, `card2-HDMI-A-1` is NVIDIA.
- `prime-select` is `on-demand`, `nvidia_drm modeset=1` is already set, driver 580.159.03.
  `/var/log/Xorg.0.log` shows the NVIDIA driver actively polling `DFP-0` and logging
  connect/disconnect events. **The driver stack is healthy - nothing needs fixing there.**
- The actual cause: **nothing in the dotfiles ever calls `xrandr`.** No `.xprofile`,
  no `.xinitrc`, no `autorandr`, no udev hotplug rule, and zero display lines in
  `.config/i3/config`. A `grep` for `xrandr` across the whole repo returns nothing.

So when HDMI is plugged in, X marks the output connected but never assigns it a CRTC,
a mode, or a position in the screen - it sits at 0x0 and the monitor stays black.
Cinnamon works because `cinnamon-settings-daemon` runs an xrandr plugin that does this
automatically. i3 is only a window manager and deliberately ships no display manager,
so that piece has to be supplied.

**No GPU mode change is needed.** `prime-select` stays on `on-demand`; reverse PRIME
is already functional, as Cinnamon proves.

Outcome: HDMI configures itself automatically on plug and unplug (Cinnamon-like), plus
an on-demand menu to switch between extend / mirror / external-only / laptop-only.

## Approach

Two layers, so nothing depends on remembering a keybind:

1. **`autorandr`** (apt, `1.14-2`) provides the missing daemon. It ships a udev rule and
   systemd user units that fire on DRM hotplug, fingerprint the connected displays by
   EDID, and apply the matching saved profile. This is the direct analogue of
   `csd-xrandr`. Its config lives in `~/.config/autorandr/`, so profiles stay tracked
   in this repo.
2. **`display.sh`** - a small script for manual layout switching, reached through a rofi
   menu on `$mod+p`. Both layers funnel through the same refresh helper so polybar and
   the wallpaper always end up correct.

## Files

### New: `.config/i3/scripts/display.sh`

Single entry point, takes a mode argument: `auto | extend | mirror | external | internal | refresh`.

- Detects the internal panel as `eDP-1` and picks the external as the first non-internal
  `connected` output from `xrandr --query` (do not hardcode `HDMI-1-0`; the name carries a
  provider-index suffix that can shift).
- Before any layout call, bind the sink provider so the NVIDIA-owned output can be given
  a CRTC. Guard on the provider existing and swallow errors so it is a no-op when already bound:

  ```
  xrandr --setprovideroutputsource NVIDIA-G0 modesetting
  ```

  This is the reverse-PRIME step. It is what makes `HDMI-1-0` assignable at all.
- Layout modes are plain `xrandr` calls: `--right-of` for extend, `--same-as` for mirror,
  `--off` on the internal for external-only. `--primary` moves with the mode.
- `auto` delegates to `autorandr --change --default mobile` and returns early - the
  postswitch hook does the refresh, so it is not done twice.
- `refresh` re-runs `feh --bg-scale ~/Pictures/solarpunk_1080.jpg` and
  `~/.config/polybar/launch.sh`. Every other mode ends by calling it.

### New: `.config/i3/scripts/display-menu.sh`

`rofi -dmenu` picker (reuse the existing `~/.config/rofi/config.rasi`, as
`.config/i3/config:54` already does) listing the four layouts plus Auto, exec'ing
`display.sh` with the chosen mode.

### New: `.config/autorandr/postswitch`

Executable hook, one line: `exec "$HOME/.config/i3/scripts/display.sh" refresh`.
This is what makes polybar and the wallpaper follow an automatic hotplug.

### Modify: `.config/polybar/launch.sh`

Currently launches exactly one bar. Change the tail to iterate connected outputs,
passing each through the `MONITOR` env var:

- Read the primary from `xrandr --query` (`/ connected primary/`).
- For each ` connected` output, launch bar `main` on the primary and `secondary`
  elsewhere, as `MONITOR=$m polybar --reload "$BAR"`.
- Keep the existing `killall -q polybar` + wait loop at the top - it already makes the
  script idempotent, which is why `display.sh refresh` can call it freely.
- Fall back to launching `main` on the first output if no primary is set.

### Modify: `.config/polybar/config.ini`

- `.config/polybar/config.ini:27` - change `monitor =` to `monitor = ${env:MONITOR:}`.
- Add a `[bar/secondary]` section after `[bar/main]`: `inherit = bar/main` plus
  `tray-position = none`. Only one polybar instance may own the system tray; without
  this the second bar logs a tray-conflict error on every launch.

### Modify: `.config/i3/config`

- Line 46: replace the direct polybar launch with
  `exec_always --no-startup-id ~/.config/i3/scripts/display.sh auto`.
  Display setup must run *before* the bar so polybar sees the final layout.
- Line 48: drop the standalone `feh` exec - `display.sh refresh` now owns the wallpaper.
- Add to the Applications/keybind block (`$mod+p` and `$mod+shift+p` are both currently unbound):

  ```
  bindsym $mod+p       exec --no-startup-id ~/.config/i3/scripts/display-menu.sh
  bindsym $mod+shift+p exec --no-startup-id ~/.config/i3/scripts/display.sh auto
  ```

- In the Workspaces block (after line 121), split workspaces across outputs. i3 4.23
  accepts a fallback list, so these degrade correctly when nothing is plugged in:

  ```
  workspace $ws1 output primary
  ...  (ws1 through ws5)
  workspace $ws6  output HDMI-1-0 eDP-1
  ...  (ws6 through ws10)
  ```

## Setup steps (one-time, needs the monitor on hand)

1. `sudo apt install autorandr` - installs the udev rule and user units that drive the
   automatic path.
2. Unplug HDMI, then `autorandr --save mobile`.
3. Plug HDMI in, run `~/.config/i3/scripts/display.sh extend`, then `autorandr --save docked`.
4. `systemctl --user enable --now autorandr.service` if the package does not enable it.

Only `docked` and `mobile` are saved as profiles. Mirror and external-only stay as
manual `display.sh` modes - two autorandr profiles sharing one EDID fingerprint are
ambiguous on `--change`, so keeping alternates out of autorandr makes hotplug deterministic.

## Verification

Cannot be tested right now - `HDMI-1-0` currently reads `disconnected`, so the monitor
must be plugged in for any of this.

1. **Provider binding**: with HDMI plugged, run `xrandr --listproviders` then
   `xrandr --query | grep HDMI`. Expect `HDMI-1-0 connected` with a real mode list.
   If it stays at `0x0` with no CRTC, the `--setprovideroutputsource` call is the thing
   to debug first.
2. **Manual path**: `~/.config/i3/scripts/display.sh extend` - external should light up
   and `xrandr --query` should show `HDMI-1-0 connected 1920x1080+1920+0`.
3. **Menu**: `$mod+p`, cycle through all four layouts; each should apply without an i3 restart.
4. **Polybar**: a bar on both screens, tray only on the primary. Check `/tmp/polybar-*.log`
   for errors.
5. **Automatic path** (the real test): unplug and replug HDMI without touching the keyboard.
   The `docked` profile should apply on its own. If not, `journalctl --user -u autorandr -b`
   and `udevadm monitor --udev` while replugging will show whether the event is firing.
6. **Workspaces**: `$mod+6` should land on the external, `$mod+1` on the laptop; unplugging
   should pull ws6-10 back onto `eDP-1` without losing windows.

## If the automatic path misbehaves

Fall back in this order, since the driver stack is known-good:

1. Confirm the udev rule exists: `ls /lib/udev/rules.d/*monitor*` (shipped by autorandr).
2. Re-save the `docked` profile - EDID fingerprints differ per monitor, so a profile saved
   against one display will not match another.
3. Only if reverse PRIME itself proves unstable across suspend/resume: `sudo prime-select nvidia`
   + reboot makes NVIDIA drive everything and the HDMI output attach natively as `HDMI-0`.
   This costs battery life and should not be needed - Cinnamon working is strong evidence
   that the on-demand path is sound.
