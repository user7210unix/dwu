/*
 * DWU runtime configuration.
 *
 * dwm reads ~/.config/dwu/dwm.rc (one "key=value" per line) every time it
 * starts and on the xrdb reload key. That file is written by dwu-settings, so
 * palette, fonts, bar position, gaps, brand text and so on never need a
 * recompile and never depend on the X resource database being merged first.
 * Anything missing from the file keeps the compiled-in default.
 */

enum { DWU_INT, DWU_UINT, DWU_COLOR };

typedef struct {
	const char *key;
	int type;
	void *dst;
} DwuOpt;

static char dwu_brand[64] = "";

static void
dwu_set_color(char *dst, const char *val)
{
	/* colors are stored as "#rrggbb" in 8 byte buffers */
	if (val[0] == '#' && strlen(val) == 7)
		memcpy(dst, val, 8);
}

static void
dwu_load_config(void)
{
	static int first = 1;
	char path[512], line[512], *val, *nl;
	const char *base = getenv("XDG_CONFIG_HOME"), *home = getenv("HOME");
	FILE *fp;
	unsigned int i, a;
	int have_brand = 0;
	const DwuOpt opts[] = {
		{ "topbar",         DWU_INT,   (void *)&topbar },
		{ "showbar",        DWU_INT,   (void *)&showbar },
		{ "borderpx",       DWU_UINT,  (void *)&borderpx },
		{ "snap",           DWU_UINT,  (void *)&snap },
		{ "bar_height",     DWU_INT,   (void *)&bar_height },
		{ "vertpad",        DWU_INT,   (void *)&vertpad },
		{ "sidepad",        DWU_INT,   (void *)&sidepad },
		{ "gappih",         DWU_UINT,  (void *)&gappih },
		{ "gappiv",         DWU_UINT,  (void *)&gappiv },
		{ "gappoh",         DWU_UINT,  (void *)&gappoh },
		{ "gappov",         DWU_UINT,  (void *)&gappov },
		{ "smartgaps_fact", DWU_INT,   (void *)&smartgaps_fact },
		{ "showsystray",    DWU_INT,   (void *)&showsystray },
		{ "systrayspacing", DWU_UINT,  (void *)&systrayspacing },
		{ "ulinestroke",    DWU_UINT,  (void *)&ulinestroke },
		{ "ulinepad",       DWU_UINT,  (void *)&ulinepad },
		{ "ulineall",       DWU_INT,   (void *)&ulineall },
		{ "normfgcolor",         DWU_COLOR, normfgcolor },
		{ "normbgcolor",         DWU_COLOR, normbgcolor },
		{ "normbordercolor",     DWU_COLOR, normbordercolor },
		{ "normfloatcolor",      DWU_COLOR, normfloatcolor },
		{ "selfgcolor",          DWU_COLOR, selfgcolor },
		{ "selbgcolor",          DWU_COLOR, selbgcolor },
		{ "selbordercolor",      DWU_COLOR, selbordercolor },
		{ "selfloatcolor",       DWU_COLOR, selfloatcolor },
		{ "titlenormfgcolor",    DWU_COLOR, titlenormfgcolor },
		{ "titlenormbgcolor",    DWU_COLOR, titlenormbgcolor },
		{ "titlenormbordercolor",DWU_COLOR, titlenormbordercolor },
		{ "titlenormfloatcolor", DWU_COLOR, titlenormfloatcolor },
		{ "titleselfgcolor",     DWU_COLOR, titleselfgcolor },
		{ "titleselbgcolor",     DWU_COLOR, titleselbgcolor },
		{ "titleselbordercolor", DWU_COLOR, titleselbordercolor },
		{ "titleselfloatcolor",  DWU_COLOR, titleselfloatcolor },
		{ "tagsnormfgcolor",     DWU_COLOR, tagsnormfgcolor },
		{ "tagsnormbgcolor",     DWU_COLOR, tagsnormbgcolor },
		{ "tagsnormbordercolor", DWU_COLOR, tagsnormbordercolor },
		{ "tagsnormfloatcolor",  DWU_COLOR, tagsnormfloatcolor },
		{ "tagsselfgcolor",      DWU_COLOR, tagsselfgcolor },
		{ "tagsselbgcolor",      DWU_COLOR, tagsselbgcolor },
		{ "tagsselbordercolor",  DWU_COLOR, tagsselbordercolor },
		{ "tagsselfloatcolor",   DWU_COLOR, tagsselfloatcolor },
		{ "hidnormfgcolor",      DWU_COLOR, hidnormfgcolor },
		{ "hidnormbgcolor",      DWU_COLOR, hidnormbgcolor },
		{ "hidselfgcolor",       DWU_COLOR, hidselfgcolor },
		{ "hidselbgcolor",       DWU_COLOR, hidselbgcolor },
		{ "urgfgcolor",          DWU_COLOR, urgfgcolor },
		{ "urgbgcolor",          DWU_COLOR, urgbgcolor },
		{ "urgbordercolor",      DWU_COLOR, urgbordercolor },
		{ "urgfloatcolor",       DWU_COLOR, urgfloatcolor },
		{ "color0",              DWU_COLOR, termcol0 },
		{ "color1",              DWU_COLOR, termcol1 },
		{ "color2",              DWU_COLOR, termcol2 },
		{ "color3",              DWU_COLOR, termcol3 },
		{ "color4",              DWU_COLOR, termcol4 },
		{ "color5",              DWU_COLOR, termcol5 },
		{ "color6",              DWU_COLOR, termcol6 },
		{ "color7",              DWU_COLOR, termcol7 },
		{ "color8",              DWU_COLOR, termcol8 },
		{ "color9",              DWU_COLOR, termcol9 },
		{ "color10",              DWU_COLOR, termcol10 },
		{ "color11",              DWU_COLOR, termcol11 },
		{ "color12",              DWU_COLOR, termcol12 },
		{ "color13",              DWU_COLOR, termcol13 },
		{ "color14",              DWU_COLOR, termcol14 },
		{ "color15",              DWU_COLOR, termcol15 },
	};

	if (base && *base)
		snprintf(path, sizeof(path), "%s/dwu/dwm.rc", base);
	else if (home)
		snprintf(path, sizeof(path), "%s/.config/dwu/dwm.rc", home);
	else
		return;

	/* st and dmenu read the X resource database, make sure it is filled
	 * even when dwm was started by a hand written .xinitrc */
	if (first && home) {
		char cmd[640];
		snprintf(cmd, sizeof(cmd), "f=\"%s\"; [ -f \"${f%%/dwm.rc}/Xresources\" ] && xrdb -merge \"${f%%/dwm.rc}/Xresources\" >/dev/null 2>&1 &", path);
		if (system(cmd)) { /* best effort */ }
	}
	first = 0;

	if (!(fp = fopen(path, "r")))
		return;

	while (fgets(line, sizeof(line), fp)) {
		if ((nl = strchr(line, '\n')))
			*nl = '\0';
		if (line[0] == '#' || !(val = strchr(line, '=')))
			continue;
		*val++ = '\0';

		if (!strcmp(line, "font_ui") && *val)         { fonts[0] = strdup(val); continue; }
		if (!strcmp(line, "font_icons") && *val)      { fonts[1] = strdup(val); continue; }
		if (!strcmp(line, "font_brand") && *val)      { brandfont[0] = strdup(val); continue; }
		if (!strcmp(line, "font_brand_icons") && *val){ brandfont[1] = strdup(val); continue; }
		if (!strcmp(line, "brand")) {
			snprintf(dwu_brand, sizeof(dwu_brand), "%s", val);
			have_brand = 1;
			continue;
		}
		if (!strcmp(line, "alpha")) {
			a = (unsigned int)strtoul(val, NULL, 10) & 0xff;
			for (i = 0; i < LENGTH(alphas); i++)
				alphas[i][1] = a;
			continue;
		}
		for (i = 0; i < LENGTH(opts); i++) {
			if (strcmp(line, opts[i].key))
				continue;
			switch (opts[i].type) {
			case DWU_INT:   *(int *)opts[i].dst = (int)strtol(val, NULL, 10); break;
			case DWU_UINT:  *(unsigned int *)opts[i].dst = (unsigned int)strtoul(val, NULL, 10); break;
			case DWU_COLOR: dwu_set_color((char *)opts[i].dst, val); break;
			}
			break;
		}
	}
	fclose(fp);

	if (have_brand && LENGTH(launchers) > 0)
		launchers[0].name = dwu_brand;
}
