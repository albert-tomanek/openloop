using OpenLoop;

static uint16 TILE_WIDTH  = 96;
static uint16 TILE_HEIGHT = 96;
static uint16 TILE_CORNER_RADIUS = 6;
static uint16 TILE_BORDER_OFFSET = 4;	// How many pixels between the tile and its border
static uint16 TILE_BORDER_WIDTH  = 2;	// How wide the tile border is
static uint16 TILE_SPACING = 4;

abstract class OpenLoop.Tile : Object
{
	public OpenLoop.AppPipeline pipeline;
	public weak GUI.TileHost? host;

	public abstract Gst.Element? gst_element { get; }

	public abstract void start();
	public abstract void stop();
	public abstract bool playing { get; }

	public bool selected {
		get {
			if (this.host != null)
			{
				if (this.host.grid != null)
				{
					return this.host.grid.selected.contains(this);
				}
			}

			return false;
		}
		set {
			if (this.host != null)
			{
				if (this.host.grid != null)
				{
					if (value == true && !this.host.grid.selected.contains(this))
					{
						this.host.grid.selected.add(this);
					}
					else if (value == false)
					{
						this.host.grid.selected.remove(this);
					}
				}
			}
		}
	}

	public abstract void draw        (Cairo.Context context, uint16 x, uint16 y);
	public abstract void draw_border (Cairo.Context context, uint16 x, uint16 y);
	protected void draw_border_with_colour (Cairo.Context context, uint16 x, uint16 y, uint32 colour)
	{
		Colours.set_context_rgb(context, colour);

		context.new_path();
		context.set_line_width (TILE_BORDER_WIDTH);
		context.move_to(x - TILE_BORDER_OFFSET, y + TILE_CORNER_RADIUS);

		context.arc     (x + TILE_CORNER_RADIUS, y + TILE_CORNER_RADIUS, TILE_CORNER_RADIUS + TILE_BORDER_OFFSET, Math.PI, -Math.PI / 2);
		context.line_to (x + TILE_WIDTH - TILE_CORNER_RADIUS, y - TILE_BORDER_OFFSET);
		context.arc     (x + TILE_WIDTH - TILE_CORNER_RADIUS, y + TILE_CORNER_RADIUS, TILE_CORNER_RADIUS + TILE_BORDER_OFFSET, -Math.PI / 2, 0);
		context.line_to (x + TILE_WIDTH + TILE_BORDER_OFFSET, y + TILE_HEIGHT - TILE_CORNER_RADIUS);
		context.arc     (x + TILE_WIDTH - TILE_CORNER_RADIUS, y + TILE_HEIGHT - TILE_CORNER_RADIUS, TILE_CORNER_RADIUS + TILE_BORDER_OFFSET, 0, Math.PI / 2);
		context.line_to (x + TILE_CORNER_RADIUS, y + TILE_HEIGHT + TILE_BORDER_OFFSET);
		context.arc     (x + TILE_CORNER_RADIUS, y + TILE_HEIGHT - TILE_CORNER_RADIUS, TILE_CORNER_RADIUS + TILE_BORDER_OFFSET, Math.PI / 2, Math.PI);
		context.close_path();

		context.stroke();
	}

	public void die()
	{
		/* This should clear all references to the	*
		 * tile and therefore cause it to be freed. */

		this.pipeline.remove(this.gst_element);

		if (this.host != null)
			this.host.release();
	}
}
