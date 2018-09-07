class OpenLoop.GUI.LoopSourceList : Granite.Widgets.SourceList
{
	private weak OpenLoop.App app;

	public Gee.ArrayList<Loop> loops = new Gee.ArrayList<Loop>();

	public LoopSourceList(OpenLoop.App instance)
	{
		base();
		this.app = instance;

		/* Drag and Drop source */
		this.enable_drag_source(TileHost.gtk_targetentries);

		/* Test sample */
		{
			var test_loop = new Loop(OpenLoop.Audio.Sample.load_raw("../media/wicked dub_f32s.raw", 44100, 2));
			var test_loop_item = new LoopSourceItem("", this.app.pipeline, "Test Loop");
			test_loop_item.loop = test_loop;
			this.root.add(test_loop_item);
		}
	}

	public void add_path(string path)
	{
		var item = new LoopSourceItem(path, this.app.pipeline);
		this.root.add(item);
	}
}

class OpenLoop.GUI.LoopSourceItem : Granite.Widgets.SourceList.Item, Granite.Widgets.SourceListDragSource
{
	public string file_path;
	public Loop?  loop = null;			// A reference to the loop if it has already been loaded from a file. TODO: This reference the loop sample in memory, even if it is not being played anywhere.

	private OpenLoop.AppPipeline _pipeline;		// TODO: Uhh. Why can't we access the parent SourceList to get the pipeline when we `prepare_selection_data`?

	public LoopSourceItem(string path, OpenLoop.AppPipeline pipeline, string? name = null)
	{
		base(name ?? path);
		this.file_path = path;
		this._pipeline = pipeline;
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
		Tile tile = new LoopTile(this._pipeline, this.loop);
		tile.pipeline.add(tile.gst_element);
		tile.@ref();	// We need to manually increase the reference cound of the tile because Vala doesn't know that we're keeping a pointer to it when we send it over to the other widget.

		/* Send a pointer to it */
		Tile[] _tile = {tile};
		selection_data.set(selection_data.get_target(), (int) sizeof(void *) * 8, (uint8[])(_tile));
	}
}
