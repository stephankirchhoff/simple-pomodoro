# KDE Store Listing — copy/paste reference

Submit at: https://store.kde.org/product/add
Category to pick: **Plasma 6 Addons → Plasmoids** (browse an existing widget
of the same type first if the exact category name isn't obvious — the
taxonomy isn't always intuitive from the form alone)

---

## Title
Simple Pomodoro

## Summary (short)
A simple taskbar Pomodoro timer for KDE Plasma.

## Full description (paste into the description box)

A native Plasma 6 panel widget for the Pomodoro Technique — no separate app,
no shrunken tray icon, just a clean MM:SS readout sitting in your panel at
the same visual weight as your clock.

**Features**
- Lives in the panel, not a tiny tray icon
- Click the icon (🍅 / ☕ / 🌿) to start or pause
- Click the timer digits to open a detail popup with a progress bar and skip/reset buttons
- Clear click feedback (icon spin + pop) plus a wiggle animation on phase transitions
- Four built-in presets (Classic 25/5/15, Extended 50/10/20, Deep Work 90/15/30,
  Quick 15/3/10) — or save your own from the Settings page
- Optional auto-continue — skip the pause between phases if you'd rather it just keep going
- Desktop notifications when a focus session or break ends
- Pure QML/KConfigXT — no Python, no Electron, no extra runtime dependencies

**Usage**
- Click the icon to start/pause
- Click the timer digits to open/close the popup
- Right-click → Configure to change durations or manage presets

**Source code:** https://github.com/stephankirchhoff/simple-pomodoro

## Tags
pomodoro, timer, productivity, panel, plasmoid, focus

## License
**PolyForm Noncommercial License 1.0.0.** The Store's license dropdown almost
certainly won't list this by name — pick the closest available option (often
labeled "Custom" or "Other"), and paste this into the license/notes field:

> Licensed under the PolyForm Noncommercial License 1.0.0. Free for any
> noncommercial use (personal, educational, hobby). Selling it or using it
> in a commercial product/service is not permitted. Full text:
> https://github.com/stephankirchhoff/simple-pomodoro/blob/main/LICENSE

## Source / Homepage fields
- Source: `https://github.com/stephankirchhoff/simple-pomodoro`
- Homepage: same, or leave blank

## File to upload
`pomodoro.plasmoid` — rebuild any time with:
```bash
./scripts/package.sh
```

## Changelog (paste into the version notes field)
**1.0 — Initial release**
- Panel widget with click-to-start, click-for-details interaction
- 4 built-in presets + custom preset support
- Optional auto-continue (skip the pause between phases)
- Click and phase-transition animations
- Desktop notifications

---

## Screenshots to prepare (Store requires at least one, ideally 3)
1. The panel view — icon + timer sitting next to your clock
2. The popup open — showing the progress bar and buttons
3. The Settings page — showing the preset dropdown

KDE's Spectacle tool works well for this — press <kbd>Print Screen</kbd> or
run `spectacle -r` to select a region.
