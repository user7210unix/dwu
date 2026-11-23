#!/usr/bin/env bash

DWU_SRC="${DWU_SRC:-$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)}"
DWU_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dwu"
DWU_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dwu"
DWU_SETTINGS="$DWU_CONF_DIR/settings.conf"
DWU_FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/dwu"
DWU_PREFIX="${DWU_PREFIX:-/usr/local}"
DWU_TOOLS=(dwm st dmenu slstatus)
DWU_ICON_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/NerdFontsSymbolsOnly.zip"
DWU_NERD_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1"
DWU_DMENU_LINES=14

mkdir -p "$DWU_CONF_DIR" "$DWU_DATA_DIR"

log()  { printf '%s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

notify() {
	if have notify-send && [ -n "${DISPLAY:-}" ]; then
		notify-send -a dwu "$@" 2>/dev/null || log "$*"
	else
		log "$*"
	fi
}

load_settings() {
	[ -f "$DWU_SETTINGS" ] || cp "$DWU_SRC/templates/settings.conf" "$DWU_SETTINGS"
	# shellcheck disable=SC1090
	. "$DWU_SRC/templates/settings.conf"
	# shellcheck disable=SC1090
	. "$DWU_SETTINGS"
}

save_setting() {
	local key="$1" value="$2"
	if grep -q "^${key}=" "$DWU_SETTINGS" 2>/dev/null; then
		sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$DWU_SETTINGS"
	else
		printf '%s="%s"\n' "$key" "$value" >> "$DWU_SETTINGS"
	fi
}

use_dmenu() {
	[ -n "${DISPLAY:-}" ] && [ -z "${DWU_TTY:-}" ] && have dmenu
}

pick() {
	local prompt="$1" items choice
	items="$(cat)"
	if use_dmenu; then
		printf '%s\n' "$items" | dmenu -l "$DWU_DMENU_LINES" -p "$prompt"
	else
		local IFS=$'\n' options
		read -r -d '' -a options <<< "$items" || true
		PS3="$prompt > "
		select choice in "${options[@]}"; do
			[ -n "$choice" ] && { printf '%s\n' "$choice"; return 0; }
		done < /dev/tty
	fi
}

ask_text() {
	local prompt="$1" answer
	if use_dmenu; then
		answer="$(printf '' | dmenu -p "$prompt")" || return 1
	else
		read -r -p "$prompt: " answer < /dev/tty || return 1
	fi
	printf '%s\n' "$answer"
}

confirm() {
	local prompt="$1" default="${2:-y}" answer
	if use_dmenu; then
		answer="$(printf 'yes\nno\n' | dmenu -p "$prompt")"
		[ "$answer" = yes ]
		return
	fi
	if [ "$default" = y ]; then
		read -r -p "$prompt [Y/n] " answer < /dev/tty
		[[ ! "$answer" =~ ^[nN] ]]
	else
		read -r -p "$prompt [y/N] " answer < /dev/tty
		[[ "$answer" =~ ^[yY] ]]
	fi
}

# menu entries are "<nerd icon>  Label"; this returns just Label
strip_icon() { printf '%s' "${1#*  }"; }

palette_list() {
	local f
	for f in "$DWU_SRC"/palettes/*.palette; do
		( . "$f"; printf '%s|%s\n' "$PALETTE_SLUG" "$PALETTE_NAME" )
	done
}

load_palette() {
	local file="$DWU_SRC/palettes/$1.palette"
	[ -f "$file" ] || { log "unknown palette: $1"; return 1; }
	# shellcheck disable=SC1090
	. "$file"
}

is_virtual_machine() {
	if have systemd-detect-virt && systemd-detect-virt -q 2>/dev/null; then
		return 0
	fi
	grep -qiE 'virtualbox|vmware|qemu|kvm|virtual|bochs|xen|parallels' \
		/sys/class/dmi/id/product_name /sys/class/dmi/id/sys_vendor 2>/dev/null
}

is_laptop() {
	compgen -G "/sys/class/power_supply/BAT*" >/dev/null
}

font_pattern() {
	local family="$1" size="$2"
	printf '%s:size=%s:antialias=true:autohint=true' "$family" "$size"
}

write_xresources() {
	local out="$DWU_CONF_DIR/Xresources" i
	local term_font ui_font
	term_font="$(font_pattern "$FONT_TERM_FAMILY" "$FONT_TERM_SIZE")"
	ui_font="$(font_pattern "$FONT_UI_FAMILY" "$FONT_UI_SIZE")"
	{
		printf 'Xft.dpi: %s\nXft.antialias: 1\nXft.hinting: 1\nXft.hintstyle: hintslight\nXft.rgba: rgb\n' "$XFT_DPI"
		printf 'st.font: %s\nst.alpha: 0.92\nst.background: %s\nst.foreground: %s\nst.cursorColor: %s\n' \
			"$term_font" "$PALETTE_BG" "$PALETTE_FG" "$PALETTE_ACCENT"
		for i in "${!PALETTE_ANSI[@]}"; do
			printf 'st.color%s: %s\n*.color%s: %s\n' "$i" "${PALETTE_ANSI[$i]}" "$i" "${PALETTE_ANSI[$i]}"
		done
		printf 'dmenu.font: %s, %s\n' "$ui_font" "$(font_pattern "$FONT_ICON_FAMILY" "$FONT_ICON_SIZE")"
		printf 'dmenu.background: %s\ndmenu.foreground: %s\n' "$PALETTE_BG" "$PALETTE_FG"
		printf 'dmenu.selbackground: %s\ndmenu.selforeground: %s\n' "$PALETTE_SELECT" "$PALETTE_FG"
		printf 'dmenu.bordercolor: %s\n' "$PALETTE_ACCENT"
		printf 'dmenu.hlbackground: %s\ndmenu.hlforeground: %s\n' "$PALETTE_BG" "$PALETTE_ACCENT"
		printf 'dmenu.selhlbackground: %s\ndmenu.selhlforeground: %s\n' "$PALETTE_SELECT" "$PALETTE_FG"
		printf 'dmenu.outbackground: %s\ndmenu.outforeground: %s\n' "$PALETTE_SURFACE" "$PALETTE_FG"
		dwm_colors | while read -r name value; do printf 'dwm.%s: %s\n' "$name" "$value"; done
	} > "$out"
}

# one "name value" pair per line, shared by Xresources and dwm.rc
dwm_colors() {
	cat <<COLORS
normfgcolor $PALETTE_DIM
normbgcolor $PALETTE_BG
normbordercolor $PALETTE_SURFACE
normfloatcolor $PALETTE_ACCENT
selfgcolor $PALETTE_FG
selbgcolor $PALETTE_SELECT
selbordercolor $PALETTE_ACCENT
selfloatcolor $PALETTE_FG
titlenormfgcolor $PALETTE_DIM
titlenormbgcolor $PALETTE_BG
titlenormbordercolor $PALETTE_SURFACE
titlenormfloatcolor $PALETTE_ACCENT
titleselfgcolor $PALETTE_FG
titleselbgcolor $PALETTE_BG
titleselbordercolor $PALETTE_ACCENT
titleselfloatcolor $PALETTE_FG
tagsnormfgcolor $PALETTE_DIM
tagsnormbgcolor $PALETTE_BG
tagsnormbordercolor $PALETTE_SURFACE
tagsnormfloatcolor $PALETTE_ACCENT
tagsselfgcolor $PALETTE_FG
tagsselbgcolor $PALETTE_SELECT
tagsselbordercolor $PALETTE_ACCENT
tagsselfloatcolor $PALETTE_FG
hidnormfgcolor $PALETTE_DIM
hidselfgcolor $PALETTE_FG
hidnormbgcolor $PALETTE_BG
hidselbgcolor $PALETTE_BG
urgfgcolor $PALETTE_BG
urgbgcolor $PALETTE_URGENT
urgbordercolor $PALETTE_URGENT
urgfloatcolor $PALETTE_URGENT
COLORS
}

# the file dwm reads on every start (see dwm/patch/dwu_config.c), no recompile needed
write_dwm_rc() {
	local out="$DWU_CONF_DIR/dwm.rc" i top=1 vpad=8 spad=12 gap="$DWM_GAPS" smart=1 brand=""
	[ "$DWM_BAR_POSITION" = bottom ] && top=0
	[ "$DWM_BAR_STYLE" = flush ] && { vpad=0; spad=0; }
	[ "$DWM_SMARTGAPS" = 1 ] && smart=0
	if [ "$DWM_BRAND_SHOW" = 1 ]; then
		brand="$DWM_BRAND_ICON"
		[ -n "$DWM_BRAND_TEXT" ] && brand="${brand:+$brand  }$DWM_BRAND_TEXT"
	fi
	{
		printf 'topbar=%s\nshowbar=%s\nborderpx=%s\nbar_height=%s\nvertpad=%s\nsidepad=%s\n' \
			"$top" "$DWM_BAR_VISIBLE" "$DWM_BORDER" "$DWM_BAR_HEIGHT" "$vpad" "$spad"
		printf 'gappih=%s\ngappiv=%s\ngappoh=%s\ngappov=%s\nsmartgaps_fact=%s\n' "$gap" "$gap" "$gap" "$gap" "$smart"
		printf 'showsystray=%s\nalpha=%s\nbrand=%s\n' "$DWM_SYSTRAY" "$DWM_BAR_ALPHA" "$brand"
		printf 'font_ui=%s\nfont_icons=%s\n' \
			"$(font_pattern "$FONT_UI_FAMILY" "$FONT_UI_SIZE")" "$(font_pattern "$FONT_ICON_FAMILY" "$FONT_ICON_SIZE")"
		printf 'font_brand=%s:slant=italic:weight=bold:size=%s:antialias=true\n' "$FONT_UI_FAMILY" "$FONT_BRAND_SIZE"
		printf 'font_brand_icons=%s\n' "$(font_pattern "$FONT_ICON_FAMILY" "$FONT_BRAND_SIZE")"
		dwm_colors | while read -r name value; do printf '%s=%s\n' "$name" "$value"; done
		for i in "${!PALETTE_ANSI[@]}"; do printf 'color%s=%s\n' "$i" "${PALETTE_ANSI[$i]}"; done
	} > "$out"
}

# 0 for dark backgrounds, 1 for light ones
palette_is_light() {
	local hex="${PALETTE_BG#\#}"
	[ $(( (0x${hex:0:2} * 299 + 0x${hex:2:2} * 587 + 0x${hex:4:2} * 114) / 1000 )) -gt 140 ]
}

subst_palette() {
	sed -e "s|@BG@|$PALETTE_BG|g" -e "s|@SURFACE@|$PALETTE_SURFACE|g" -e "s|@SELECT@|$PALETTE_SELECT|g" \
		-e "s|@ACCENT@|$PALETTE_ACCENT|g" -e "s|@FG@|$PALETTE_FG|g" -e "s|@DIM@|$PALETTE_DIM|g" \
		-e "s|@URGENT@|$PALETTE_URGENT|g" -e "s|@GREEN@|${PALETTE_ANSI[2]}|g" \
		-e "s|@FONT@|$FONT_UI_FAMILY|g" -e "s|@FONT_SIZE@|$FONT_UI_SIZE|g" "$@"
}

icon_theme() {
	local t
	for t in Papirus-Dark Papirus Adwaita; do
		[ -d "/usr/share/icons/$t" ] || [ -d "$HOME/.local/share/icons/$t" ] && { printf '%s' "$t"; return; }
	done
	printf 'Adwaita'
}

# fonts, colors and a minimal look for every GTK app (Thunar and friends)
write_gtk() {
	[ "$GTK_STYLE" = 1 ] || return 0
	local cfg="${XDG_CONFIG_HOME:-$HOME/.config}" dark=1 icons dpi
	palette_is_light && dark=0
	icons="$(icon_theme)"
	mkdir -p "$cfg/gtk-3.0" "$cfg/gtk-4.0" "$cfg/fontconfig/conf.d"
	local settings
	settings="[Settings]
gtk-font-name=$FONT_UI_FAMILY $FONT_UI_SIZE
gtk-theme-name=Adwaita
gtk-icon-theme-name=$icons
gtk-application-prefer-dark-theme=$dark
gtk-decoration-layout=:
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-enable-animations=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb"
	printf '%s\n' "$settings" > "$cfg/gtk-3.0/settings.ini"
	printf '%s\n' "$settings" > "$cfg/gtk-4.0/settings.ini"
	subst_palette "$DWU_SRC/templates/gtk3.css" > "$cfg/gtk-3.0/gtk.css"
	subst_palette "$DWU_SRC/templates/gtk4.css" > "$cfg/gtk-4.0/gtk.css"
	printf 'gtk-font-name="%s %s"\ngtk-icon-theme-name="%s"\ngtk-theme-name="Adwaita"\n' \
		"$FONT_UI_FAMILY" "$FONT_UI_SIZE" "$icons" > "$HOME/.gtkrc-2.0"

	# fontconfig: the chosen fonts become the system wide sans-serif and monospace
	{
		printf '<?xml version="1.0"?>\n<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n<fontconfig>\n'
		printf '  <alias binding="same"><family>sans-serif</family><prefer><family>%s</family></prefer></alias>\n' "$FONT_UI_FAMILY"
		printf '  <alias binding="same"><family>system-ui</family><prefer><family>%s</family></prefer></alias>\n' "$FONT_UI_FAMILY"
		[ "$FONT_TERM_FAMILY" = monospace ] || \
			printf '  <alias binding="same"><family>monospace</family><prefer><family>%s</family></prefer></alias>\n' "$FONT_TERM_FAMILY"
		printf '</fontconfig>\n'
	} > "$cfg/fontconfig/conf.d/60-dwu.conf"

	# xsettingsd pushes the same values into running GTK apps
	dpi=$(( XFT_DPI * 1024 ))
	mkdir -p "$cfg/xsettingsd"
	cat > "$cfg/xsettingsd/xsettingsd.conf" <<XS
Net/ThemeName "Adwaita"
Net/IconThemeName "$icons"
Gtk/FontName "$FONT_UI_FAMILY $FONT_UI_SIZE"
Gtk/DecorationLayout ":"
Xft/DPI $dpi
Xft/Antialias 1
Xft/Hinting 1
Xft/HintStyle "hintslight"
Xft/RGBA "rgb"
XS
}

# minimal Thunar: no menubar, details view, no clutter in the sidebar, terminal action
write_thunar() {
	[ "$THUNAR_CONFIG" = 1 ] || return 0
	local cfg="${XDG_CONFIG_HOME:-$HOME/.config}" marker="$DWU_DATA_DIR/thunar-configured"
	[ -f "$marker" ] && return 0
	pgrep -x thunar >/dev/null 2>&1 && return 0
	mkdir -p "$cfg/Thunar" "$cfg/xfce4/xfconf/xfce-perchannel-xml"
	cp "$DWU_SRC/templates/thunar.xml" "$cfg/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
	[ -f "$cfg/Thunar/uca.xml" ] || cp "$DWU_SRC/templates/thunar-uca.xml" "$cfg/Thunar/uca.xml"
	[ -f "$cfg/Thunar/accels.scm" ] || cp "$DWU_SRC/templates/thunar-accels.scm" "$cfg/Thunar/accels.scm"
	touch "$marker"
}

write_picom() {
	local out="$DWU_CONF_DIR/picom.conf" backend="$PICOM_BACKEND" vsync blur shadow damage
	local radius="$PICOM_CORNER_RADIUS"
	if [ "$backend" = auto ]; then
		if is_virtual_machine; then backend=xrender; else backend=glx; fi
	fi
	vsync=true; [ "$PICOM_VSYNC" = 1 ] || vsync=false
	shadow=true; [ "$PICOM_SHADOW" = 1 ] || shadow=false
	blur="$PICOM_BLUR"; [ "$backend" = glx ] || blur=0
	damage=true; [ "$backend" = glx ] || damage=false
	if [ "$backend" = xrender ] && is_virtual_machine; then vsync=false; fi
	{
		printf 'backend = "%s";\nvsync = %s;\nuse-damage = %s;\n' "$backend" "$vsync" "$damage"
		printf 'detect-client-opacity = true;\ndetect-rounded-corners = true;\nmark-wmwin-focused = true;\nmark-ovredir-focused = false;\n'
		printf 'shadow = %s;\nshadow-radius = %s;\nshadow-opacity = %s;\nshadow-offset-x = -%s;\nshadow-offset-y = -%s;\n' \
			"$shadow" "$PICOM_SHADOW_RADIUS" "$PICOM_SHADOW_OPACITY" "$PICOM_SHADOW_RADIUS" "$PICOM_SHADOW_RADIUS"
		printf 'shadow-exclude = [\n  "class_g = '"'"'dwm'"'"'",\n  "class_g = '"'"'dmenu'"'"'",\n  "_NET_WM_WINDOW_TYPE@:32a *= '"'"'_NET_WM_WINDOW_TYPE_DOCK'"'"'",\n  "_NET_WM_WINDOW_TYPE@:32a *= '"'"'_NET_WM_WINDOW_TYPE_DESKTOP'"'"'",\n  "_GTK_FRAME_EXTENTS@:c"\n];\n'
		if [ "$PICOM_FADE" = 1 ]; then
			printf 'fading = true;\nfade-in-step = 0.06;\nfade-out-step = 0.06;\nfade-delta = 6;\n'
		else
			printf 'fading = false;\n'
		fi
		printf 'inactive-opacity = %s;\nactive-opacity = %s;\nframe-opacity = 1.0;\ninactive-opacity-override = false;\n' \
			"$PICOM_OPACITY_INACTIVE" "$PICOM_OPACITY_ACTIVE"
		printf 'opacity-rule = [\n  "100:class_g = '"'"'firefox'"'"' && fullscreen",\n  "100:class_g = '"'"'mpv'"'"'",\n  "100:class_g = '"'"'vlc'"'"'",\n  "100:class_g = '"'"'dmenu'"'"'",\n  "100:class_g = '"'"'dwm'"'"'",\n  "100:class_g = '"'"'St'"'"' && focused"\n];\n'
		printf 'corner-radius = %s;\nrounded-corners-exclude = [\n  "class_g = '"'"'dwm'"'"'",\n  "_NET_WM_WINDOW_TYPE@:32a *= '"'"'_NET_WM_WINDOW_TYPE_DOCK'"'"'"\n];\n' "$radius"
		if [ "$blur" = 1 ]; then
			printf 'blur-method = "dual_kawase";\nblur-strength = %s;\nblur-background-exclude = [\n  "window_type = '"'"'dock'"'"'",\n  "_GTK_FRAME_EXTENTS@:c"\n];\n' "$PICOM_BLUR_STRENGTH"
		fi
		printf 'wintypes:\n{\n  tooltip = { fade = true; shadow = false; opacity = 0.95; };\n  dock = { shadow = false; };\n  dnd = { shadow = false; };\n  popup_menu = { opacity = 1.0; };\n  dropdown_menu = { opacity = 1.0; };\n};\n'
	} > "$out"
}

restart_picom() {
	pkill -x picom 2>/dev/null || true
	[ "$PICOM_ENABLE" = 1 ] || return 0
	have picom || return 0
	sleep 0.3
	picom --config "$DWU_CONF_DIR/picom.conf" -b 2>/dev/null || log "picom failed, try PICOM_BACKEND=xrender"
}

write_dunst() {
	local dir="${XDG_CONFIG_HOME:-$HOME/.config}/dunst"
	mkdir -p "$dir"
	subst_palette "$DWU_SRC/templates/dunstrc" > "$dir/dunstrc"
}

firefox_profiles() {
	local base ini
	for base in "$HOME/.mozilla/firefox" "$HOME/.config/mozilla/firefox" "$HOME/snap/firefox/common/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"; do
		ini="$base/profiles.ini"
		[ -f "$ini" ] || continue
		awk -F= -v base="$base" '/^Path=/{print base "/" $2}' "$ini"
	done
}

write_firefox_css() {
	[ "$FIREFOX_CSS" = 1 ] || return 0
	local profile found=0 theme=0
	palette_is_light && theme=1
	while IFS= read -r profile; do
		[ -d "$profile" ] || continue
		found=1
		mkdir -p "$profile/chrome"
		subst_palette "$DWU_SRC/firefox/userChrome.css" > "$profile/chrome/userChrome.css"
		subst_palette "$DWU_SRC/firefox/userContent.css" > "$profile/chrome/userContent.css"
		sed "s|@TOOLBAR_THEME@|$theme|" "$DWU_SRC/firefox/user.js" > "$profile/user.js"
	done < <(firefox_profiles)
	[ "$found" = 1 ] || log "no Firefox profile found yet, start Firefox once and run: dwu-settings apply"
}

apply_all() {
	load_settings
	load_palette "$PALETTE" || return 1
	write_xresources
	write_dwm_rc
	write_picom
	write_dunst
	write_gtk
	write_thunar
	write_firefox_css
	[ -n "${DISPLAY:-}" ] || return 0
	have xrdb && xrdb -merge "$DWU_CONF_DIR/Xresources"
	pkill -USR1 -x st 2>/dev/null || true
	pkill -HUP -x xsettingsd 2>/dev/null || true
	pkill -HUP -x dwm 2>/dev/null || true
	restart_picom
	if pkill -x dunst 2>/dev/null; then { dunst >/dev/null 2>&1 & }; fi
	dwu-wallpaper apply 2>/dev/null || true
}

make_cmd() {
	if have gmake; then printf 'gmake'; else printf 'make'; fi
}

make_vars() {
	case "$(uname -s)" in
		FreeBSD|DragonFly) printf 'X11INC=/usr/local/include X11LIB=/usr/local/lib FREETYPEINC=/usr/local/include/freetype2' ;;
		OpenBSD) printf 'X11INC=/usr/X11R6/include X11LIB=/usr/X11R6/lib FREETYPEINC=/usr/X11R6/include/freetype2 KVMLIB=-lkvm' ;;
		NetBSD) printf 'X11INC=/usr/X11R7/include X11LIB=/usr/X11R7/lib FREETYPEINC=/usr/pkg/include/freetype2' ;;
		*) printf '' ;;
	esac
}

as_root() {
	if [ "$(id -u)" = 0 ]; then "$@"
	elif have sudo; then sudo "$@"
	elif have doas; then doas "$@"
	else log "need sudo or doas"; return 1
	fi
}
