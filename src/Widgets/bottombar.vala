class OpenLoop.GUI.BottomBar : Gtk.ActionBar
{
	private Gtk.Button new_loop_button;

	public BottomBar()
	{
		this.new_loop_button = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.MENU);
		this.new_loop_button.clicked.connect(App.ui.import_loop);
		this.pack_start(this.new_loop_button);
	}
}
