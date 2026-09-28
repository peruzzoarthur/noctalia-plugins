# Local changes to keyviz (vs upstream `h-jangra/keyviz` community version)

Saved here on 2026-08-28 after fixing device detection on my machine. The **running**
plugin is still the materialized copy at
`~/.local/state/noctalia/plugins/materialized/community/keyviz` — this folder is
a backup/fork. A community plugin update would overwrite the fix there.

## Why the fix was needed

I run **handy-keys** (evdev/uinput remapper). It grabs the physical keyboard
(Logitech PRO Gaming Keyboard, event0/1) exclusively and re-emits keystrokes
through a virtual device (`handy-keys passthrough`, event21). Upstream's
`scripts/listener.py` therefore:

1. **Saw no keyboard at all** — virtual uinput keyboards often lack the EV_REP
   capability bit, and `_is_real_keyboard()` required EV_KEY **and** EV_REP.
2. **Showed mouse clicks as `Key_272`** — my Logitech PRO X gaming mouse
   registers a fake `kbd` handler (for onboard macros) and passed the filter.

## What changed (only `scripts/listener.py`)

- `_is_real_keyboard()`: still requires EV_KEY, but now accepts devices without
  EV_REP **if they are virtual** (`/sys/class/input/eventN` realpath contains
  `/virtual/`), i.e. uinput passthroughs from keyd/kmonad/handy-keys.
- `find_keyboard_devices()`: skips any device whose `H: Handlers=` line in
  `/proc/bus/input/devices` contains `mouse` (gaming mice with kbd handlers).
- **Hotplug (2026-09-28):** upstream opened devices once at start and never
  rescanned while any fd stayed open, so a keyboard plugged in later (e.g. the
  Corne after a reset) was never read. Replaced the reader threads with a
  `select()` loop that re-runs discovery every 2s (`sync_devices()`), opening
  new keyboards and closing vanished ones.

Verify with: `python3 scripts/listener.py --test-devices` — should list the
handy-keys passthrough and **not** the mouse.

## Plugin id

Renamed to `peruzzoarthur/keyviz` (plugin.toml, service.luau, shortcut.luau,
README) and listed in `../catalog.toml`, so it installs from the `peruzzoarthur`
source next to — never on top of — the community `h-jangra/keyviz`. Keep the
community one disabled/uninstalled.

## Maybe better long-term fix

If I **stop using handy-keys** (virtual keyboard), the physical keyboard has
EV_REP and upstream's unmodified plugin works again — except the mouse would
still show as `Key_272` clicks, so the `mouse`-handler exclusion is worth
reporting upstream regardless.
</content>
