/* DWU dwm configuration, patches are selected in patches.h */

#include <X11/XF86keysym.h>
#include "colors.h"
#include "fonts.h"

#define MODKEY Mod4Mask
#define ALTKEY Mod1Mask
#define SHIFT  ShiftMask
#define CTRL   ControlMask

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
#define CMD(...)   { .v = (const char*[]){ __VA_ARGS__, NULL } }

#define BORDER_WIDTH        2
#define SNAP_DISTANCE       24
#define BAR_VERTICAL_PAD    8
#define BAR_SIDE_PAD        12
#define BAR_HEIGHT_FIXED    30
#define BAR_ALPHA_VALUE     0xe6
#define SYSTRAY_SPACING     6
#define GAP_INNER_H         10
#define GAP_INNER_V         10
#define GAP_OUTER_H         10
#define GAP_OUTER_V         10
#define SMARTGAPS_FACTOR    1
#define UNDERLINE_PAD       8
#define UNDERLINE_STROKE    2
#define MASTER_FACTOR       0.56
#define MASTER_COUNT        1
#define FLOATPOS_GRID_COLS  5
#define FLOATPOS_GRID_ROWS  5
#define FLOAT_STEP          "26"
#define MFACT_STEP          0.03
#define CFACT_STEP          0.20
#define REFRESH_RATE        120
#define SCRATCH_GEOMETRY    "110x30"

static unsigned int borderpx       = BORDER_WIDTH;
static unsigned int snap           = SNAP_DISTANCE;
static const int swallowfloating         = 0;
static unsigned int gappih         = GAP_INNER_H;
static unsigned int gappiv         = GAP_INNER_V;
static unsigned int gappoh         = GAP_OUTER_H;
static unsigned int gappov         = GAP_OUTER_V;
static int smartgaps_fact          = SMARTGAPS_FACTOR;
static const char autostartblocksh[]     = "autostart_blocking.sh";
static const char autostartsh[]          = "autostart.sh";
static const char dwmdir[]               = "dwm";
static const char localshare[]           = ".local/share";
static int showbar                 = 1;
static int topbar                  = 1;
static int bar_height              = BAR_HEIGHT_FIXED;
static int vertpad                 = BAR_VERTICAL_PAD;
static int sidepad                 = BAR_SIDE_PAD;
static int floatposgrid_x                = FLOATPOS_GRID_COLS;
static int floatposgrid_y                = FLOATPOS_GRID_ROWS;
static const int statusmon               = 'A';
static unsigned int systrayspacing = SYSTRAY_SPACING;
static int showsystray             = 1;
static unsigned int ulinepad       = UNDERLINE_PAD;
static unsigned int ulinestroke    = UNDERLINE_STROKE;
static const unsigned int ulinevoffset   = 0;
static int ulineall                = 0;
static const int ulinetop                = 0;
static int tagindicatortype              = INDICATOR_NONE;
static int tiledindicatortype            = INDICATOR_NONE;
static int floatindicatortype            = INDICATOR_TOP_LEFT_SQUARE;

static const char *fonts[]               = { DWU_FONT_UI, DWU_FONT_ICONS };
static const char *brandfont[]           = { DWU_FONT_BRAND, DWU_FONT_ICONS };
static const char dmenufont[]            = DWU_FONT_UI;

static char c000000[]                    = "#000000";
static char normfgcolor[]                = DWU_DIM;
static char normbgcolor[]                = DWU_BG;
static char normbordercolor[]            = DWU_SURFACE;
static char normfloatcolor[]             = DWU_ACCENT;
static char selfgcolor[]                 = DWU_FG;
static char selbgcolor[]                 = DWU_SELECT;
static char selbordercolor[]             = DWU_ACCENT;
static char selfloatcolor[]              = DWU_FG;
static char titlenormfgcolor[]           = DWU_DIM;
static char titlenormbgcolor[]           = DWU_BG;
static char titlenormbordercolor[]       = DWU_SURFACE;
static char titlenormfloatcolor[]        = DWU_ACCENT;
static char titleselfgcolor[]            = DWU_FG;
static char titleselbgcolor[]            = DWU_BG;
static char titleselbordercolor[]        = DWU_ACCENT;
static char titleselfloatcolor[]         = DWU_FG;
static char tagsnormfgcolor[]            = DWU_DIM;
static char tagsnormbgcolor[]            = DWU_BG;
static char tagsnormbordercolor[]        = DWU_SURFACE;
static char tagsnormfloatcolor[]         = DWU_ACCENT;
static char tagsselfgcolor[]             = DWU_FG;
static char tagsselbgcolor[]             = DWU_SELECT;
static char tagsselbordercolor[]         = DWU_ACCENT;
static char tagsselfloatcolor[]          = DWU_FG;
static char hidnormfgcolor[]             = DWU_DIM;
static char hidselfgcolor[]              = DWU_FG;
static char hidnormbgcolor[]             = DWU_BG;
static char hidselbgcolor[]              = DWU_BG;
static char urgfgcolor[]                 = DWU_BG;
static char urgbgcolor[]                 = DWU_URGENT;
static char urgbordercolor[]             = DWU_URGENT;
static char urgfloatcolor[]              = DWU_URGENT;

