class OpenLoop.Views.MetronomeInfo : Gtk.Window
{
	private Gtk.Label beat_label;
	private Gtk.Label dur_label;
	private Gtk.Label bpm_label;

	public MetronomeInfo()
	{
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
		this.add(box);

		this.beat_label = new Gtk.Label(null);
		box.add(this.beat_label);
		this.dur_label = new Gtk.Label(null);
		box.add(this.dur_label);
		App.metronome.beat.connect(this.update_beat_label);
		this.update_beat_label();

		this.bpm_label  = new Gtk.Label(null);
		box.add(this.bpm_label);
		App.metronome.notify["bpm"].connect(this.update_bpm_label);
		this.update_bpm_label();

		this.show_all();
	}

	private void update_beat_label()
	{
		this.beat_label.label = "%u / %u".printf(App.metronome.beat_no, App.metronome.bpb);
		this.dur_label.label  = "Beat duration: %luus".printf((ulong) (App.pipeline.get_pipeline_clock().get_time() - App.metronome.last_beat));
	}

	private void update_bpm_label()
	{
		this.bpm_label.label = "%ubpm".printf(App.metronome.bpm);
	}
}
