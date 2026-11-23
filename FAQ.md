# FAQ

## The bar is black or has no transparency

The bar uses an alpha visual and needs a compositor. Check `pgrep picom`. In a VM keep `PICOM_BACKEND=auto`, it selects xrender.

## picom fails to start

Run `picom --config ~/.config/dwu/picom.conf` in a terminal and read the error. Try `dwu-settings set PICOM_BACKEND xrender`. On old picom versions turn off blur.

## dwu-bar: command not found, or build failed with "No such file"

`~/.local/src/dwu` was an old clone without `scripts/`. Run `./install.sh` from your checkout (it now uses that directory), or delete `~/.local/src/dwu`. Then check `ls -l /usr/local/bin/dwu-*` and restart the session.

## Icons show as boxes

The Nerd symbols font is missing. Run `dwu-settings fonts-default`, then `fc-list | grep -i symbols`. Then run `dwu-settings apply`, the bar restarts by itself.

## Colors do not change in the bar

xdotool must be installed, dwu-settings uses it to trigger the reload. Manual fallback: Super + Shift + F5.

## The font change did not reach the bar

Run `dwu-settings apply`. dwm reads `~/.config/dwu/dwm.rc` on every start, so a font, palette or gap change never needs a rebuild. If it still looks default, check that `~/.config/dwu/dwm.rc` exists.

## Firefox ignores the CSS

Start Firefox once so the profile exists, run `dwu-settings apply`, restart Firefox. Check `about:config` for `toolkit.legacyUserProfileCustomizations.stylesheets` set to true. The CSS is written against Firefox 150, internal selectors can change between releases.

## Second monitor stays off

Run `dwu-display apply` and read the output. `xrandr` must list the output as connected. With a closed lid and `DISPLAY_LID_CLOSE_DISABLES_INTERNAL=1` the laptop panel is off on purpose.

## Brightness or volume keys do nothing

Install brightnessctl and either wireplumber (wpctl) or pulseaudio utils (pactl). Your user needs the video group for brightnessctl on some distributions unless udev rules from the package apply.

## Lock screen does nothing

Install slock or i3lock. Debian based systems get i3lock from the installer.

## How do I add a patch

Set the flag to 1 in `dwm/patches.h`, copy needed variables from `dwm/config.def.h` into `config.h`, run `dwu-rebuild dwm`.

## How do I change a keybind

Edit the `keys[]` array in `dwm/config.h`, run `dwu-rebuild dwm`. Modifiers are named constants at the top of the file.

## Where is the wallpaper

The default is the palette background color. Put images in `~/Pictures`, then `dwu-settings` and Wallpaper, or `dwu-wallpaper file PATH`, or `dwu-wallpaper url URL`.

## Can I go back to an older build

`dwu-backup list`, then `dwu-backup restore NAME`, then `dwu-rebuild all`.
