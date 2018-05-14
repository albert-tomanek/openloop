using OpenLoop;

class LoopTile : Tile
{
	//private Audio.Loop loop;
	//public OpenLoop.Audio.SamplePlayer player;

	public LoopTile (/*Loop loop*/)
	{
	}

	public override void draw (Cairo.Context context, uint16 x, uint16 y)
	{
		LoopTile.draw_tile    (this, context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
		LoopTile.draw_progress(this, context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
		LoopTile.draw_waveform(this, context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
	}

	private static void draw_tile (LoopTile tile, Cairo.Context context, uint16 x, uint16 y)
	{
		/* Draw the actual tile */
		context.set_source_rgb((1.0/256.0) * 18.0, (1.0/256.0) * 71.0, (1.0/256.0) * 128.0);		// Draw the tile (0, 47, 154)
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
	}

	private static void draw_progress (LoopTile tile, Cairo.Context context, uint16 x, uint16 y)
	{
	}

	private static void draw_play (LoopTile tile, Cairo.Context context, uint16 x, uint16 y)
	{
	}

}
