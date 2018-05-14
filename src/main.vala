class OpenLoop.App : Gtk.Application
{
	AppUI ui;

    public App ()
	{
        Object (
            application_id: "com.github.albert-tomanek.openloop",
            flags: ApplicationFlags.FLAGS_NONE
        );

		this.ui = new AppUI(this);
    }

    protected override void activate ()
	{
		this.ui.create();
    }

    public static int main (string[] args)
	{
        var app = new App ();
        return app.run (args);
    }
}
