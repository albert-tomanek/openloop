class OpenLoop.AppUI
{
	private weak App app;

	private  Gtk.ApplicationWindow root;
	internal Gtk.Grid grid;

	public AppUI (App app)
	{
		this.app = app;
	}

	public void create ()
	{
		this.root = new Gtk.ApplicationWindow (this.app);
		this.root.default_height = 300;
		this.root.default_width = 300;
		this.root.title = "Loops";

		this.grid = new Gtk.Grid();
		this.root.add(this.grid);

		this.root.show_all ();
	}
}
