class OpenLoop.AppUI
{
	private weak App app;

	private Gtk.ApplicationWindow root;
	private Gtk.Paned paned;

	private GUI.LoopSourceList source_list;
	private GUI.TileGrid tile_grid;

	public AppUI (App app)
	{
		this.app = app;
	}

	public void create ()
	{
		/* Create window */
		this.root = new Gtk.ApplicationWindow (this.app);
		this.root.title = "Loops";

		this.source_list = new GUI.LoopSourceList(this.app);
		this.source_list.set_size_request(130, -1);
		this.tile_grid = new GUI.TileGrid(4, 3);

		this.paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
		this.paned.pack1(this.source_list, false, false);
		this.paned.pack2(this.tile_grid, false, false);

		this.root.add(this.paned);

		this.root.show_all ();
	}
}
