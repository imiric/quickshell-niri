## quickshell-niri

This project contains examples of [Quickshell](https://quickshell.outfoxxed.me/) configuration for the [niri](https://github.com/YaLTeR/niri) Wayland compositor, using the [QML plugin for niri](https://github.com/imiric/qml-niri).


### Setup

1. Install Quickshell version >=0.2.1, and niri version >=25.08.

2. [Install the QML plugin for niri.](https://github.com/imiric/qml-niri#installation)

3. See the `README` within each example directory for additional instructions and dependencies.


### Usage

Clone this repository, and copy or symlink any of the example directories into `~/.config/quickshell/`. E.g.:
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

- [Simple bar](/simple-bar)

  ![Simple bar](/simple-bar/screenshot.png)

- [Fancy bar](/fancy-bar)

  ![Fancy bar](/fancy-bar/screenshot.png)


## License

[MIT](/LICENSE)
