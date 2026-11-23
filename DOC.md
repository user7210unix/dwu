# DWU documentation

## Layout of a rebuild

Nothing you change in dwu-settings needs a rebuild. It writes `~/.config/dwu/Xresources` (st, dmenu) and `~/.config/dwu/dwm.rc` (dwm: colors, fonts, bar position, gaps, brand text and so on), then signals st and restarts dwm in place. dwm reads `dwm.rc` itself on every start (`dwm/patch/dwu_config.c`), so settings survive logging out and do not depend on xrdb having been merged. The same apply step writes the GTK 3 and 4 theme, fontconfig, xsettingsd, dunst and picom config, and a minimal Thunar setup on first run.

`dwu-rebuild [all|dwm|st|dmenu|slstatus] [--backup|--no-backup]` compiles (incremental, `--clean` for a full rebuild), installs to the prefix, signals the running dwm to restart in place and asks whether to create a backup of the new build. `BACKUP_ASK=0` in settings skips the question.

## Settings file

`~/.config/dwu/settings.conf`, plain shell variables. Defaults live in `templates/settings.conf`.

| Variable | Meaning |
| --- | --- |
| PALETTE | palette slug |
| FONT_TERM_FAMILY, FONT_TERM_SIZE | st font |
| FONT_UI_FAMILY, FONT_UI_SIZE | bar and dmenu font |
| FONT_ICON_FAMILY | symbols font, default Symbols Nerd Font Mono |
| XFT_DPI | set 144 or higher on HiDPI screens |
| WALLPAPER_MODE | solid or file |
| WALLPAPER_FILE | image path when mode is file |
| DISPLAY_MODE | extend, mirror or external |
| DISPLAY_LID_CLOSE_DISABLES_INTERNAL | 1 turns the laptop panel off when the lid is closed |
| PICOM_ENABLE, PICOM_BACKEND | backend auto, glx or xrender |
| PICOM_SHADOW, PICOM_SHADOW_RADIUS, PICOM_SHADOW_OPACITY | shadows |
| PICOM_BLUR, PICOM_BLUR_STRENGTH | dual kawase blur, glx only |
| PICOM_OPACITY_ACTIVE, PICOM_OPACITY_INACTIVE | window opacity |
| PICOM_CORNER_RADIUS | 0 keeps sharp corners |
| PICOM_FADE | fading |
| BACKUP_KEEP, BACKUP_ASK | backup retention and prompt |
| FIREFOX_CSS | 0 stops writing Firefox files |

## Commands

| Command | Purpose |
| --- | --- |
| dwu-settings | menu, `apply`, `palette SLUG`, `set KEY VALUE`, `fonts-default` |
| dwu-rebuild | compile and install |
| dwu-backup | `create`, `list`, `restore` |
| dwu-wallpaper | `apply`, `menu`, `solid`, `file PATH`, `url URL` |
| dwu-display | `apply`, `watch`, `menu` |
| dwu-power, dwu-lock, dwu-network, dwu-media, dwu-screenshot | menus and key actions |
| dwu-menu | menu behind the DWM label |
| dwu-bar | the whole status line for slstatus, modules come from `BAR_*` in settings.conf |
| dwu-weather | weather cache for the bar, `dwu-weather city Berlin` sets a fixed city |
| dwu-files | Thunar, or ranger when Thunar is missing |
| dwu-session | session entry point, exports XDG variables and starts dwm under dbus |

Outside X, or with `DWU_TTY=1`, dwu-settings uses a numbered text menu instead of dmenu.

## Fonts

`fonts/fonts.list` has the columns `category|label|kind|source`. Kind `nerd` downloads `<source>.zip` from Nerd Fonts v3.5.1, kind `url` downloads the given files. Fonts land in `~/.local/share/fonts/dwu`, the real family name is read with fc-scan after download. Categories: mono, display, hand. Handwriting fonts such as IM Fell English and Caveat fit the claret palette.

## Picom

`dwu-settings` then Picom edits the variables and restarts picom. On virtual machines the auto backend picks xrender, turns blur and vsync off and disables damage tracking. Force glx with `PICOM_BACKEND=glx`. The config uses the classic option names, which picom 9 to 12 accept.

## Monitors

`autostart.sh` runs `dwu-display watch`, which listens for RandR events with xev and re-applies the layout when the set of connected outputs or the lid state changes. New outputs go to the right of the previous one. dwm picks up the geometry through Xinerama.

## Patches

Edit `<tool>/patches.h`, then `dwu-rebuild <tool>`. The matching settings block in `config.h` appears in `config.def.h`, copy the variables you need. Enabled patches with links are in `PATCHES.md`.

## Firefox

The installer and `dwu-settings apply` write `chrome/userChrome.css`, `chrome/userContent.css` and `user.js` into every profile found, including snap and flatpak paths. `user.js` sets `toolkit.legacyUserProfileCustomizations.stylesheets`. Restart Firefox after a palette change.

## Backups

Each backup is a tar.gz of the source tree (without objects and .git) and `~/.config/dwu` in `~/.local/share/dwu/backups`. `dwu-backup restore` extracts it and tells you to run `dwu-rebuild all`.

## Uninstall

`install.sh --sections uninstall` removes binaries, scripts, the session entry and the touchpad file. Settings and sources stay.
