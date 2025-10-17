## quickshell-niri

This project contains examples of [Quickshell](https://quickshell.outfoxxed.me/) configuration for the [niri](https://github.com/YaLTeR/niri) Wayland compositor, using the [QML plugin for niri](https://github.com/imiric/qml-niri).


### Setup

1. Install Quickshell version >=0.2.1, and niri version >=25.08.

2. [Install the QML plugin for niri.](https://github.com/imiric/qml-niri#installation)

3. For specific widgets:
   - Battery: [UPower](https://upower.freedesktop.org/)
   
4. Fonts/icons: [Barlow](https://tribby.com/fonts/barlow/)


### Usage

Clone this repository, and copy or symlink any of the examples into `~/.config/quickshell/`. E.g.:
```shell
git clone https://github.com/imiric/quickshell-niri.git
ln -s "$PWD/quickshell-niri/simple-bar" ~/.config/quickshell/niri-simple-bar
```

Then you can run Quickshell with the specific configuration:
```shell
quickshell --config niri-simple-bar
```

You can run this automatically when niri starts by adding this to your niri configuration file (`~/.config/niri/config.kdl`):
```kdl
spawn-at-startup "quickshell" "--config" "niri-simple-bar"
```


### Examples

#### [Simple bar](/simple-bar)

![Simple bar](/assets/simple-bar.png)

A plain bar with a workspace indicator and switcher, centered title of the currently focused window, and text battery and date/time widgets.

This is a slightly modified version of [SimpleQuickshellBar](https://github.com/the-ink-serpent/SimpleQuickshellBar), but for niri instead of Hyprland.


## License

[MIT](/LICENSE)