static const unsigned int baralpha       = BAR_ALPHA_VALUE;
static const unsigned int borderalpha    = OPAQUE;
static unsigned int alphas[][3] = {
	[SchemeNorm]      = { OPAQUE, baralpha, borderalpha },
	[SchemeSel]       = { OPAQUE, baralpha, borderalpha },
	[SchemeTitleNorm] = { OPAQUE, baralpha, borderalpha },
	[SchemeTitleSel]  = { OPAQUE, baralpha, borderalpha },
	[SchemeTagsNorm]  = { OPAQUE, baralpha, borderalpha },
	[SchemeTagsSel]   = { OPAQUE, baralpha, borderalpha },
	[SchemeHidNorm]   = { OPAQUE, baralpha, borderalpha },
	[SchemeHidSel]    = { OPAQUE, baralpha, borderalpha },
	[SchemeUrg]       = { OPAQUE, baralpha, borderalpha },
};

static char *colors[][ColCount] = {
	[SchemeNorm]      = { normfgcolor,      normbgcolor,      normbordercolor,      normfloatcolor },
	[SchemeSel]       = { selfgcolor,       selbgcolor,       selbordercolor,       selfloatcolor },
	[SchemeTitleNorm] = { titlenormfgcolor, titlenormbgcolor, titlenormbordercolor, titlenormfloatcolor },
	[SchemeTitleSel]  = { titleselfgcolor,  titleselbgcolor,  titleselbordercolor,  titleselfloatcolor },
	[SchemeTagsNorm]  = { tagsnormfgcolor,  tagsnormbgcolor,  tagsnormbordercolor,  tagsnormfloatcolor },
	[SchemeTagsSel]   = { tagsselfgcolor,   tagsselbgcolor,   tagsselbordercolor,   tagsselfloatcolor },
	[SchemeHidNorm]   = { hidnormfgcolor,   hidnormbgcolor,   c000000,              c000000 },
	[SchemeHidSel]    = { hidselfgcolor,    hidselbgcolor,    c000000,              c000000 },
	[SchemeUrg]       = { urgfgcolor,       urgbgcolor,       urgbordercolor,       urgfloatcolor },
};

static Launcher launchers[] = {
	{ "\uf120  DWM", CMD("dwu-menu") },
};

const char *spcmd1[] = { "st", "-n", "spterm", "-g", SCRATCH_GEOMETRY, NULL };
static Sp scratchpads[] = {
	{ "spterm", spcmd1 },
};

static char *tagicons[][NUMTAGS] = {
	[DEFAULT_TAGS] = { "\uf0ac", "\uf121", "\uf120", "\uf15c", "\uf086", "\uf001", "\uf07b", "\uf108", "\uf013" },
};

static const Rule rules[] = {
	RULE(.wintype = WTYPE "DIALOG",  .isfloating = 1)
	RULE(.wintype = WTYPE "UTILITY", .isfloating = 1)
	RULE(.wintype = WTYPE "TOOLBAR", .isfloating = 1)
	RULE(.wintype = WTYPE "SPLASH",  .isfloating = 1)
	RULE(.class = "firefox",          .tags = 1 << 0)
	RULE(.class = "Pavucontrol",      .isfloating = 1)
	RULE(.class = "Nm-connection-editor", .isfloating = 1)
	RULE(.class = "KeePassXC",        .isfloating = 1)
	RULE(.class = "Blueman-manager",  .isfloating = 1)
	RULE(.instance = "spterm",        .tags = SPTAG(0), .isfloating = 1)
};

static const BarRule barrules[] = {
	{ -1,        0, BAR_ALIGN_LEFT,  width_launcher,  draw_launcher,  click_launcher,  NULL, "launcher" },
	{ -1,        0, BAR_ALIGN_LEFT,  width_tags,      draw_tags,      click_tags,      hover_tags, "tags" },
	{  0,        0, BAR_ALIGN_RIGHT, width_systray,   draw_systray,   click_systray,   NULL, "systray" },
	{ -1,        0, BAR_ALIGN_LEFT,  width_ltsymbol,  draw_ltsymbol,  click_ltsymbol,  NULL, "layout" },
	{ statusmon, 0, BAR_ALIGN_RIGHT, width_status2d,  draw_status2d,  click_status2d,  NULL, "status2d" },
	{ -1,        0, BAR_ALIGN_NONE,  width_wintitle,  draw_wintitle,  click_wintitle,  NULL, "wintitle" },
};

