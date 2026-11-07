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

## Configure

Edit `~/.config/archpill/config.json`. Changes apply as soon as you save.
Only keep the settings you want to change; anything missing falls back to
`config.default.json`. Choose modules and their order with `pill.modules`:

```json
{ "pill": { "modules": ["media", "clock", "volume", "battery"] } }
```

Available modules: `clock`, `media`, `volume`, `battery`.

## Commands

```bash
qs -c archpill ipc call archpill toggle      # keep the pill open / let it hide
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
