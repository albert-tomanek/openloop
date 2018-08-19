struct OpenLoop.Colours
{
	static uint32 LIGHT_BLUE = 0x38acffff;
	static uint32 DARK_BLUE  = 0x124780ff;

	public static void set_context_rgb(Cairo.Context context, uint32 colour)
	{
		context.set_source_rgba(((colour & 0xff000000) >> 24) / 255f, ((colour & 0x00ff0000) >> 16) / 255f, ((colour & 0x0000ff00) >> 8) / 255f, ((colour & 0x000000ff) >> 0) / 255f);
	}
}
