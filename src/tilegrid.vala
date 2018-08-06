using OpenLoop;

class OpenLoop.TileGrid : Gtk.Grid
{
	private uint width;
	private uint height;
	public Gee.ArrayList<Section> sections = new Gee.ArrayList<Section>();

	public TileGrid(uint width, uint height)
	{
		// this.set_column_spacing(TILE_SPACING);
		// this.set_row_spacing(TILE_SPACING);

		this.width  = width;
		this.height = height;

		/* Create initial grid of TileHosts */
		for (int x = 0; x < width; x++)
		{
			var section = new Section();

			for (int y = 0; y < height; y++)
			{
				var host = new GUI.TileHost();
				host.section = section;
				this.attach(host, x, y, 1, 1);
			}

			this.sections.add(section);
		}
	}
}
