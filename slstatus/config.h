/* DWU slstatus: one command builds the whole line, see scripts/dwu-bar.
   Modules are switched on and off in dwu-settings, no recompile needed. */

const unsigned int interval = 2000;

static const char unknown_str[] = "";

#define MAXLEN 2048

static const struct arg args[] = {
	{ run_command, "%s", "dwu-bar" },
};
