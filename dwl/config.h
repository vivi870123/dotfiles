#define BROWSER "org.mozilla.firefox"
#define TERMINAL "footclient"

#define SUPER WLR_MODIFIER_LOGO
#define ALT WLR_MODIFIER_ALT
#define SHIFT WLR_MODIFIER_SHIFT
#define CTRL WLR_MODIFIER_CTRL
#define CAPS WLR_MODIFIER_MOD3

/* appearance */
static const int sloppyfocus               = 0;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const float bordercolor[]           = {0.5, 0.5, 0.5, 1.0};
static const float focuscolor[]            = {1.0, 0.0, 0.0, 1.0};

static const unsigned int borderpx         = 3;  /* border pixel of windows */

static const unsigned int gappih           = 15; /* horiz inner gap between windows */
static const unsigned int gappiv           = 10; /* vert inner gap between windows */
static const unsigned int gappoh           = 10; /* horiz outer gap between windows and screen edge */
static const unsigned int gappov           = 15; /* vert outer gap between windows and screen edge */
static const unsigned int default_gapps    = 0;  /* second state of gapp size */

static const int smartgaps                 = 1;  /* 1 means no outer gap when there is only one window */
static const int monoclegaps               = 0;  /* 1 means outer gaps in monocle layout */

/* To conform the xdg-protocol, set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.1, 0.1, 0.1, 1.0};


/* Autostart */
static const char *const autostart[] = {
  "dunst", NULL,
  "pacman", "-Sy", NULL,
  "wbg", "/home/chris/.local/share/bg", NULL,
  "pipewire", NULL,
  "gammastep", NULL,
  "wl-paste", "--watch", "clipman", "store", NULL,
  "foot", "--server", NULL,
  "someblocks", "-m", "-1", NULL,
  NULL /* terminate */
};

/* tagging - tagcount must be no greater than 31 */
#define TAGCOUNT (9)
static const int tagcount = TAGCOUNT;

static const Rule rules[] = {
  /* app_id     title       tags mask     isfloating  isterm  noswallow  monitor scratchkey */
  { "firefox",  NULL,       1 << 8,       0,          0,      1,         -1,      0 },
  { "foot",     NULL,       0,            0,          1,      1,         -1,      0 },
  { NULL,       "sp0",      0,            1,          1,      1,         -1,      's'},
  { NULL,       "sp1",      0,            1,          1,      1,         -1,      't'},
};

/* layout(s) */
static const Layout layouts[] = {
  /* symbol     arrange function */
  { "[]=",      tile },
  { "TTT",      bstack },

  { "[@]",      spiral },
  { "[\\]",      dwindle },

  { "[D]",      deck },
  { "[M]",      monocle },

  { "|M|",      centeredmaster },
  /* { "===",      bstackhoriz }, */

  { "><>",      NULL },    /* no layout function means floating behavior */
  { NULL,       NULL },
};

