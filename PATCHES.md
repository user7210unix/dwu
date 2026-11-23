# Patches
Patches are selected through `patches.h` in each tool directory. The sources come from the flexipatch trees by bakkeby, which merge the patches published on suckless.org so they combine without conflicts. Change a flag from 0 to 1, run `dwu-rebuild <tool>`.

## dwm
- `BAR_LAUNCHER_PATCH` Adds buttons to the bar that can be used to launch applications. https://dwm.suckless.org/patches/launcher/
- `BAR_LTSYMBOL_PATCH` Show layout symbol in bar
- `BAR_STATUS_PATCH` Show status in bar
- `BAR_STATUS2D_PATCH` Status2d allows colors and rectangle drawing in your dwm status bar. This patch is incompatible with the statuscolors patch which takes prec... https://dwm.suckless.org/patches/status2d/
- `BAR_STATUS2D_XRDB_TERMCOLORS_PATCH` Addition to the status2d patch that allows the use of terminal colors (color0 through color15) from xrdb in the status, allowing programs li... https://dwm.suckless.org/patches/status2d/
- `BAR_SYSTRAY_PATCH` The systray patch adds systray for the status bar. https://dwm.suckless.org/patches/systray/
- `BAR_TAGS_PATCH` Show tag symbols in the bar.
- `BAR_UNDERLINETAGS_PATCH` This patch underlines the selected tag, or optionally all tags. https://dwm.suckless.org/patches/underlinetags/
- `BAR_WINTITLE_PATCH` Show window title in bar
- `BAR_ALPHA_PATCH` The alpha patch adds transparency for the status bar. You need to uncomment the corresponding line in config.mk to use the -lXrender library... https://dwm.suckless.org/patches/alpha/
- `BAR_CENTEREDWINDOWNAME_PATCH` This patch centers the WM_NAME of the currently selected window on the status bar. This is compatible with the wintitle, bartabgroups, flexw... https://dwm.suckless.org/patches/centeredwindowname/
- `BAR_HEIGHT_PATCH` Allows the bar height to be explicitly set rather than being derived from font. https://dwm.suckless.org/patches/bar_height/
- `BAR_HIDEVACANTTAGS_PATCH` This patch prevents dwm from drawing tags with no clients (i.e. vacant) on the bar. https://dwm.suckless.org/patches/hide_vacant_tags/
- `BAR_PADDING_PATCH` This patch adds vertical and horizontal space between the statusbar and the edge of the screen. https://dwm.suckless.org/patches/barpadding/
- `ALWAYSCENTER_PATCH` All floating windows are centered, like the center patch, but without a rule. The center patch takes precedence over this patch. This patch ... https://dwm.suckless.org/patches/alwayscenter/
- `ATTACHBELOW_PATCH` This patch adds new clients below the selected client. This patch takes precedence over ATTACHBOTTOM_PATCH. https://dwm.suckless.org/patches/attachbelow/
- `AUTOSTART_PATCH` This patch will make dwm run "~/.local/share/dwm/autostart_blocking.sh" and "~/.local/share/dwm/autostart.sh &" before entering the handler ... https://dwm.suckless.org/patches/autostart/
- `CFACTS_PATCH` This patch provides the ability to assign different weights to clients in their respective stack in tiled layout. https://dwm.suckless.org/patches/cfacts/
- `CYCLELAYOUTS_PATCH` The cyclelayouts patch lets you cycle through all your layouts. https://dwm.suckless.org/patches/cyclelayouts/
- `FLOATPOS_PATCH` This patch adds a float rule allowing the size and position of floating windows to be specified It also allows the size and position of floa... https://github.com/bakkeby/patches/wiki/floatpos/
- `FOCUSMASTER_PATCH` A simple patch that just puts focus back to the master client. https://dwm.suckless.org/patches/focusmaster/
- `FOCUSURGENT_PATCH` Selects the next window having the urgent flag regardless of the tag it is on. The urgent flag can be artificially set with the following xd... https://dwm.suckless.org/patches/focusurgent/
- `FULLSCREEN_PATCH` Applies the monocle layout with the focused client on top and hides the bar. When pressed again it shows the bar and restores the layout tha... https://dwm.suckless.org/patches/fullscreen/
- `MOVESTACK_PATCH` This patch allows you to move clients around in the stack and swap them with the master. https://dwm.suckless.org/patches/movestack/
- `NOBORDER_PATCH` Removes the border when there is only one window visible. https://dwm.suckless.org/patches/noborder/
- `PERTAG_PATCH` The pertag patch adds nmaster, mfacts and layouts per tag rather than per monitor (default). https://dwm.suckless.org/patches/pertag/
- `RESTARTSIG_PATCH` Adds a keyboard shortcut to restart dwm or alternatively by using kill -HUP dwmpid. Additionally dwm can quit cleanly by using kill -TERM dw... https://dwm.suckless.org/patches/restartsig/
- `SAVEFLOATS_PATCH` This patch saves size and position of every floating window before it is forced into tiled mode. If the window is made floating again then t... https://dwm.suckless.org/patches/save_floats/
- `SCRATCHPADS_PATCH` The scratchpad patch allows you to spawn or restore floating terminal windows. It is typically useful when one need to do some short typing.... https://lists.suckless.org/hackers/2004/17205.html
- `SEAMLESS_RESTART_PATCH` This patch persists some settings across window manager restarts. These include but are not limited to: - client's assigned tag(s) on which ...
- `SHIFTVIEW_PATCH` This patch adds keybindings for left and right circular shift through tags. https://github.com/chau-bao-long/dotfiles/blob/master/suckless/dwm/shiftview.diff
- `VANITYGAPS_PATCH` This patch adds configurable gaps between windows differentiating between outer, inner, horizontal and vertical gaps. https://github.com/bakkeby/patches/blob/master/dwm/dwm-vanitygaps-6.2.diff
- `VANITYGAPS_MONOCLE_PATCH` This patch adds outer gaps for the monocle layout. Most gaps patches tries to avoid gaps on the monocle layout, as it is often used as a ful...
- `WARP_PATCH` This patch warps the mouse cursor to the center of the currently focused window or screen when the mouse cursor is (a) on a different screen... https://dwm.suckless.org/patches/warp/
- `XRDB_PATCH` Allows dwm to read colors from xrdb (.Xresources) during runtime. Compatible with the float border color, awesomebar, urgentborder and title... https://dwm.suckless.org/patches/xrdb/
- `CENTEREDMASTER_LAYOUT` Centered master layout. https://dwm.suckless.org/patches/centeredmaster/
- `DECK_LAYOUT` Deck layout. https://dwm.suckless.org/patches/deck/
- `FIBONACCI_SPIRAL_LAYOUT` Fibonacci spiral layout. https://dwm.suckless.org/patches/fibonacci/
- `GAPPLESSGRID_LAYOUT` Gappless grid layout. https://dwm.suckless.org/patches/gaplessgrid/
- `TILE_LAYOUT` The default tile layout. This can be optionally disabled in favour of other layouts.
- `MONOCLE_LAYOUT` Monocle layout (default). This can be optionally disabled in favour of other layouts.

