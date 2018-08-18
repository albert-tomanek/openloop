using OpenLoop;

class GUI.LoopSourceList : Granite.Widgets.SourceList
{
	private weak OpenLoop.App app;

	public LoopSourceList(OpenLoop.App instance)
	{
		base();
		this.app = instance;

		/* Drag and Drop source */
		this.enable_drag_source(TileHost.gtk_targetentries);

		/* Initial tile */
		{
			var test_loop_item = new LoopSourceItem("Test loop", this.app.pipeline);
			test_loop_item.loop = test_loop;
			this.root.add(test_loop_item);
		}
	}
}

class GUI.LoopSourceItem : Granite.Widgets.SourceList.Item, Granite.Widgets.SourceListDragSource
{
	public string file_path;
	public Loop?  loop;			// A reference to the loop if it has already been loaded from a file.

	private OpenLoop.AppPipeline _pipeline;		// TODO: Uhh. Why can't we access the parent SourceList to get the pipeline when we `prepare_selection_data`?

	public LoopSourceItem(string name, OpenLoop.AppPipeline pipeline)
	{
		base(name);
		this._pipeline = pipeline;
	}

	public bool draggable()
	{
		return true;
	}

	public void prepare_selection_data (Gtk.SelectionData selection_data)
	{
		if (loop == null)
		{
			GLib.printerr("Error: loading loops not implementd yet.\n");
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
