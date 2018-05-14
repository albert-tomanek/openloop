class OpenLoop.AppUI
{
	private weak App app;

	Gtk.ApplicationWindow root;
	Gtk.Grid grid;

	public AppUI (App app)
	{
		this.app = app;
	}

	public void create ()
	{
		this.root = new Gtk.ApplicationWindow (this.app);
		this.root.default_height = 300;
		this.root.default_width = 300;
		this.root.title = "Hello World";

		this.grid = new Gtk.Grid();
		this.root.add(this.grid);

		var host1 = new GUI.TileHost();
		host1.attach(new LoopTile());
		this.grid.attach(host1, 0, 0, 1, 1);

		var host2 = new GUI.TileHost();
		this.grid.attach(host2, 1, 0, 1, 1);

		this.root.show_all ();
	}
}
