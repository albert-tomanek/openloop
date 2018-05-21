using OpenLoop;

class LoopTile : Tile
{
	private Loop loop;
	public  Audio.SamplePlayer player;

	private float[] repr;

	public LoopTile (OpenLoop.Loop loop)
	{
		this.loop = loop;
		this.player = new Audio.SamplePlayer (this.loop.orig_sample);

		/* Generate the sample's visual representation */
		this.repr = this.loop.orig_sample.visual_repr (TILE_WIDTH);
	}

	public override void start ()
	{
		this.player.playing = true;
	}

	public override void stop ()
	{
		this.player.playing = false;
	}

	public override bool playing { get { return this.player.playing; } }

	public override void draw (Cairo.Context context, uint16 x, uint16 y)
	{
		LoopTile.draw_tile    (this, context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
		LoopTile.draw_progress(this, context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
		LoopTile.draw_waveform(this, context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
	}

	private static void draw_tile (LoopTile tile, Cairo.Context context, uint16 x, uint16 y)
	{
		/* Draw the actual tile */
		context.set_source_rgb(18f/255f, 71f/255f, 128f/255f);		// Draw the tile (0, 47, 154)
		context.set_line_join(Cairo.LineJoin.ROUND);

		context.new_path();
		context.move_to(x, y + TILE_CORNER_RADIUS);
		// from http://www.mono-project.com/docs/tools+libraries/libraries/Mono.Cairo/cookbook/
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

	private static void draw_waveform (LoopTile tile, Cairo.Context context, uint16 x, uint16 y)
	{
		/* Draw a representation of the sample's waveform */
		uint16 center_y = y + (TILE_HEIGHT / 2);

		context.set_source_rgb (1.0, 1.0, 1.0);
		context.set_line_join (Cairo.LineJoin.ROUND);

		context.new_path ();
		context.set_line_width (0.5);
		context.move_to (x, center_y);

		uint16 current_x = x;
		foreach (float val in tile.repr)
		{
			context.line_to(current_x, center_y - (val * 1000 * TILE_HEIGHT * 0.5));
			current_x++;
		}

		context.stroke();
	}

	private static void draw_progress (LoopTile tile, Cairo.Context context, uint16 x, uint16 y)
	{
		/* Draw the progress */
		context.set_source_rgba(51f/255f, 150f/255f, 255f/255f, 0.5);		// Draw the tile (0, 47, 154)
		context.set_line_join(Cairo.LineJoin.MITER);

		context.new_path();
		context.move_to(x + TILE_CORNER_RADIUS, y + TILE_HEIGHT);

		context.arc     (x + TILE_CORNER_RADIUS, y + TILE_HEIGHT - TILE_CORNER_RADIUS, TILE_CORNER_RADIUS, Math.PI / 2, Math.PI);
		context.line_to (x, y + TILE_CORNER_RADIUS);
		context.arc     (x + TILE_CORNER_RADIUS, y + TILE_CORNER_RADIUS, TILE_CORNER_RADIUS, Math.PI, -Math.PI / 2);
		context.line_to (x + TILE_WIDTH * tile.player.progress, y);
		context.rel_line_to(0, TILE_HEIGHT);

		context.close_path();
		context.fill();
	}

	private static void draw_play (LoopTile tile, Cairo.Context context, uint16 x, uint16 y)
	{
	}

}
