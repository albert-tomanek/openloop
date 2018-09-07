class OpenLoop.AppUI
{
	private Gtk.ApplicationWindow root;
	private Gtk.Paned paned;

	private GUI.LoopSourceList source_list;
	private GUI.TileGrid tile_grid;
	private GUI.BottomBar bottom_bar;

	public AppUI ()
	{
	}

	public void create (Gtk.Application instance)
	{
		/* Create window */
		this.root = new Gtk.ApplicationWindow (instance);
		this.root.title = "Loops";

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

			{
				this.bottom_bar = new GUI.BottomBar();
				grid.add(this.bottom_bar);
			}

			this.root.add(grid);
		}

		this.root.show_all ();
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

			//chooser.add_filter(filter);	// Don't add the filter yet as we can still ony load raw sample files.

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
