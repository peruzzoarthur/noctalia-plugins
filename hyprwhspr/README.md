# Hyprwhspr

Bar indicator for [hyprwhspr-rs](https://github.com/goodroot/hyprwhspr) voice dictation.
UI only — it does not capture audio or run its own service.

- Hidden while idle.
- Pulsing red microphone while recording (left click stops the recording).
- Loader glyph while transcribing.
- Muted mic-off glyph with a setup hint if `hyprwhspr-rs` is missing or its daemon is unreachable.

## Requirements

- `hyprwhspr-rs` on `PATH` with its daemon running (on NixOS: `services.hyprwhspr-rs.enable = true`).
- Recording is started with the hyprwhspr-rs keyboard shortcut (see `$XDG_CONFIG_HOME/hyprwhspr-rs/config.jsonc`); the widget only appears while dictation is active.

## Install

This plugin lives in the `my-plugins` path source. Enable it and add the widget to a bar section:

```sh
noctalia msg plugins enable peruzzoarthur/hyprwhspr
```

```toml
[widget.hyprwhspr]
type = "peruzzoarthur/hyprwhspr:hyprwhspr"
```

Then place `hyprwhspr` in `bar.widgets.start`, `center`, or `end`.

## Manual test checklist

- [ ] `noctalia plugins lint` passes with no errors or warnings.
- [ ] Idle: widget is invisible.
- [ ] Press the dictation shortcut: mic glyph appears and pulses within ~1 s.
- [ ] Stop speaking / stop recording: loader glyph shows while transcribing, then the widget disappears.
- [ ] While recording, left click stops the recording.
- [ ] While transcribing, left click does nothing.
- [ ] With the daemon stopped: mic-off glyph with the daemon tooltip.
- [ ] With the binary absent from PATH: mic-off glyph with the missing-binary tooltip.
