<p align="center"><img src="assets/logo.png" width="160" alt="ArchPill logo"></p>

# ArchPill

A small, lightweight Dynamic Island–style pill for **KDE Plasma 6 on Wayland**,
written in [Quickshell](https://quickshell.org) (QML). It sits at the top-centre
of the screen, stays out of the way, and slides down when your mouse touches the
top edge. It runs *alongside* Plasma's own panel — it doesn't replace anything.

> Work in progress. Stage 1 (pill, hover reveal, clock, battery, volume, now
> playing) is done. A full README with screenshots and shortcut examples comes
> in stage 5.

## Install

```bash
git clone https://github.com/yeeboein/archpill.git
cd archpill
./install.sh
qs -c archpill -n -d
```

Move the mouse to the top-centre edge of the screen.

## Customise it

Open **ArchPill Settings**: find it in your app menu, click the palette button
at the top of the control centre, or run `qs -c archpill ipc call archpill openSettings`. In there you can:

- **Pill**: drag modules into any order, add/remove them (clock, now playing,
  volume, battery, control-centre button, Wi-Fi, Bluetooth, mic, weather,
  separator) and set their options
- **Control Centre**: drag widgets into any order, pick from 50+ built-in
  widgets, add **any installed app** as a tile, or make **your own buttons**
  (open a website, a folder, or run any command)
- **Appearance**: 12 themes, every colour, opacity, sizes, corner radius,
  font, text size, animation speed
- **Behaviour**: always-on or hover, hover area, delays, what a click does,
  layer, which screens
- **Music & More**: preferred player, ignored players, volume step, weather
  location, dark/light schemes
- **Shortcuts & Reset**: copy-paste commands for keyboard shortcuts, reset

Everything applies instantly and is saved to `~/.config/archpill/config.json`
(only the settings you change are stored there).

## Commands

```bash
qs -c archpill ipc call archpill toggle      # keep the pill open / let it hide
qs -c archpill ipc call archpill toggleControlCenter
qs -c archpill ipc call archpill toggleMedia
qs -c archpill ipc call archpill openSettings
qs -c archpill ipc call archpill playPause
qs -c archpill ipc call archpill next
qs -c archpill ipc call archpill previous
qs log -c archpill                           # show ArchPill's log
qs kill -c archpill                          # stop ArchPill
```

## Uninstall

```bash
./uninstall.sh
```

## License

MIT
