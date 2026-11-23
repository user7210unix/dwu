#!/bin/sh
# Runs every time dwm starts, including seamless restarts, so each program is
# only launched when it is not already running.
config="${XDG_CONFIG_HOME:-$HOME/.config}/dwu"
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

once() { # once <process name> [command...]
	name="$1"; shift
	[ $# -gt 0 ] || set -- "$name"
	command -v "$1" >/dev/null 2>&1 || return 0
	pgrep -x "$name" >/dev/null 2>&1 && return 0
	"$@" >/dev/null 2>&1 &
}

[ -f "$config/picom.conf" ] && once picom picom --config "$config/picom.conf" -b
once dunst
once slstatus
# scripts show up as "bash" in the process list, so match their command line
if command -v curl >/dev/null 2>&1 && ! pgrep -f "dwu-weather daemon" >/dev/null 2>&1; then
	dwu-weather daemon >/dev/null 2>&1 &
fi
once xsettingsd xsettingsd -c "${XDG_CONFIG_HOME:-$HOME/.config}/xsettingsd/xsettingsd.conf"
once nm-applet
once blueman-applet
once xss-lock xss-lock -l -- dwu-lock

for agent in /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
             /usr/libexec/polkit-gnome-authentication-agent-1 \
             /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 \
             /usr/lib/polkit-kde-authentication-agent-1 \
             /usr/libexec/lxqt-policykit-agent; do
	if [ -x "$agent" ]; then
		pgrep -f "$agent" >/dev/null 2>&1 || "$agent" >/dev/null 2>&1 &
		break
	fi
done

pgrep -f "dwu-display watch" >/dev/null 2>&1 || dwu-display watch >/dev/null 2>&1 &
dwu-wallpaper apply >/dev/null 2>&1 &
