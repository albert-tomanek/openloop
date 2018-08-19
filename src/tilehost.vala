using OpenLoop;

class GUI.TileHost : Gtk.DrawingArea
{
	public weak TileGrid grid;
	public weak Section? section;

	private Tile? tile = null;

	/* Gtk stuff */
	public enum DndTargetType {
		TILE_PTR
	}

	public static const Gtk.TargetEntry[] gtk_targetentries = {
		{"com.github.albert-tomanek.openloop.tile.instance_ptr", Gtk.TargetFlags.SAME_APP, TileHost.DndTargetType.TILE_PTR}
	};

	private bool tile_being_dragged = false;

	public TileHost(TileGrid grid)
	{
		this.grid = grid;

		this.set_size_request(
			TILE_WIDTH + (2 * TILE_BORDER_OFFSET) + (2 * TILE_BORDER_WIDTH),
			TILE_WIDTH + (2 * TILE_BORDER_OFFSET) + (2 * TILE_BORDER_WIDTH)
		);

		/* Listen for events */
		this.add_events (
			Gdk.EventMask.BUTTON_PRESS_MASK |
			Gdk.EventMask.BUTTON_RELEASE_MASK
		);

		this.button_release_event.connect(this.on_click);

		/* Drag and Drop */
		Gtk.drag_source_set(this, Gdk.ModifierType.BUTTON1_MASK, TileHost.gtk_targetentries, Gdk.DragAction.MOVE);

		this.drag_begin.connect(this.on_drag_begin);
		this.drag_end.connect(this.on_drag_end);
		this.drag_data_get.connect(this.on_drag_data_get);

		Gtk.drag_dest_set(this, Gtk.DestDefaults.MOTION, TileHost.gtk_targetentries, Gdk.DragAction.MOVE);

		this.drag_drop.connect(this.on_drag_drop);
		this.drag_data_received.connect(this.on_drag_data_received);

		/* Queue a redraw every 50 milliseconds */
		Timeout.add(50, () => { this.queue_draw(); return true; });
	}

	public void attach(Tile tile)
	{
		this.tile = tile;
		tile.host = this;
	}

	public void release()
	{
		this.tile.host = null;
		this.tile = null;
	}

	/* User interaction handelers */

	private bool on_click(Gdk.EventButton event)
	{
		Gdk.ModifierType mods;

		switch (event.button)
		{
			case 1:
				if (this.tile != null)
				{
					event.get_state(out mods);
					if ((mods & Gdk.ModifierType.CONTROL_MASK) != 0)
					{
						/* Control-click to select */
						if (this.tile != null)
							this.tile.selected = !this.tile.selected;
					}
					else
					{
						/* Normal click to stop/start */
						if (this.tile.playing)
						{
							this.tile.stop();
						}
						else
						{
							this.tile.start();
						}
					}
				}
				break;
			case 3:
				this.on_rclick(event);
				break;
		}

		return true;	// true to stop other handlers from being invoked for the event.
	}

	private void on_rclick(Gdk.EventButton event)
	{
		var context_menu = new Gtk.Menu();						// Because context_menu is a local variable, it would be destroyed after the current method ended. Therefore we have to attach it to a widget so that it is destroyed only once the widget is destoryed.
		context_menu.attach_to_widget(this, null);

		if (this.tile != null)
		{
			var item_delete_tile = new Gtk.MenuItem.with_mnemonic("_Delete tile");
			item_delete_tile.activate.connect(() => {
				if (this.grid.selected.size > 0)
				{
					foreach (Tile tile in this.grid.selected)
					{
						tile.die();
					}

					this.grid.selected.clear();
				}
				else
				{
					this.tile.die();
				}
			});
			context_menu.append(item_delete_tile);

			context_menu.show_all();
			context_menu.popup(null, this, null, 0, event.get_time());
			//context_menu.popup_at_pointer(event);		// FIXME: GTK
		}

	}

	/* Drag and drop -- source callbacks */

	private void on_drag_begin (Gtk.Widget widget, Gdk.DragContext context)
	{
		this.tile_being_dragged = true;
	}

	private void on_drag_end (Gtk.Widget widget, Gdk.DragContext context)
	{
		this.tile_being_dragged = false;
	}

	private void on_drag_data_get (Gtk.Widget widget, Gdk.DragContext context, Gtk.SelectionData selection_data, uint target_type, uint time)
	{
		switch (target_type)
		{
			case TileHost.DndTargetType.TILE_PTR:
				this.tile.@ref();					// Manually increase the reference count to account for the pointer that we're sending as the selection data.
				Tile[] _tile = {this.tile};
				selection_data.set(selection_data.get_target(), (int) sizeof(void *) * 8, (uint8[])(_tile));
				break;
			default:
				break;
		}
	}

	/* Drag and drop -- destination callbacks */
	private static Gdk.Atom? find_atom_with_name(string name, List<Gdk.Atom> list)
	{
		foreach (var atom in list)
		{
			if (atom.name() == name) return atom;
		}

		return null;
	}

	private bool on_drag_drop (Gtk.Widget widget, Gdk.DragContext context, int x, int y, uint time)
	{
		/* Don't accept a drop of we're already hosting a tile. */
		if (this.tile != null) return false;

		if (context.list_targets() == null) return false;

		Gdk.Atom? target_type = find_atom_with_name("com.github.albert-tomanek.openloop.tile.instance_ptr", context.list_targets());	//.nth_data(TileHost.DndTargetType.TILE_PTR);

		if (target_type == null) return false;	// No compatable target type

		/* Request the data from the source. */
		Gtk.drag_get_data (
			widget,         // will receive 'drag_data_received' signal
			context,        // represents the current state of the DnD
			target_type,    // the target type we want
			time            // time stamp
		);

		return true;
	}

	private void on_drag_data_received (Gtk.Widget widget, Gdk.DragContext context, int x, int y, Gtk.SelectionData selection_data, uint target_type, uint time)
    {
		bool delete_source = false, success = true;

        /* Deal with what we are given from source */
        if (selection_data.get_length() >= 0)
		{
            switch (target_type) {
				case TileHost.DndTargetType.TILE_PTR:
				{
					Tile tile = ((Tile[]) selection_data.get_data())[0];
					tile.unref();

					if (tile.host != null)			// WARNING: The tile will be removed from its old host regardless of whether `context.get_suggested_action() == Gdk.DragAction.MOVE` or not.
						tile.host.release();

					this.attach(tile);
					break;
				}
	            default:
					GLib.printerr("Incompatable data dropped.\n");
					success = false;
	                break;
            }
        }

        Gtk.drag_finish (context, success, delete_source, time);
	}

	/* Drawing */

	public override bool draw (Cairo.Context context)
	{
		if (this.tile != null/* && !this.tile_being_dragged*/)
		{
			this.tile.draw(context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);

			if (this.tile.selected)
				this.tile.draw_border(context, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET, TILE_BORDER_WIDTH + TILE_BORDER_OFFSET);
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
}
