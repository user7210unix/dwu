#!/usr/bin/env bash
# DWU installer, run with: curl -fsSL https://raw.githubusercontent.com/user7210unix/dwm/main/install.sh | bash
set -u

REPO_URL="${DWU_REPO:-https://github.com/user7210unix/dwm}"
BRANCH="${DWU_BRANCH:-main}"
SELF_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
	SELF_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
fi
# run from a checkout (./install.sh)? then that checkout is the source of truth,
# never a second clone in ~/.local/src that can be stale or missing scripts/
if [ -z "${DWU_SRC:-}" ] && [ -n "$SELF_DIR" ] && [ -d "$SELF_DIR/dwm" ] && [ -d "$SELF_DIR/scripts" ]; then
	DWU_SRC="$SELF_DIR"
fi
DWU_SRC="${DWU_SRC:-$HOME/.local/src/dwu}"
export DWU_PREFIX="${DWU_PREFIX:-/usr/local}"
XSESSION_DIR=/usr/share/xsessions
XORG_CONF_DIR=/etc/X11/xorg.conf.d
AUTOSTART_DIR="$HOME/.local/share/dwm"
ASSUME_YES=0
DISTRO=""
SECTIONS=""

C_ACCENT=$'\033[38;2;165;111;99m'
C_TEXT=$'\033[38;2;217;155;127m'
C_DIM=$'\033[2m'
C_RESET=$'\033[0m'

splash() {
	printf '%s' "$C_ACCENT"
	cat <<'ART'

   ____  __        __ _   _
  |  _ \ \ \      / /| | | |
  | | | | \ \ /\ / / | | | |
  | |_| |  \ V  V /  | |_| |
  |____/    \_/\_/    \___/

ART
	printf '%s  dwm for user7210unix, st, dmenu, slstatus, picom%s\n' "$C_TEXT" "$C_RESET"
	printf '%s  nine palettes, nerd fonts, one command%s\n\n' "$C_DIM" "$C_RESET"
}

say()  { printf '%s>%s %s\n' "$C_ACCENT" "$C_RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$C_TEXT" "$C_RESET" "$*" >&2; }
die()  { warn "$*"; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

ask_yes() {
	[ "$ASSUME_YES" = 1 ] && return 0
	local answer
	read -r -p "$1 [Y/n] " answer < /dev/tty
	[[ ! "$answer" =~ ^[nN] ]]
}

as_root() {
	if [ "$(id -u)" = 0 ]; then "$@"
	elif have sudo; then sudo "$@"
	elif have doas; then doas "$@"
	else die "need root: install sudo or doas"
	fi
}

detect_distro() {
	[ -n "$DISTRO" ] && return
	case "$(uname -s)" in
		FreeBSD|DragonFly) DISTRO=freebsd; return ;;
		Linux) ;;
		*) die "unsupported system: $(uname -s)" ;;
	esac
	local id like
	id="$(. /etc/os-release && printf '%s' "${ID:-}")"
	like="$(. /etc/os-release && printf '%s' "${ID_LIKE:-}")"
	case " $id $like " in
		*" arch "*|*" cachyos "*|*" manjaro "*|*" endeavouros "*) DISTRO=arch ;;
		*" debian "*|*" ubuntu "*|*" pop "*|*" linuxmint "*) DISTRO=debian ;;
		*" fedora "*|*" rhel "*) DISTRO=fedora ;;
		*" void "*) DISTRO=void ;;
		*" gentoo "*) DISTRO=gentoo ;;
		*) die "unknown distro '$id', pass --distro arch|debian|fedora|void|gentoo|freebsd" ;;
	esac
}

is_ubuntu_family() { grep -qiE 'ubuntu|pop|mint' /etc/os-release 2>/dev/null; }

