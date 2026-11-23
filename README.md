# DWU

dwm for user7210unix. A patched dwm 6.8 with st, dmenu, slstatus, picom, dunst and a Firefox userChrome, all driven by nine palettes and one settings script.

## Install

```
curl -fsSL https://raw.githubusercontent.com/user7210unix/dwm/main/install.sh | bash
```

The installer shows a section menu: deps, build, fonts, session, firefox, zsh, laptop, uninstall. Unattended:

```
curl -fsSL https://raw.githubusercontent.com/user7210unix/dwm/main/install.sh | bash -s -- --all --yes
```

From a local checkout just run `./install.sh`, it builds that checkout and links the `dwu-*` scripts into `/usr/local/bin`.

Flags: `--distro arch|debian|fedora|void|gentoo|freebsd`, `--sections deps,build`, `--prefix DIR`, `--src DIR`.

Supported: Arch family, Debian, Ubuntu, Pop!_OS, Fedora, Void, Gentoo. FreeBSD is best effort.

## What you get

* dwm with vanitygaps, pertag, systray, status2d, alpha bar, underline tags, scratchpad, floatpos, seamless restart and five extra layouts
* "DWM" in italic at the left of the bar, click it for the menu (apps, settings, network, display, power)
* st with scrollback, alpha, boxdraw, live recoloring and a nerd symbols fallback
* dmenu centered, fuzzy, highlighted, themed from the palette
* slstatus with a checklist of modules (cpu, ram, swap, disk, temperature, load, volume, mic, brightness, network, ip, speed, vpn, battery, weather, uptime, keyboard layout, date, clock), switch them in `dwu-settings` -> Status bar, no rebuild
* weather in the bar from your IP location (or a city you choose), in °C or °F, via open-meteo.com, no API key
* dwm settings menu: bar top or bottom, floating or flush, height, opacity, brand text or icon (or hide it), systray, gaps, smart gaps, border width
* minimal Thunar and a palette themed GTK look, your interface font is applied to every GTK app
* zsh with plugins and a rounded-pill prompt, set as your default shell
* picom config generated from variables, VM detection picks the xrender backend
* plug and play monitors through `dwu-display`, lid aware
* Firefox 150+ userChrome and userContent generated from the palette

## zsh

The `zsh` section installs zsh, clones autosuggestions, syntax-highlighting, completions and history-substring-search into `~/.local/share/dwu/zsh/plugins`, adds a themed prompt with Nerd icons (`~/.config/dwu/zshrc`, sourced from `~/.zshrc`) and sets zsh as your login shell. An existing `~/.zshrc` is saved as `~/.zshrc.dwu-backup`. Run it alone with `./install.sh --sections zsh`.

## Daily use

| Key | Action |
| --- | --- |
| Super + Return | terminal |
| Super + Space | launcher |
| Super + s | dwu-settings |
| Super + F1 | all keybinds |
| Super + Shift + r | restart dwm, windows stay |
| Super + Shift + e | power menu |

## Palettes

verdigris, adobe-dusk, claret, parchment-lilac, mulberry-cream, violet-hour, midnight-brass, ember-slate, tidewater. Switch with `dwu-settings` or `dwu-settings palette claret`. Colors, fonts and all dwm settings apply live, no rebuild.

## Files

* `dwm st dmenu slstatus` sources with `patches.h` and `config.h`
* `palettes/` palette files
* `fonts/fonts.list` font catalog used by dwu-settings
* `scripts/` all dwu-* commands
* `firefox/` userChrome, userContent, user.js
* `PATCHES.md` enabled patches with links, `DOC.md` details, `FAQ.md` problems

## Credits

dwm, st, dmenu, slstatus by suckless.org. Patch trees by bakkeby (dwm-flexipatch, st-flexipatch, dmenu-flexipatch). Nerd Fonts by ryanoasis. Firefox CSS inspired by TileFox, FoxOne and Cascade from firefoxcss-store.github.io.
