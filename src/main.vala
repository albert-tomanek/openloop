class OpenLoop.App : Gtk.Application
{
	public static bool dev_mode = true;

	public static AppThreads threads = new AppThreads();
	public static MainWindow ui;

	public static GES.Pipeline pipeline;
	public static GES.Timeline timeline;
	public static GES.Project  ges_project;

	public static Metronome metronome;
	public static LivePlayback live_playback;

	public bool playing { get; set; }

	/* Audio settings */
	public static Gst.Audio.Info internal_fmt = new Gst.Audio.Info();

    public App ()
	{
        Object (
            application_id: "com.github.albert-tomanek.openloop",
            flags: ApplicationFlags.FLAGS_NONE
        );

		App.ui = new MainWindow();

		App.timeline = new GES.Timeline();
		App.pipeline = new GES.Pipeline();
		App.pipeline.set_timeline(App.timeline);
		App.pipeline.set_state(Gst.State.PLAYING);
		App.ges_project = App.timeline.get_asset() as GES.Project;

		App.live_playback = new LivePlayback(App.timeline);

		App.metronome = new Metronome();
		App.metronome.bar.connect(this.on_bar);

		/* Default settings */
		App.internal_fmt.set_format(Gst.Audio.Format.F32, 48000, 2, null);

		/* Threads */
		App.threads.start();

		this.shutdown.connect(() => { App.threads.stop(); });
    }

    protected override void activate ()
	{
		App.ui.create(this);
    }

	private void on_bar()
	{
	}

    public static int main (string[] args)
	{
		Gtk.init(ref args);
		Gst.init(ref args);
		GES.init();

        var app = new App ();
        return app.run (args);
    }
}
