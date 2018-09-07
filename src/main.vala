weak OpenLoop.AppPipeline app_pipeline;

class OpenLoop.App : Gtk.Application
{
	internal AppUI ui;
	internal AppPipeline pipeline;		// The GStreamer pipeline that all tiles feed their audio into.

    public App ()
	{
        Object (
            application_id: "com.github.albert-tomanek.openloop",
            flags: ApplicationFlags.FLAGS_NONE
        );

		this.ui = new AppUI(this);
		this.pipeline = new AppPipeline();
		app_pipeline = this.pipeline;
		this.pipeline.error.connect((msg) => { stderr.printf(msg); });
    }

    protected override void activate ()
	{
		this.ui.create();
    }

    public static int main (string[] args)
	{
		Gst.init(ref args);
		Gtk.init(ref args);

        var app = new App ();
        return app.run (args);
    }
}
