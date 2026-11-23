#!/bin/sh
config="${XDG_CONFIG_HOME:-$HOME/.config}/dwu"
[ -f "$config/Xresources" ] && xrdb -merge "$config/Xresources"
xset -b
xset r rate 250 40
xset s 600 10
xset dpms 0 0 900
dwu-display apply
