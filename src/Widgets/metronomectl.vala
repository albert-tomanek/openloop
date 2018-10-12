class OpenLoop.GUI.MetronomeControl : Gtk.Box
{
	public weak Metronome metronome;

	public Gtk.ToggleButton snd_button;
	public Gtk.SpinButton bpm_spinbut;

	public MetronomeControl (Metronome met)
	{
		this.orientation = Gtk.Orientation.HORIZONTAL;
		this.spacing = 0;

		this.metronome = met;

		/* Style */
		var style = this.get_style_context ();
        style.add_class (Gtk.STYLE_CLASS_LINKED);
        style.add_class ("raised");

		this.snd_button = new Gtk.ToggleButton();
		this.snd_button.image = new Gtk.Image.from_pixbuf(new Gdk.Pixbuf.from_file_at_size("../media/metronome.svg", 14, 14));
		this.snd_button.get_style_context().remove_class("image-button");
		this.snd_button.get_style_context().add_class("suggested-action");
		this.snd_button.active = this.metronome.sound;
		this.snd_button.toggled.connect(() => { this.metronome.sound = this.snd_button.active; });
		this.add(this.snd_button);

		this.bpm_spinbut = new Gtk.SpinButton.with_range(1, 256, 1);
		this.bpm_spinbut.value = this.metronome.bpm;
		this.bpm_spinbut.value_changed.connect(() => { this.metronome.bpm = (uint) this.bpm_spinbut.value; });
		this.add(this.bpm_spinbut);
	}
}
