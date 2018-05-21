using OpenLoop;

class GUI.TileHost : Gtk.DrawingArea
{
	private Tile? tile = null;

	public TileHost()
	{
		this.set_size_request(
			TILE_WIDTH + (2 * TILE_BORDER_OFFSET) + (2 * TILE_BORDER_WIDTH),
			TILE_WIDTH + (2 * TILE_BORDER_OFFSET) + (2 * TILE_BORDER_WIDTH)
		);

		/* Listen for events */
		this.add_events (
			Gdk.EventMask.BUTTON_PRESS_MASK
		);

		this.button_press_event.connect(this.on_click);

		/* Queue a redraw every 50 milliseconds */
		Timeout.add(50, () => { this.queue_draw(); return true; });
	}

	public void attach(Tile tile)
	{
		this.tile = tile;
	}

	public void release()
	{
		this.tile = null;
	}

	public override bool draw (Cairo.Context context)
	{
		if (this.tile != null)
		{
			this.tile.draw(context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
		}
		else
		{
			/* If we don't contain any tile, draw us empty */
			TileHost.draw_empty(context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
		}

		return true;
	}

	private static void draw_empty (Cairo.Context context, uint16 x, uint16 y)
	{
		/* For more, see LoopTile.draw_tile */
		context.set_source_rgba(0.5, 0.5, 0.5, 0.2);
		context.set_line_join(Cairo.LineJoin.ROUND);

		context.new_path();
		context.move_to (x, y + TILE_CORNER_RADIUS);
		context.arc     (x + TILE_CORNER_RADIUS, y + TILE_CORNER_RADIUS, TILE_CORNER_RADIUS, Math.PI, -Math.PI / 2);
		context.line_to (x + TILE_WIDTH - TILE_CORNER_RADIUS, y);
		context.arc     (x + TILE_WIDTH - TILE_CORNER_RADIUS, y + TILE_CORNER_RADIUS, TILE_CORNER_RADIUS, -Math.PI / 2, 0);
		context.line_to (x + TILE_WIDTH, y + TILE_HEIGHT - TILE_CORNER_RADIUS);
		context.arc     (x + TILE_WIDTH - TILE_CORNER_RADIUS, y + TILE_HEIGHT - TILE_CORNER_RADIUS, TILE_CORNER_RADIUS, 0, Math.PI / 2);
		context.line_to (x + TILE_CORNER_RADIUS, y + TILE_HEIGHT);
		context.arc     (x + TILE_CORNER_RADIUS, y + TILE_HEIGHT - TILE_CORNER_RADIUS, TILE_CORNER_RADIUS, Math.PI / 2, Math.PI);
		context.close_path();
		context.fill();
	}

	private bool on_click(Gdk.EventButton event)
	{
		if (this.tile == null)
			return false;

		if (this.tile.playing)
		{
			this.tile.stop();
		}
		else
		{
			this.tile.start();
		}

		return true;	// true to stop other handlers from being invoked for the event.
	}
}
