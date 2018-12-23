class OpenLoop.GUI.TileGrid : Gtk.Grid
{
	private uint width;
	private uint height;

	public Gee.ArrayList<Section> sections = new Gee.ArrayList<Section>();			// Columns on the grid
	public Gee.ArrayList<weak Tile> selection = new Gee.ArrayList<weak Tile>();		// Has to be weak because if we try to destroy all the tiles in the selection then this will be keeping them alive.

	public TileGrid(uint width, uint height)
	{
		this.set_column_spacing(TILE_SPACING);
		this.set_row_spacing(TILE_SPACING);

		this.key_press_event.connect(this.on_keypress);

		this.width  = width;
		this.height = height;

		/* Create initial grid of TileHosts */
		for (int x = 0; x < width; x++)
		{
			var section = new Section();

			for (int y = 0; y < height; y++)
			{
				var host = new GUI.TileHost (this);
				Section.add_host (host, section);
				this.attach (host, x, y, 1, 1);
			}

			this.sections.add(section);
		}
	}

	public void add_row()
	{
		//this.insert_row()

		for (int x = 0; x < this.width; x++)
		{
			var host = new GUI.TileHost (this);
			Section.add_host (host, this.sections[x]);
			this.attach (host, x, (int) this.height, 1, 1);
		}

		this.height++;
	}

	public bool on_keypress(Gdk.EventKey event)
	{
		if (event.keyval == Gdk.Key.Delete)
			print("Delete!\n");

		return true;
	}
}