## st
- `ALPHA_PATCH` The alpha patch adds transparency for the terminal. You need to uncomment the corresponding line in config.mk to use the -lXrender library w... https://st.suckless.org/patches/alpha/
- `ANYSIZE_SIMPLE_PATCH` A simple variant of the anysize patch that only changes the resize hints to allow the window to be resized to any size.
- `BLINKING_CURSOR_PATCH` This patch allows the use of a blinking cursor. Only cursor styles 0, 1, 3, 5, and 7 blink. Set cursorstyle accordingly. Cursor styles are d... https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h4-Functions-using-CSI-_-ordered-by-the-final-character-lparen-s-rparen:CSI-Ps-SP-q.1D81
- `BOLD_IS_NOT_BRIGHT_PATCH` By default bold text is rendered with a bold font in the bright variant of the current color. This patch makes bold text rendered simply as ... https://st.suckless.org/patches/bold-is-not-bright/
- `BOXDRAW_PATCH` This patch adds custom rendering of lines/blocks/braille characters for gapless alignment. https://st.suckless.org/patches/boxdraw/
- `CLIPBOARD_PATCH` By default st only sets PRIMARY on selection. This patch makes st set CLIPBOARD on selection. https://st.suckless.org/patches/clipboard/
- `FONT2_PATCH` This patch allows you to add spare font besides the default. Some glyphs can be not present in the default font. For this glyphs st uses fon... https://st.suckless.org/patches/font2/
- `NEWTERM_PATCH` This patch allows you to spawn a new st terminal using Ctrl-Shift-Return. It will have the same CWD (current working directory) as the origi... https://st.suckless.org/patches/newterm/
- `SCROLLBACK_PATCH` Scroll back through terminal output using Shift+{PageUp, PageDown}. https://st.suckless.org/patches/scrollback/
- `SCROLLBACK_MOUSE_PATCH` Scroll back through terminal output using Shift+MouseWheel. This variant depends on SCROLLBACK_PATCH being enabled. https://st.suckless.org/patches/scrollback/
- `SELECTION_COLORS_PATCH` This patch adds the two color-settings selectionfg and selectionbg to config.def.h. Those define the fore- and background colors which are u... https://st.suckless.org/patches/selectioncolors/
- `THEMED_CURSOR_PATCH` Instead of a default X cursor, use the xterm cursor from your cursor theme. You need to uncomment the corresponding line in config.mk to use... https://st.suckless.org/patches/themed_cursor/
- `UNDERCURL_PATCH` Adds support for special underlines. * Example test command: $ echo -e "\e[4:3m\e[58:5:10munderline\e[0m" ^ ^     ^ ^  ^- sets terminal colo... https://st.suckless.org/patches/undercurl/
- `VERTCENTER_PATCH` Vertically center lines in the space available if you have set a larger chscale in config.h https://st.suckless.org/patches/vertcenter/
- `XRESOURCES_PATCH` This patch adds the ability to configure st via Xresources. At startup, st will read and apply the resources named in the resources[] array ... https://st.suckless.org/patches/xresources/
- `XRESOURCES_RELOAD_PATCH` This patch adds the ability to reload the Xresources config when a SIGUSR1 signal is received e.g.: killall -USR1 st Depends on the XRESOURC...

