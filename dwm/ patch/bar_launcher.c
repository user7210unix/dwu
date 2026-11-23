static Fnt *brandfonts;

static void
brand_init(void)
{
	Fnt *previous;

	if (brandfonts)
		return;
	previous = drw->fonts;
	brandfonts = drw_fontset_create(drw, brandfont, LENGTH(brandfont));
	drw->fonts = previous;
}

static int
brand_width(const char *text)
{
	Fnt *previous = drw->fonts;
	int w;

	brand_init();
	drw->fonts = brandfonts ? brandfonts : previous;
	w = drw_fontset_getwidth(drw, text, False) + lrpad;
	drw->fonts = previous;
	return w;
}

int
width_launcher(Bar *bar, BarArg *a)
{
	int i, x = 0;

	for (i = 0; i < LENGTH(launchers); i++)
		if (launchers[i].name && *launchers[i].name)
			x += brand_width(launchers[i].name);
	return x;
}

int
draw_launcher(Bar *bar, BarArg *a)
{
	Fnt *previous = drw->fonts;
	int i, x = 0, w = 0;

	brand_init();
	for (i = 0; i < LENGTH(launchers); i++) {
		if (!launchers[i].name || !*launchers[i].name)
			continue;
		w = brand_width(launchers[i].name);
		drw->fonts = brandfonts ? brandfonts : previous;
		drw_text(drw, x, 0, w, bh, lrpad / 2, launchers[i].name, 0, False);
		drw->fonts = previous;
		x += w;
	}
	return x;
}

int
click_launcher(Bar *bar, Arg *arg, BarArg *a)
{
	int i, x = 0;

	for (i = 0; i < LENGTH(launchers); i++) {
		if (!launchers[i].name || !*launchers[i].name)
			continue;
		x += brand_width(launchers[i].name);
		if (a->x < x) {
			spawn(&launchers[i].command);
			break;
		}
	}
	return -1;
}