packages_for() {
	case "$DISTRO" in
	arch)
		echo base-devel git libx11 libxft libxinerama libxrender libxcursor freetype2 fontconfig \
			xorg-server xorg-xinit xorg-xrandr xorg-xrdb xorg-xsetroot xorg-xev xorg-xset xdotool \
			picom dunst feh maim xclip brightnessctl playerctl networkmanager network-manager-applet \
			pipewire pipewire-pulse wireplumber ranger curl unzip xss-lock slock libnotify polkit-gnome firefox zsh \
			thunar thunar-archive-plugin thunar-volman gvfs tumbler xarchiver xsettingsd adwaita-icon-theme iw wireless_tools ;;
	debian)
		echo build-essential git pkg-config libx11-dev libxft-dev libxinerama-dev libxrender-dev libxcursor-dev \
			libfreetype-dev libfontconfig1-dev xorg xinit x11-xserver-utils x11-utils xdotool picom dunst feh maim \
			xclip brightnessctl playerctl network-manager network-manager-gnome pipewire-pulse wireplumber ranger \
			curl unzip xss-lock i3lock libnotify-bin policykit-1-gnome dbus-x11 zsh \
			thunar thunar-archive-plugin thunar-volman gvfs gvfs-backends tumbler xarchiver xsettingsd adwaita-icon-theme iw wireless-tools
		if is_ubuntu_family; then echo firefox; else echo firefox-esr; fi ;;
	fedora)
		echo @development-tools git gcc make pkgconf-pkg-config libX11-devel libXft-devel libXinerama-devel \
			libXrender-devel libXcursor-devel freetype-devel fontconfig-devel xorg-x11-server-Xorg xorg-x11-xinit \
			xorg-x11-server-utils xorg-x11-utils xdotool picom dunst feh maim xclip brightnessctl playerctl \
			NetworkManager network-manager-applet pipewire-pulseaudio wireplumber ranger curl unzip xss-lock slock \
			libnotify polkit-gnome firefox zsh \
			Thunar thunar-archive-plugin thunar-volman gvfs tumbler xarchiver xsettingsd adwaita-icon-theme iw wireless-tools ;;
	void)
		echo base-devel git pkg-config libX11-devel libXft-devel libXinerama-devel libXrender-devel libXcursor-devel \
			freetype-devel fontconfig-devel xorg-minimal xinit xrandr xrdb xsetroot xev xset xdotool picom dunst feh \
			maim xclip brightnessctl playerctl NetworkManager network-manager-applet pipewire wireplumber ranger curl \
			unzip xss-lock slock libnotify polkit-gnome dbus elogind firefox zsh \
			Thunar thunar-archive-plugin thunar-volman gvfs tumbler xarchiver xsettingsd adwaita-icon-theme iw wireless_tools ;;
	gentoo)
		echo dev-vcs/git x11-libs/libX11 x11-libs/libXft x11-libs/libXinerama x11-libs/libXrender x11-libs/libXcursor \
			media-libs/freetype media-libs/fontconfig x11-base/xorg-server x11-apps/xinit x11-apps/xrandr \
			x11-apps/xrdb x11-apps/xsetroot x11-apps/xev x11-apps/xset x11-misc/xdotool x11-misc/picom x11-misc/dunst \
			media-gfx/feh media-gfx/maim x11-misc/xclip app-misc/brightnessctl media-sound/playerctl \
			net-misc/networkmanager gnome-extra/nm-applet media-video/pipewire media-video/wireplumber app-misc/ranger \
			net-misc/curl app-arch/unzip x11-misc/xss-lock x11-misc/slock x11-libs/libnotify www-client/firefox-bin app-shells/zsh \
			xfce-base/thunar xfce-extra/thunar-archive-plugin xfce-extra/thunar-volman gnome-base/gvfs xfce-extra/tumbler \
			app-arch/xarchiver x11-misc/xsettingsd x11-themes/adwaita-icon-theme net-wireless/iw ;;
	freebsd)
		echo git gmake pkgconf libX11 libXft libXinerama libXrender libXcursor freetype2 fontconfig xorg xdotool \
			picom dunst feh maim xclip playerctl ranger curl unzip slock i3lock libnotify firefox zsh \
			thunar thunar-archive-plugin gvfs tumbler xarchiver xsettingsd adwaita-icon-theme ;;
	esac
}

install_each() {
	local failed=() pkg
	for pkg in "$@"; do
		"$INSTALL_ONE" "$pkg" >/dev/null 2>&1 || failed+=("$pkg")
	done
	[ "${#failed[@]}" -eq 0 ] || warn "not installed, check the names on your release: ${failed[*]}"
}

