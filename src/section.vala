/* A column of tiles in a tile grid. Tiles are in order from the top down. */

class OpenLoop.Section
{
	public Gee.ArrayList<GUI.TileHost> tile_hosts = new Gee.ArrayList<GUI.TileHost>();

	public static void add_host(GUI.TileHost host, Section section)
	{
		host.section = section;
		section.tile_hosts.add(host);
	}
}
