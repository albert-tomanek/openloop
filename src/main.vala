class OpenLoop.App : Gtk.Application
{
	public static MainWindow ui;
	public static AppPipeline pipeline;		// The GStreamer pipeline that all tiles feed their audio into.

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

		/* Default settings */
		App.internal_fmt.set_format(Gst.Audio.Format.F32, 48000, 2, null);
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
}