## dmenu
- `ALPHA_PATCH` The alpha patch adds transparency for the dmenu window. You need to uncomment the corresponding line in config.mk to use the -lXrender libra... https://github.com/bakkeby/patches/blob/master/dmenu/dmenu-alpha-5.0_20210725_523aa08.diff
- `BORDER_PATCH` This patch adds a border around the dmenu window. It is intended to be used with the center or xyw patches, to make the menu stand out from ... http://tools.suckless.org/dmenu/patches/border/
- `CASEINSENSITIVE_PATCH` This patch makes dmenu case-insensitive by default, replacing the case-insensitive -i option with a case sensitive -s option. http://tools.suckless.org/dmenu/patches/case-insensitive/
- `CENTER_PATCH` This patch centers dmenu in the middle of the screen. https://tools.suckless.org/dmenu/patches/center/
- `FUZZYMATCH_PATCH` This patch adds support for fuzzy-matching to dmenu, allowing users to type non-consecutive portions of the string to be matched. https://tools.suckless.org/dmenu/patches/fuzzymatch/
- `HIGHLIGHT_PATCH` This patch highlights the individual characters of matched text for each dmenu list entry. If combined with the fuzzymatch patch then fuzzy ... https://tools.suckless.org/dmenu/patches/highlight/
- `INSTANT_PATCH` This patch adds a flag which will cause dmenu to select an item immediately if there is only one matching option left. https://tools.suckless.org/dmenu/patches/instant/
- `LINE_HEIGHT_PATCH` This patch adds a '-h' option which sets the minimum height of a dmenu line. This helps integrate dmenu with other UI elements that require ... http://tools.suckless.org/dmenu/patches/line-height/
- `MOUSE_SUPPORT_PATCH` This patch adds basic mouse support for dmenu. https://tools.suckless.org/dmenu/patches/mouse-support/
- `NUMBERS_PATCH` Adds text which displays the number of matched and total items in the top right corner of dmenu. https://tools.suckless.org/dmenu/patches/numbers/
- `XRESOURCES_PATCH` This patch adds the ability to configure dmenu via Xresources. At startup, dmenu will read and apply the resources named below: dmenu.font  ... https://tools.suckless.org/dmenu/patches/xresources/
