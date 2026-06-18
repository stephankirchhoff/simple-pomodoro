# 🍅 Simple Pomodoro

**A simple taskbar Pomodoro timer for KDE Plasma.**

A native Plasma 6 panel widget for the Pomodoro Technique — no separate app,
no shrunken tray icon, just a clean `MM:SS` readout sitting in your panel at
the same visual weight as your clock.

<!-- ![Panel view](screenshots/panel.png) -->

## Features

- **Lives in the panel** — not a tiny tray icon, full panel-height text right next to your clock
- **One click to control** — click the icon (🍅 / ☕ / 🌿) to start or pause, click the digits to open the detail popup
- **Clear visual feedback** — the icon spins and pops on every click; a little wiggle marks each phase transition
- **Presets** — four built-in schedules (Classic 25/5/15, Extended 50/10/20, Deep Work 90/15/30, Quick 15/3/10), or save your own from Settings
- **Auto-continue** — optionally skip straight into the next phase instead of pausing between work and breaks (toggle in the popup or in Settings)
- **Desktop notifications** — via `notify-send` when a focus session or break ends
- **Zero extra dependencies** — pure QML + KConfigXT, no Python, no Electron, nothing to install beyond Plasma itself

## Usage

| Action | Result |
|---|---|
| Click the icon (🍅/☕/🌿) | Start / pause the timer |
| Click the timer digits | Open / close the detail popup |
| Right-click the widget → *Configure…* | Change durations, manage presets |

## Installation

### From source
```bash
git clone https://github.com/stephankirchhoff/simple-pomodoro.git
cd simple-pomodoro
./scripts/install.sh
```
Then restart Plasma so it picks up the new widget:
```bash
plasmashell --replace & disown
```
Add it via right-click on your panel → **Add Widgets…** → search **Simple Pomodoro**.

### From the KDE Store
Search for **Simple Pomodoro** directly inside Plasma:
right-click your panel → **Add Widgets…** → **Get New Widgets…**.

## Updating

```bash
git pull
./scripts/install.sh
```
`install.sh` always does a clean remove-then-install — `kpackagetool6`'s
`--upgrade` flag turned out to be unreliable for this package, so don't use
it directly.

## Configuring

Right-click the widget → **Configure Simple Pomodoro…** to:
- Pick a built-in preset or set custom work/break/interval durations
- Save your own presets
- Delete presets you no longer use
- Turn **auto-continue** on/off (same toggle is also available directly in the popup)

## Development

No build step — it's plain QML. After editing files under `contents/`,
re-run `./scripts/install.sh` to test, then restart Plasma.

To rebuild the distributable `.plasmoid` package (e.g. for a GitHub Release
or the KDE Store):
```bash
./scripts/package.sh
```

## Known limitations

- The "pomodoros completed" counter resets whenever Plasma restarts (it's session-based, not calendar-based)
- English-only for now — strings aren't wrapped in `i18n()` yet

Contributions and issues are welcome — see [LICENSE](LICENSE) below for what
that means in practice.

## License

[PolyForm Noncommercial License 1.0.0](LICENSE).

In plain terms: you're free to use, copy, and modify this for **any
noncommercial purpose** — personal use, learning, tinkering, sharing
modified versions with friends, all of it. What you can't do is sell it, or
use it (modified or not) as part of a paid product or service. Copyright
stays with Stephan Kirchhoff.

## Author

**Stephan Kirchhoff** — [github.com/stephankirchhoff](https://github.com/stephankirchhoff)