static const float mfact     = MASTER_FACTOR;
static const int nmaster     = MASTER_COUNT;
static const int resizehints = 0;
static const int lockfullscreen = 1;
static const int refreshrate = REFRESH_RATE;

static const Layout layouts[] = {
	{ "\uf009", tile },
	{ "\uf2d0", NULL },
	{ "\uf24d", monocle },
	{ "\uf0c9", centeredmaster },
	{ "\uf0db", deck },
	{ "\uf1ce", spiral },
	{ "\uf00a", gaplessgrid },
};

static char dmenumon[8] = "0";
static const char *dmenucmd[]  = { "dmenu_run", "-m", dmenumon, "-p", "run", NULL };
static const char *termcmd[]   = { "st", NULL };
static const char *browsercmd[] = { "firefox", NULL };
static const char *filescmd[]  = { "dwu-files", NULL };

#define TAGKEYS(KEY, TAG) \
	{ MODKEY,              KEY, view,       {.ui = 1 << TAG} }, \
	{ MODKEY|CTRL,         KEY, toggleview, {.ui = 1 << TAG} }, \
	{ MODKEY|SHIFT,        KEY, tag,        {.ui = 1 << TAG} }, \
	{ MODKEY|CTRL|SHIFT,   KEY, toggletag,  {.ui = 1 << TAG} },

