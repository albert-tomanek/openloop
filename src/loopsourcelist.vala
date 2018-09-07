class OpenLoop.GUI.LoopSourceList : Granite.Widgets.SourceList
{
	public Gee.ArrayList<Loop> loops = new Gee.ArrayList<Loop>();

	public LoopSourceList()
	{
		base();
		this.ellipsize_mode = Pango.EllipsizeMode.START;

		/* Drag and Drop source */
		this.enable_drag_source(TileHost.gtk_targetentries);

		/* Test sample */
		{
			var test_loop = new Loop(OpenLoop.Audio.Sample.load_raw("../media/wicked dub_f32s.raw", 44100, 2));
			var test_loop_item = new LoopSourceItem("", "Test Loop");
			test_loop_item.loop = test_loop;
			this.root.add(test_loop_item);
		}
	}

	public void add_path(string path)
	{
		var item = new LoopSourceItem(path);
		this.root.add(item);
	}
}

class OpenLoop.GUI.LoopSourceItem : Granite.Widgets.SourceList.Item, Granite.Widgets.SourceListDragSource
{
	public string file_path;
	public Loop?  loop = null;			// A reference to the loop if it has already been loaded from a file. TODO: This reference the loop sample in memory, even if it is not being played anywhere.

	public LoopSourceItem(string path, string? name = null)
	{
		base(name ?? path);
		this.file_path = path;
	}

	public bool draggable()
	{
		return true;
	}

	public void prepare_selection_data (Gtk.SelectionData selection_data)
	{
		if (this.loop == null)
		{
			/* Load the loop if it hasn't been loaded yet. */
			this.loop = Loop.load_path(this.file_path);
			return;
		}

		/* Create a new tile with this loop */
		Tile tile = new LoopTile(this.loop);
		tile.pipeline.add(tile.gst_element);
		tile.@ref();	// We need to manually increase the reference cound of the tile because Vala doesn't know that we're keeping a pointer to it when we send it over to the other widget.

		/* Send a pointer to it */
		Tile[] _tile = {tile};
		selection_data.set(selection_data.get_target(), (int) sizeof(void *) * 8, (uint8[])(_tile));
	}
}