section_deps() {
	detect_distro
	say "installing dependencies for $DISTRO"
	local packages yes_flag=""
	read -r -a packages <<< "$(packages_for)"
	case "$DISTRO" in
		arch)
			as_root pacman -Syu --needed --noconfirm "${packages[@]}" || {
				INSTALL_ONE() { as_root pacman -S --needed --noconfirm "$1"; }; install_each "${packages[@]}"; } ;;
		debian)
			as_root apt-get update
			as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}" || {
				INSTALL_ONE() { as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$1"; }; install_each "${packages[@]}"; } ;;
		fedora)
			as_root dnf install -y --skip-unavailable "${packages[@]}" ;;
		void)
			as_root xbps-install -Sy "${packages[@]}" || {
				INSTALL_ONE() { as_root xbps-install -y "$1"; }; install_each "${packages[@]}"; } ;;
		gentoo)
			[ "$ASSUME_YES" = 1 ] && yes_flag="--ask=n"
			as_root emerge --noreplace --quiet-build $yes_flag "${packages[@]}" || {
				INSTALL_ONE() { as_root emerge --noreplace --quiet-build --ask=n "$1"; }; install_each "${packages[@]}"; } ;;
		freebsd)
			as_root pkg install -y "${packages[@]}" ;;
	esac
}

source_ok() { [ -x "$1/scripts/dwu-rebuild" ] && [ -x "$1/scripts/dwu-settings" ] && [ -d "$1/dwm" ]; }

