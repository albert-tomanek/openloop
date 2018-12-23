class OpenLoop.GUI.LoopSourceList : Granite.Widgets.SourceList
{
	public Gee.ArrayList<Loop> loops = new Gee.ArrayList<Loop>();

	public LoopSourceList()
	{
		base();
		this.ellipsize_mode = Pango.EllipsizeMode.START;

		/* Drag and Drop source */
		this.enable_drag_source(TileHost.gtk_targetentries);
	}

	public void add_path(string path)
	{
		var item = new LoopSourceItem(path);

		/* Add it to the SourceList */
		this.root.add(item);

		/* Queue for the sample to be loaded */
		// App.threads.loop_importer.queue.add(item);
		// item.load_pending();

		item.loop = new Loop.from_asset(App.ges_project.create_asset_sync("file://" + path, typeof(GES.UriClip)));
	}
}

class OpenLoop.GUI.LoopSourceItem : Granite.Widgets.SourceList.Item, Granite.Widgets.SourceListDragSource
{
	public string file_path;
	public Loop?  loop = null;			// A reference to the loop if it has already been loaded from a file. TODO: This reference the loop sample in memory, even if it is not being played anywhere.

	public signal void load_pending();	// Called when the item has been added to the queue of items to load.
	public signal void load_finished();	// Called when the loop has been loaded.

	public LoopSourceItem(string path, string? name = null)
	{
		base(name ?? path);
		this.file_path = path;

		this.editable = true;
		this.edited.connect((name) => {this.name = name;});

		this.load_pending.connect(() => {
			this.icon = Icon.new_for_string("document-send-symbolic");
		});

		this.load_finished.connect(() => {
			this.icon = null;
		});
	}

	~LoopSourceItem()
	{
		App.threads.loop_importer.queue.remove(this);
	}

	public bool draggable()
	{
		if (this.loop == null)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	public void prepare_selection_data (Gtk.SelectionData selection_data)
	{
		// if (this.loop == null)
		// {
		// 	/* Load the loop if it hasn't been loaded yet. */
		// 	this.loop = Loop.import_path(this.file_path);
		// 	return;
		// }
		//
		/* Create a new tile with this loop */
		Tile tile = new LoopTile(this.loop);
		//App.pipeline.add(tile.gst_element);
		tile.@ref();	// We need to manually increase the reference cound of the tile because Vala doesn't know that we're keeping a pointer to it when we send it over to the other widget.

		/* Send a pointer to it */
		Tile[] _tile = {tile};
		selection_data.set(selection_data.get_target(), (int) sizeof(void *) * 8, (uint8[])(_tile));
	}
}