/* monitors */
static const MonitorRule monrules[] = {
  { NULL,       0.55, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
  /* can specify fields: rules, model, layout, variant, options */
  .layout = "gb",
  .options = "ctrl:nocaps",
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 1;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const int cursor_timeout = 5;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

#define TAGKEYS(KEY,TAG) \
  { SUPER,        KEY,    view,         {.ui = 1 << TAG} }, \
  { SUPER|CTRL,   KEY,    toggleview,   {.ui = 1 << TAG} }, \
  { SUPER|SHIFT,  KEY,    tag,          {.ui = 1 << TAG} }, \
  { SUPER|CTRL,   KEY,    toggletag,    {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "kitty", NULL };
static const char *menucmd[] = { "bemenu-run", NULL };

/* named scratchpads - First arg only serves to match against key in rules*/
static const char *scratchpadcmd0[] = { "s", TERMINAL, "-T", "sp0", NULL };
static const char *scratchpadcmd1[] = { "t", TERMINAL, "-T", "sp1", NULL };

#include "shiftview.c"
#include "keys.h"
static const Key keys[] = {
  /* Note that Shift changes certain key codes: c -> C, 2 -> at, etc. */
  /* modifier           key                     function        argument */
  { SUPER,              Key_j,                  focusstack,     {.i = +1} },
  { SUPER,              Key_k,                  focusstack,     {.i = -1} },
  { SUPER|SHIFT,        Key_j,                  movestack,      {.i = +1} },
  { SUPER|SHIFT,        Key_k,                  movestack,      {.i = -1} },
  { SUPER,              Key_grave,              spawn,          SHCMD("bemenuunicode") },

  TAGKEYS(              Key_1,                                  0),
  TAGKEYS(              Key_2,                                  1),
  TAGKEYS(              Key_3,                                  2),
  TAGKEYS(              Key_4,                                  3),
  TAGKEYS(              Key_5,                                  4),
  TAGKEYS(              Key_6,                                  5),
  TAGKEYS(              Key_7,                                  6),
  TAGKEYS(              Key_8,                                  7),
  TAGKEYS(              Key_9,                                  8),

  { SUPER,		Key_0,		        view,		{.ui = ~0 } },
  { SUPER|SHIFT,	Key_0,		        tag,		{.ui = ~0 } },
  { SUPER,		Key_minus,	        spawn,		SHCMD("pamixer -d 5; kill -44 $(pidof someblocks)") },
  { SUPER|SHIFT,        Key_minus,	        spawn,		SHCMD("pamixer -d 15; kill -44 $(pidof someblocks)") },
  { SUPER,		Key_equal,	        spawn,		SHCMD("pamixer -i 5; kill -44 $(pidof someblocks)") },
  { SUPER|SHIFT,	Key_equal,	        spawn,		SHCMD("pamixer -i 15; kill -44 $(pidof someblocks)") },
  { SUPER,		Key_BackSpace,	        spawn,		SHCMD("sysact") },
  { SUPER|SHIFT,	Key_BackSpace,	        spawn,		SHCMD("sysact") },

  { SUPER,              Key_Tab,                view,           {0} },
  { SUPER,              Key_q,                  killclient,     {0} },
  { SUPER|SHIFT,        Key_q,		        spawn,		SHCMD("sysact") },
  { SUPER,		Key_w,		        spawn,		SHCMD(BROWSER) },
  { SUPER|SHIFT,	Key_w,		        spawn,		SHCMD("networkmanager_dmenu") },
  { SUPER,		Key_e,		        spawn,		SHCMD(TERMINAL " -e neomutt ; pkill -RTMIN+12 someblocks; rmdir ~/.abook 2>/dev/null") },
  { SUPER|SHIFT,	Key_e,		        spawn,		SHCMD(TERMINAL " -e abook -C ~/.config/abook/abookrc --datafile ~/.config/abook/addressbook") },
  { SUPER,		Key_r,		        spawn,		SHCMD(TERMINAL " -e lf") },
  { SUPER|SHIFT,	Key_r,		        spawn,		SHCMD(TERMINAL " -e htop") },

  { SUPER,		Key_t,		        setlayout,	{.v = &layouts[0]} }, /* tile */
  { SUPER|SHIFT,	Key_t,		        setlayout,	{.v = &layouts[1]} }, /* bstack */
  { SUPER,		Key_y,		        setlayout,	{.v = &layouts[2]} }, /* spiral */
  { SUPER|SHIFT,	Key_y,		        setlayout,	{.v = &layouts[3]} }, /* dwindle */
  { SUPER,		Key_u,		        setlayout,	{.v = &layouts[4]} }, /* deck */
  { SUPER|SHIFT,	Key_u,		        setlayout,	{.v = &layouts[5]} }, /* monocle */
  { SUPER,              Key_i,		        setlayout,	{.v = &layouts[6]} }, /* centeredmaster */
  { SUPER|SHIFT,	Key_i,		        setlayout,	{.v = &layouts[7]} }, /* centeredfloatingmaster */
  { SUPER,              Key_o,                  incnmaster,     {.i = +1} },
  { SUPER|SHIFT,        Key_o,                  incnmaster,     {.i = -1} },
  { SUPER|CTRL,         Key_comma,              cyclelayout,    {.i = -1 } },
  { SUPER|CTRL,         Key_period,             cyclelayout,    {.i = +1 } },
  { SUPER,		Key_p,			spawn,		SHCMD("mpc toggle") },
  { SUPER|SHIFT,	Key_p,			spawn,		SHCMD("mpc pause; pauseallmpv") },
  { SUPER,		Key_bracketleft,	spawn,		SHCMD("mpc seek -10") },
  { SUPER|SHIFT,	Key_bracketleft,	spawn,		SHCMD("mpc seek -60") },
  { SUPER,		Key_bracketright,	spawn,		SHCMD("mpc seek +10") },
  { SUPER|SHIFT,	Key_bracketright,	spawn,		SHCMD("mpc seek +60") },
  { SUPER,		Key_backslash,		view,		{0} },

  { SUPER,		Key_a,		        togglegaps,	{0} },
  { SUPER|SHIFT,	Key_a,		        defaultgaps,	{0} },
  { SUPER,		Key_s,		        togglesticky,	{0} },
  { SUPER,		Key_d,		        spawn,          SHCMD("bemenu-run") },
  { SUPER|SHIFT,	Key_d,		        spawn,		SHCMD("passmenu") },
  { SUPER,              Key_f,                  togglefullscreen, {0} },
  { SUPER,		Key_h,		        setmfact,	{.f = -0.05} },
  { SUPER,		Key_l,		        setmfact,      	{.f = +0.05} },
  { SUPER,		Key_g,		        shiftview,	{ .i = -1 } },
  { SUPER,		Key_semicolon,	        shiftview,	{ .i = 1 } },

  { SUPER,		Key_apostrophe,	        togglescratch,	{.v = scratchpadcmd0} },
  { SUPER,		Key_Return,	        spawn,		{.v = termcmd } },
  { SUPER|SHIFT,        Key_Return,	        togglescratch,	{.v = scratchpadcmd1} },

  { SUPER,		Key_z,		        incgaps,	{.i = +3 } },
  { SUPER,		Key_x,		        incgaps,	{.i = -3 } },
  { SUPER,		Key_c,		        spawn,		SHCMD(TERMINAL "-e profanity") },
  /* { SUPER,		Key_b,		        togglebar,	{0} }, */
  { SUPER,		Key_n,		        spawn,		SHCMD(TERMINAL " -e newsboat ; pkill -RTMIN+6 someblocks") },
  { SUPER,		Key_m,		        spawn,		SHCMD(TERMINAL " -e ncmpcpp") },
  { SUPER|SHIFT,	Key_m,		        spawn,		SHCMD("pamixer -t; kill -44 $(pidof someblocks)") },
  { SUPER,		Key_comma,	        spawn,		SHCMD("mpc prev") },
  { SUPER|SHIFT,	Key_comma,	        spawn,		SHCMD("mpc seek 0%") },
  { SUPER,		Key_period,	        spawn,		SHCMD("mpc next") },
  { SUPER|SHIFT,	Key_period,	        spawn,		SHCMD("mpc repeat") },

  { SUPER,              Key_Left,               focusmon,       {.i = WLR_DIRECTION_LEFT} },
  { SUPER|SHIFT,        Key_Left,               tagmon,         {.i = WLR_DIRECTION_LEFT} },
  { SUPER,              Key_Right,              focusmon,       {.i = WLR_DIRECTION_RIGHT} },
  { SUPER|SHIFT,        Key_Right,              tagmon,         {.i = WLR_DIRECTION_RIGHT} },

  { SUPER,		Key_KP_Up,	        shiftview,	{ .i = -1 } },
  { SUPER,		Key_KP_Down,	        shiftview,	{ .i = +1 } },

  /* { SUPER,		Key_F1,		        spawn,		SHCMD("groff -mom /usr/local/share/dwm/larbs.mom -Tpdf | zathura -") }, */
  { SUPER,		Key_F2,		        spawn,		SHCMD("tutorialvids") },
  { SUPER,		Key_F3,		        spawn,		SHCMD("displayselect") },
  { SUPER,		Key_F4,		        spawn,		SHCMD(TERMINAL " -e pulsemixer; kill -44 $(pidof someblocks)") },
  /* { SUPER,		Key_F5,		        xrdb,		{.v = NULL } }, */
  { SUPER,		Key_F6,		        spawn,		SHCMD("torwrap") },
  { SUPER,		Key_F7,		        spawn,		SHCMD("td-toggle") },
  { SUPER,		Key_F8,		        spawn,		SHCMD("mailsync") },
  { SUPER,		Key_F9,		        spawn,		SHCMD("mounter") },
  { SUPER,		Key_F10,		spawn,		SHCMD("unmounter") },
  { SUPER,		Key_F11,		spawn,		SHCMD("mpv --untimed --no-cache --no-osc --no-input-default-bindings --profile=low-latency --input-conf=/dev/null --title=webcam $(ls /dev/video[0,2,4,6,8] | tail -n 1)") },
  { SUPER,		Key_F12,		spawn,		SHCMD("remaps") },
  { SUPER,		Key_space,	        zoom,		{0} },
  { SUPER|SHIFT,	Key_space,	        togglefloating,	{0} },

  { 0,			Key_Print,	        spawn,		SHCMD("grim -g $(slurp) - | swappy -f -") },   /* Screenshot area to swappy */
  { SHIFT,		Key_Print,	        spawn,		SHCMD("screenshot_area") }, /* Screenshot area to png file and clipboard */
  { ALT,                Key_Print,	        spawn,		SHCMD("grim -g $(slurp) - | wl-copy") }, /* Screenshot area to clipboard only */
  { CTRL,	        Key_Print,	        spawn,		SHCMD("grim - | swappy -f -") }, /* Screenshot monitor to swappy */
  { CTRL|ALT,		Key_Print,	        spawn,		SHCMD("grim - | wl-copy") }, /* Screenshot monitor to clipboard only */
  { CTRL|SHIFT,		Key_Print,	        spawn,		SHCMD("screenshot_monitor") }, /* Screenshot monitor to clipboard only */

  /* # dunstctl */
  { SUPER,		Key_Escape,	        spawn,		SHCMD("dunstctl close-all") },
  { SUPER|CTRL,		Key_h,	                spawn,		SHCMD("dunstctl action") },
  { SUPER|CTRL,		Key_period,	        spawn,		SHCMD("dunstctl close-all") },
  { SUPER|CTRL,		Key_m,	                spawn,		SHCMD("dunstctl set-paused toggle") },

  /* { SUPER,		Key_Print,	        spawn,		{.v = (const char*[]){ "dmenurecord", NULL } } }, */
  /* { SUPER|SHIFT,	Key_Print,	        spawn,		{.v = (const char*[]){ "dmenurecord", "kill", NULL } } }, */

  { 0, Key_XF86AudioMute,		        spawn,		SHCMD("pamixer -t; kill -44 $(pidof someblocks)") },
  { 0, Key_XF86AudioRaiseVolume,	        spawn,		SHCMD("pamixer -i 3; kill -44 $(pidof someblocks)") },
  { 0, Key_XF86AudioLowerVolume,	        spawn,		SHCMD("pamixer -d 3; kill -44 $(pidof someblocks)") },
  { 0, Key_XF86AudioMicMute,	                spawn,		SHCMD("pactl set-source-mute @DEFAULT_SOURCE@ toggle") },
  { 0, Key_XF86MonBrightnessUp,	                spawn,		SHCMD("light -A 15") },
  { 0, Key_XF86MonBrightnessDown,               spawn,		SHCMD("light -U 15") },


#define CHVT(KEY,n) { CTRL, KEY, chvt, {.ui = (n)} }
  CHVT(Key_F1, 1), CHVT(Key_F2,  2),  CHVT(Key_F3,  3),  CHVT(Key_F4,  4),
  CHVT(Key_F5, 5), CHVT(Key_F6,  6),  CHVT(Key_F7,  7),  CHVT(Key_F8,  8),
  CHVT(Key_F9, 9), CHVT(Key_F10, 10), CHVT(Key_F11, 11), CHVT(Key_F12, 12),
};

/* { SUPER, BTN_LEFT,   moveresize,     {.ui = CurMove} }, */
  /* { SUPER, BTN_MIDDLE, togglefloating, {0} }, */
  /* { SUPER, BTN_RIGHT,  moveresize,     {.ui = CurResize} }, */
static const Button buttons[] = {
  { SUPER, BTN_LEFT,   NULL,     NULL },
  { SUPER, BTN_MIDDLE, NULL, NULL },
  { SUPER, BTN_RIGHT,  NULL,     NULL },
};