section_source() {
	[ -n "${SOURCE_CHECKED:-}" ] && return 0
	mkdir -p "$(dirname "$DWU_SRC")"
	if [ -d "$DWU_SRC/.git" ] && [ "$DWU_SRC" != "${SELF_DIR:-}" ]; then
		have git || die "git is missing, run the deps section first"
		say "updating $DWU_SRC"
		git -C "$DWU_SRC" pull --ff-only || warn "pull failed, keeping the local checkout"
	elif [ -d "$DWU_SRC/dwm" ]; then
		say "using sources in $DWU_SRC"
	else
		have git || die "git is missing, run the deps section first"
		say "cloning $REPO_URL into $DWU_SRC"
		git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$DWU_SRC" || die "clone failed"
	fi
	if ! source_ok "$DWU_SRC"; then
		chmod +x "$DWU_SRC"/scripts/* 2>/dev/null || true
		source_ok "$DWU_SRC" || die "$DWU_SRC has no scripts/dwu-rebuild or scripts/dwu-settings (stale checkout?). Run install.sh from your repo directory or remove $DWU_SRC"
	fi
	SOURCE_CHECKED=1
}

link_scripts() {
	local script found=0
	as_root mkdir -p "$DWU_PREFIX/bin"
	for script in "$DWU_SRC"/scripts/dwu-*; do
		[ -f "$script" ] || continue
		found=1
		chmod +x "$script"
		as_root ln -sf "$script" "$DWU_PREFIX/bin/$(basename "$script")"
	done
	[ "$found" = 1 ] || die "no dwu-* scripts found in $DWU_SRC/scripts"
	mkdir -p "$AUTOSTART_DIR"
	chmod +x "$DWU_SRC/scripts/autostart.sh" "$DWU_SRC/scripts/autostart_blocking.sh" 2>/dev/null || true
	ln -sf "$DWU_SRC/scripts/autostart.sh" "$AUTOSTART_DIR/autostart.sh"
	ln -sf "$DWU_SRC/scripts/autostart_blocking.sh" "$AUTOSTART_DIR/autostart_blocking.sh"
	case ":$PATH:" in *":$DWU_PREFIX/bin:"*) ;; *) warn "$DWU_PREFIX/bin is not in your PATH, dwu-session adds it for the X session" ;; esac
}

section_build() {
	section_source
	link_scripts
	export PATH="$DWU_PREFIX/bin:$PATH"
	"$DWU_SRC/scripts/dwu-settings" apply || true
	"$DWU_SRC/scripts/dwu-rebuild" all --no-backup || die "build failed"
}

section_fonts() {
	section_source
	link_scripts
	export PATH="$DWU_PREFIX/bin:$PATH"
	say "installing JetBrains Mono Nerd Font, Inter and Nerd symbols"
	"$DWU_SRC/scripts/dwu-settings" fonts-default
	"$DWU_SRC/scripts/dwu-rebuild" dwm --no-backup
}

section_session() {
	section_source
	if [ -d "$XSESSION_DIR" ] || as_root mkdir -p "$XSESSION_DIR"; then
		as_root tee "$XSESSION_DIR/dwu.desktop" >/dev/null <<DESKTOP
[Desktop Entry]
Name=DWU
Comment=dwm build by user7210unix
Exec=dwu-session
Type=Application
DESKTOP
	fi
	write_xinitrc
	if have xdg-mime && [ -f /usr/share/applications/thunar.desktop ]; then
		xdg-mime default thunar.desktop inode/directory 2>/dev/null || true
	fi
}

# startx must reach dwu-session, otherwise dwm starts without PATH and settings
write_xinitrc() {
	local rc="$HOME/.xinitrc"
	if [ -f "$rc" ] && grep -q 'dwu-session' "$rc"; then
		return 0
	fi
	if [ -f "$rc" ]; then
		if ask_yes "~/.xinitrc does not start dwu-session. Replace it? (old one is saved as ~/.xinitrc.dwu-backup)"; then
			cp "$rc" "$rc.dwu-backup"
		else
			say "not changed, make sure your ~/.xinitrc ends with: exec dwu-session"
			return 0
		fi
	fi
	printf 'exec dwu-session\n' > "$rc"
	say "wrote ~/.xinitrc, start with startx"
}

ZSH_PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dwu/zsh/plugins"
ZSH_PLUGINS="zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting zsh-users/zsh-completions zsh-users/zsh-history-substring-search"

section_zsh() {
	section_source
	have zsh || { detect_distro; warn "zsh is not installed, run the deps section first"; return 0; }
	have git || die "git is missing, run the deps section first"
	local conf="${XDG_CONFIG_HOME:-$HOME/.config}/dwu" zsh_bin repo name marker="# >>> dwu zsh >>>"
	mkdir -p "$ZSH_PLUGIN_DIR" "$conf"
	say "installing zsh plugins"
	for repo in $ZSH_PLUGINS; do
		name="${repo#*/}"
		if [ -d "$ZSH_PLUGIN_DIR/$name/.git" ]; then
			git -C "$ZSH_PLUGIN_DIR/$name" pull --ff-only -q || warn "could not update $name"
		else
			git clone --depth 1 -q "https://github.com/$repo" "$ZSH_PLUGIN_DIR/$name" || warn "could not clone $name"
		fi
	done
	cp "$DWU_SRC/templates/zshrc" "$conf/zshrc"
	touch "$HOME/.zshrc"
	if ! grep -qF "$marker" "$HOME/.zshrc"; then
		[ -s "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.dwu-backup" && say "old ~/.zshrc saved as ~/.zshrc.dwu-backup"
		printf '%s\n[ -f "%s/zshrc" ] && . "%s/zshrc"\n# <<< dwu zsh <<<\n' "$marker" "$conf" "$conf" >> "$HOME/.zshrc"
	fi
	zsh_bin="$(command -v zsh)"
	grep -qxF "$zsh_bin" /etc/shells 2>/dev/null || echo "$zsh_bin" | as_root tee -a /etc/shells >/dev/null
	if [ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$zsh_bin" ]; then
		say "setting zsh as your default shell"
		as_root chsh -s "$zsh_bin" "$(id -un)" || warn "chsh failed, run: chsh -s $zsh_bin"
	fi
	say "zsh ready, log out and in again (or run: exec zsh)"
}

section_firefox() {
	section_source
	link_scripts
	export PATH="$DWU_PREFIX/bin:$PATH"
	"$DWU_SRC/scripts/dwu-settings" apply
	say "Firefox CSS written to every profile found, restart Firefox"
}

enable_service() {
	local name="$1"
	if have systemctl && [ -d /run/systemd/system ]; then as_root systemctl enable --now "$name" 2>/dev/null
	elif [ -d /etc/sv ] && [ -d "/etc/sv/$name" ]; then as_root ln -sf "/etc/sv/$name" /var/service/ 2>/dev/null
	elif have rc-update; then as_root rc-update add "$name" default 2>/dev/null
	fi
}

section_laptop() {
	detect_distro
	say "laptop tweaks, touchpad, power, network"
	if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
		case "$DISTRO" in
			arch) as_root pacman -S --needed --noconfirm tlp ;;
			debian) as_root apt-get install -y tlp ;;
			fedora) as_root dnf install -y tlp ;;
			void) as_root xbps-install -y tlp ;;
			gentoo) as_root emerge --noreplace app-laptop/tlp ;;
		esac
		enable_service tlp
	else
		say "no battery found, skipping tlp"
	fi
	enable_service NetworkManager
	enable_service dbus
	as_root mkdir -p "$XORG_CONF_DIR"
	as_root tee "$XORG_CONF_DIR/40-dwu-touchpad.conf" >/dev/null <<'CONF'