static const Key keys[] = {
	{ MODKEY,              XK_space,        spawn,          {.v = dmenucmd } },
	{ MODKEY,              XK_p,            spawn,          {.v = dmenucmd } },
	{ MODKEY,              XK_Return,       spawn,          {.v = termcmd } },
	{ MODKEY,              XK_w,            spawn,          {.v = browsercmd } },
	{ MODKEY,              XK_e,            spawn,          {.v = filescmd } },
	{ MODKEY,              XK_s,            spawn,          CMD("dwu-settings") },
	{ MODKEY|SHIFT,        XK_e,            spawn,          CMD("dwu-power") },
	{ MODKEY|SHIFT,        XK_x,            spawn,          CMD("dwu-lock") },
	{ MODKEY,              XK_n,            spawn,          CMD("dwu-network") },
	{ MODKEY,              XK_F1,           spawn,          CMD("dwu-help") },
	{ MODKEY,              XK_F8,           spawn,          CMD("dwu-display") },
	{ 0,                   XK_Print,        spawn,          CMD("dwu-screenshot") },
	{ SHIFT,               XK_Print,        spawn,          CMD("dwu-screenshot", "area") },

	{ 0, XF86XK_AudioRaiseVolume,  spawn, CMD("dwu-media", "volume-up") },
	{ 0, XF86XK_AudioLowerVolume,  spawn, CMD("dwu-media", "volume-down") },
	{ 0, XF86XK_AudioMute,         spawn, CMD("dwu-media", "volume-mute") },
	{ 0, XF86XK_AudioMicMute,      spawn, CMD("dwu-media", "mic-mute") },
	{ 0, XF86XK_AudioPlay,         spawn, CMD("dwu-media", "play-pause") },
	{ 0, XF86XK_AudioNext,         spawn, CMD("dwu-media", "next") },
	{ 0, XF86XK_AudioPrev,         spawn, CMD("dwu-media", "previous") },
	{ 0, XF86XK_MonBrightnessUp,   spawn, CMD("dwu-media", "brightness-up") },
	{ 0, XF86XK_MonBrightnessDown, spawn, CMD("dwu-media", "brightness-down") },

	{ MODKEY,              XK_b,            togglebar,      {0} },
	{ MODKEY,              XK_j,            focusstack,     {.i = +1 } },
	{ MODKEY,              XK_k,            focusstack,     {.i = -1 } },
	{ MODKEY|SHIFT,        XK_j,            movestack,      {.i = +1 } },
	{ MODKEY|SHIFT,        XK_k,            movestack,      {.i = -1 } },
	{ MODKEY|CTRL,         XK_space,        focusmaster,    {0} },
	{ MODKEY,              XK_i,            incnmaster,     {.i = +1 } },
	{ MODKEY,              XK_o,            incnmaster,     {.i = -1 } },
	{ MODKEY,              XK_h,            setmfact,       {.f = -MFACT_STEP} },
	{ MODKEY,              XK_l,            setmfact,       {.f = +MFACT_STEP} },
	{ MODKEY|SHIFT,        XK_h,            setcfact,       {.f = +CFACT_STEP} },
	{ MODKEY|SHIFT,        XK_l,            setcfact,       {.f = -CFACT_STEP} },
	{ MODKEY|SHIFT,        XK_o,            setcfact,       {0} },
	{ MODKEY|SHIFT,        XK_Return,       zoom,           {0} },
	{ MODKEY,              XK_minus,        incrgaps,       {.i = -1 } },
	{ MODKEY,              XK_equal,        incrgaps,       {.i = +1 } },
	{ MODKEY,              XK_g,            togglegaps,     {0} },
	{ MODKEY|SHIFT,        XK_g,            defaultgaps,    {0} },
	{ MODKEY,              XK_Tab,          view,           {0} },
	{ MODKEY,              XK_bracketleft,  shiftview,      {.i = -1 } },
	{ MODKEY,              XK_bracketright, shiftview,      {.i = +1 } },
	{ MODKEY,              XK_q,            killclient,     {0} },
	{ MODKEY|SHIFT,        XK_c,            killclient,     {0} },
	{ MODKEY|SHIFT,        XK_r,            quit,           {1} },
	{ MODKEY|CTRL|SHIFT,   XK_q,            quit,           {0} },
	{ MODKEY,              XK_u,            focusurgent,    {0} },
	{ MODKEY|SHIFT,        XK_F5,           xrdb,           {.v = NULL } },
	{ MODKEY,              XK_t,            setlayout,      {.v = &layouts[0]} },
	{ MODKEY,              XK_f,            fullscreen,     {0} },
	{ MODKEY,              XK_m,            setlayout,      {.v = &layouts[2]} },
	{ MODKEY,              XK_c,            setlayout,      {.v = &layouts[3]} },
	{ MODKEY,              XK_y,            setlayout,      {.v = &layouts[4]} },
	{ MODKEY,              XK_r,            setlayout,      {.v = &layouts[5]} },
	{ MODKEY|CTRL,         XK_comma,        cyclelayout,    {.i = -1 } },
	{ MODKEY|CTRL,         XK_period,       cyclelayout,    {.i = +1 } },
	{ MODKEY|SHIFT,        XK_space,        togglefloating, {0} },
	{ MODKEY,              XK_grave,        togglescratch,  {.ui = 0 } },
	{ MODKEY,              XK_0,            view,           {.ui = ~SPTAGMASK } },
	{ MODKEY|SHIFT,        XK_0,            tag,            {.ui = ~SPTAGMASK } },
	{ MODKEY,              XK_comma,        focusmon,       {.i = -1 } },
	{ MODKEY,              XK_period,       focusmon,       {.i = +1 } },
	{ MODKEY|SHIFT,        XK_comma,        tagmon,         {.i = -1 } },
	{ MODKEY|SHIFT,        XK_period,       tagmon,         {.i = +1 } },
	{ MODKEY|ALTKEY,       XK_h,            floatpos,       {.v = "-" FLOAT_STEP "x   0y" } },
	{ MODKEY|ALTKEY,       XK_l,            floatpos,       {.v = " " FLOAT_STEP "x   0y" } },
	{ MODKEY|ALTKEY,       XK_k,            floatpos,       {.v = "  0x -" FLOAT_STEP "y" } },
	{ MODKEY|ALTKEY,       XK_j,            floatpos,       {.v = "  0x  " FLOAT_STEP "y" } },
	{ MODKEY|ALTKEY|SHIFT, XK_h,            floatpos,       {.v = "-" FLOAT_STEP "w   0h" } },
	{ MODKEY|ALTKEY|SHIFT, XK_l,            floatpos,       {.v = " " FLOAT_STEP "w   0h" } },
	{ MODKEY|ALTKEY|SHIFT, XK_k,            floatpos,       {.v = "  0w -" FLOAT_STEP "h" } },
	{ MODKEY|ALTKEY|SHIFT, XK_j,            floatpos,       {.v = "  0w  " FLOAT_STEP "h" } },
	TAGKEYS(XK_1, 0)
	TAGKEYS(XK_2, 1)
	TAGKEYS(XK_3, 2)
	TAGKEYS(XK_4, 3)
	TAGKEYS(XK_5, 4)
	TAGKEYS(XK_6, 5)
	TAGKEYS(XK_7, 6)
	TAGKEYS(XK_8, 7)
	TAGKEYS(XK_9, 8)
};

static const Button buttons[] = {
	{ ClkLtSymbol,   0,      Button1, setlayout,      {0} },
	{ ClkLtSymbol,   0,      Button3, setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,   0,      Button2, zoom,           {0} },
	{ ClkStatusText, 0,      Button2, spawn,          {.v = termcmd } },
	{ ClkClientWin,  MODKEY, Button1, movemouse,      {0} },
	{ ClkClientWin,  MODKEY, Button2, togglefloating, {0} },
	{ ClkClientWin,  MODKEY, Button3, resizemouse,    {0} },
	{ ClkTagBar,     0,      Button1, view,           {0} },
	{ ClkTagBar,     0,      Button3, toggleview,     {0} },
	{ ClkTagBar,     MODKEY, Button1, tag,            {0} },
	{ ClkTagBar,     MODKEY, Button3, toggletag,      {0} },
};
