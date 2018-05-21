using OpenLoop;

static uint16 TILE_WIDTH  = 96;
static uint16 TILE_HEIGHT = 96;
static uint16 TILE_CORNER_RADIUS = 6;
static uint16 TILE_BORDER_OFFSET = 4;	// How many pixels between the tile and its border
static uint16 TILE_BORDER_WIDTH  = 2;	// How wide the tile border is

abstract class Tile
{
	//private GUI.TileHost? host;

	public abstract void start();
	public abstract void stop();
	public abstract bool playing { get; }

	public abstract void draw (Cairo.Context context, uint16 x, uint16 y);
}