Section "InputClass"
    Identifier "dwu touchpad"
    MatchIsTouchpad "on"
    MatchDriver "libinput"
    Option "Tapping" "on"
    Option "TappingButtonMap" "lrm"
    Option "NaturalScrolling" "on"
    Option "DisableWhileTyping" "on"
    Option "ClickMethod" "clickfinger"
EndSection
CONF
}

section_uninstall() {
	section_source
	local tool script
	for tool in dwm st dmenu slstatus; do
		( cd "$DWU_SRC/$tool" && as_root make PREFIX="$DWU_PREFIX" uninstall ) 2>/dev/null
	done
	for script in "$DWU_SRC"/scripts/dwu-*; do as_root rm -f "$DWU_PREFIX/bin/$(basename "$script")"; done
	as_root rm -f "$XSESSION_DIR/dwu.desktop" "$XORG_CONF_DIR/40-dwu-touchpad.conf"
	rm -f "$AUTOSTART_DIR/autostart.sh" "$AUTOSTART_DIR/autostart_blocking.sh"
	say "removed binaries and session entry, settings stay in ~/.config/dwu and sources in $DWU_SRC"
}

run_section() {
	case "$1" in
		deps) section_deps ;;
		build) section_build ;;
		fonts) section_fonts ;;
		session) section_session ;;
		firefox) section_firefox ;;
		zsh) section_zsh ;;
		laptop) section_laptop ;;
		uninstall) section_uninstall ;;
		*) warn "unknown section: $1" ;;
	esac
}

menu() {
	cat <<'MENU'
  1  deps      packages for your distribution
  2  build     clone, compile and install dwm, st, dmenu, slstatus
  3  fonts     JetBrains Mono Nerd Font, Inter, Nerd symbols
  4  session   login manager entry and ~/.xinitrc
  5  firefox   userChrome.css and user.js in every profile
  6  laptop    touchpad, tlp, NetworkManager
  7  uninstall remove binaries and session entry
  8  zsh       zsh with plugins and prompt, set as default shell

MENU
	local answer part
	read -r -p "choose sections, comma separated, Enter for 1,2,3,4,5,8 " answer < /dev/tty
	[ -n "$answer" ] || answer="1,2,3,4,5,8"
	for part in ${answer//,/ }; do
		case "$part" in
			1) SECTIONS+=" deps" ;; 2) SECTIONS+=" build" ;; 3) SECTIONS+=" fonts" ;;
			4) SECTIONS+=" session" ;; 5) SECTIONS+=" firefox" ;; 6) SECTIONS+=" laptop" ;;
			7) SECTIONS+=" uninstall" ;; 8) SECTIONS+=" zsh" ;;
		esac
	done
}

usage() {
	cat <<TXT
usage: install.sh [--all] [--yes] [--distro NAME] [--sections a,b,c] [--prefix DIR] [--src DIR]
sections: deps build fonts session firefox zsh laptop uninstall
example: curl -fsSL https://raw.githubusercontent.com/user7210unix/dwm/main/install.sh | bash -s -- --all --yes
TXT
}

while [ $# -gt 0 ]; do
	case "$1" in
		--all) SECTIONS="deps build fonts session firefox zsh" ;;
		--yes|-y) ASSUME_YES=1 ;;
		--distro) DISTRO="${2:?distro}"; shift ;;
		--sections) SECTIONS="${2//,/ }"; shift ;;
		--prefix) DWU_PREFIX="${2:?dir}"; export DWU_PREFIX; shift ;;
		--src) DWU_SRC="${2:?dir}"; shift ;;
		-h|--help) usage; exit 0 ;;
		*) usage; exit 1 ;;
	esac
	shift
done

splash
[ "$(id -u)" = 0 ] && warn "running as root, files in \$HOME will belong to root, run as your user instead"
[ -n "$SECTIONS" ] || menu
for section in $SECTIONS; do
	run_section "$section"
done
say "done. log out and pick DWU in your session list, or run: startx"
say "settings: Super+s    keybinds: Super+F1    docs: $DWU_SRC/DOC.md"
