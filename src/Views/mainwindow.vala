class OpenLoop.MainWindow
{
	public Gtk.ApplicationWindow root;
	public Gtk.Paned paned;

	public GUI.LoopSourceList source_list;
	public GUI.TileGrid tile_grid;
	public GUI.BottomBar bottom_bar;

	public Gtk.HeaderBar hbar;
	public GUI.MetronomeControl hbar_metronomectl;

	public MainWindow ()
	{
	}

	public void create (Gtk.Application instance)
	{
		/* Create window */
		this.root = new Gtk.ApplicationWindow (instance);

		/* HeaderBar */
		{
			this.hbar = new Gtk.HeaderBar();
			this.hbar.title = "OpenLoop";
			this.hbar.show_close_button = true;
			this.root.set_titlebar(this.hbar);

			this.hbar_metronomectl = new GUI.MetronomeControl(App.metronome);
			this.hbar.pack_end(this.hbar_metronomectl);
		}

		/* Window Contents */
		{
			var grid = new Gtk.Grid();
			grid.orientation = Gtk.Orientation.VERTICAL;

			{
				this.source_list = new GUI.LoopSourceList();
				this.source_list.set_size_request(130, -1);
				this.tile_grid = new GUI.TileGrid(4, 3);

				this.paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
				this.paned.pack1(this.source_list, false, false);
				this.paned.pack2(this.tile_grid, false, false);

				grid.add(this.paned);
			}

			/* ActionBar */
			{
				this.bottom_bar = new GUI.BottomBar();
				grid.add(this.bottom_bar);
			}

			this.root.add(grid);
		}

		this.root.show_all ();
		
		if (App.dev_mode)
		{
			var metinfo = new Views.MetronomeInfo();
			metinfo.show();
		}
	}

	/* Various actions */
	public void import_loop()
	{
		string path;

		{
			var chooser = new Gtk.FileChooserDialog("Import Loop", this.root, Gtk.FileChooserAction.OPEN, "_Cancel", Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT, null);
			var filter  = new Gtk.FileFilter();
			filter.set_filter_name("Sound files");

			foreach (string mime in MimeTypes.IMPORT_FORMATS)
			{
				filter.add_mime_type(mime);
			}

			chooser.add_filter(filter);

			var rc = chooser.run();
			if (rc != Gtk.ResponseType.ACCEPT)
			{
				chooser.destroy();
				return;
			}

			path = chooser.get_filename();
			chooser.destroy();
		}

		App.ui.source_list.add_path(path);
	}
}
