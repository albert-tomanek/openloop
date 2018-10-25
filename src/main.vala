class OpenLoop.App : Gtk.Application
{
	public static bool dev_mode = true;

	public static AppThreads threads = new AppThreads();
	public static MainWindow ui;
	public static AppPipeline pipeline;		// The GStreamer pipeline that all tiles feed their audio into.

	public static Metronome metronome;
	private static Gee.ArrayQueue<ScheduledEvents.Event> on_next_bar = new Gee.ArrayQueue<ScheduledEvents.Event>();	// Events that need to happen at the start of the next bar.

	/* Audio settings */
	public static Gst.Audio.Info internal_fmt = new Gst.Audio.Info();

    public App ()
	{
        Object (
            application_id: "com.github.albert-tomanek.openloop",
            flags: ApplicationFlags.FLAGS_NONE
        );

		App.ui = new MainWindow();
		App.pipeline = new AppPipeline();
		App.pipeline.error.connect((msg) => { stderr.printf(msg); });

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

    public static int main (string[] args)
	{
		Gst.init(ref args);
		Gtk.init(ref args);

        var app = new App ();
        return app.run (args);
    }

	private void on_bar()
	{
		foreach (ScheduledEvents.Event event in App.on_next_bar)
		{
			event.execute();
		}

		App.on_next_bar.clear();
	}

	public static void schedule(ScheduledEvents.Event event)
	{
		App.on_next_bar.add(event);
	}
}
