# simple-bar

A minimal Quickshell bar with a system tray, time, battery, volume, and simple app launchers with single-instance focus.

## Features
- Volume widget (PipeWire): mute on click, scroll to change, shows percent
- System tray: left/middle/right click actions, context menu displayed properly
- Time widget: 12-hour clock with date, implicit sizing for stable layout
- Battery widget (UPower): percentage with implicit sizing
- Launcher buttons:
  - Nerd font icons
  - Detects if an app is already open and focuses it instead of spawning
  - If not open, launches detached via Quickshell.execDetached

## Configure launchers
Edit `modules/bar/Bar.qml` and adjust the example loaders on the left side:

```
Loader { active: true; sourceComponent: LauncherButton {
  icon: ""              // nerd-font glyph
  exec: "/usr/bin/alacritty" // command to start when not running
  matchAppId: "alacritty"     // used to detect existing windows
  spawner: bar                // use bar.spawn (execDetached)
}}
```

Tips:
- `matchAppId` is case-insensitive and matches substrings against multiple fields (Wayland toplevel appId and title; compositor fields like class/wmClass).
- If focusing doesn’t work at first, open the app and try a different token seen in its appId/class/title. Using the exact appId is usually best (e.g., `"Alacritty"`).
- Set `singleInstance: true` (default) to avoid duplicate instances when a match exists.

## Spawn behavior
The bar prefers the documented Quickshell API:
- `Quickshell.execDetached(["sh", "-c", cmd])` to start processes detached
- Falls back to `niri.spawn(cmd)` if available

No external helper is needed.

## System tray
- Passes the bar window to tray menu display to satisfy platform menu requirements.
- Requires `//@ pragma UseQApplication` at the top of `shell.qml` (already set).

## Notes
- Fonts: icons use "Symbols Nerd Font" and text uses "Barlow Medium"; adjust families to your installed fonts as needed.
- Layout: widgets use implicit sizing to prevent layout issues on startup.
