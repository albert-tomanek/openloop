OpenLoop.Loop test_loop;
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

		/* Globals */
		test_loop = new OpenLoop.Loop(OpenLoop.Audio.Sample.load_raw("../media/wicked dub_f32s.raw", 44100, 2));
    }

    protected override void activate ()
	{
		this.ui.create();

		/* test tiles */
		// var host1 = new GUI.TileHost();
		// var tile  = new LoopTile(this.pipeline, test_loop);
		// this.pipeline.add(tile.player.gst_element);
		// host1.attach(tile);
		// this.ui.grid.attach(host1, 0, 0, 1, 1);
		//
		// var host2 = new GUI.TileHost();
		// this.ui.grid.attach(host2, 1, 0, 1, 1);
		var tilegrid  = new TileGrid(4, 3);
		this.ui.grid.attach(tilegrid, 0, 0, 1, 1);

		this.ui.grid.show_all();
    }

    public static int main (string[] args)
	{
		Gst.init(ref args);
		Gtk.init(ref args);

        var app = new App ();
        return app.run (args);
    }
}
