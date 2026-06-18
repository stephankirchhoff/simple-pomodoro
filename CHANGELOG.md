# Changelog

All notable changes to Simple Pomodoro are documented here.

## 1.0 — 2026-06-18

Initial public release.

- Panel widget showing a live `MM:SS` countdown at full panel height, next to phase icon (🍅 Focus / ☕ Short Break / 🌿 Long Break)
- Click the icon to start/pause; click the timer digits to open/close the detail popup
- Click feedback animation (icon spin + pop) and a wiggle animation on phase transitions
- Detail popup with progress bar, Start/Pause, Skip, and Reset controls, plus a quick preset switcher
- Settings page (right-click → Configure) with 4 built-in presets (Classic 25/5/15, Extended 50/10/20, Deep Work 90/15/30, Quick 15/3/10) and support for saving custom presets
- Auto-continue toggle (popup and Settings) — optionally skip straight into the next phase instead of pausing between work and breaks (off by default)
- Desktop notifications via `notify-send` on phase completion
