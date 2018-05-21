class OpenLoop.AppPipeline
{
	private Gst.Pipeline pipeline;

	private Gst.Element mixer;
	private Gst.Element audioconvert;
	private Gst.Element sink;

	private weak Gst.PadTemplate? mixer_sink_templ;		// A template for sink pads connected to the audiomixer. We need this to dynamically add pads to it.

	public signal void error (string err_str);

	public AppPipeline ()
	{
		/* Create the pipeline and elements */
		this.pipeline = new Gst.Pipeline ("app_pipeline");

		this.mixer        = Gst.ElementFactory.make ("audiomixer", null);
		this.audioconvert = Gst.ElementFactory.make ("audioconvert", null);
		this.sink         = Gst.ElementFactory.make ("autoaudiosink", null);

		this.pipeline.add_many (this.mixer, this.audioconvert, this.sink);
		//this.mixer.link_many (this.audioconvert, this.sink);
		this.audioconvert.link(this.sink);

		/* Set the mixer up */
		this.mixer_sink_templ = this.mixer.get_pad_template ("sink_%u");

		/* Set the message callback */
		this.pipeline.get_bus().add_watch(GLib.Priority.DEFAULT, this.on_bus_message);

		//this.pipeline.set_state (Gst.State.PLAYING);
	}

	~AppPipeline()
	{
		this.pipeline.set_state (Gst.State.NULL);
	}

	public void add(Gst.Element element)
	{
		this.pipeline.add(element);
element.link(this.audioconvert);this.pipeline.set_state (Gst.State.PLAYING);
/*		Gst.Pad? mixer_sink_pad = this.mixer.request_pad(this.mixer_sink_templ, null, null);	// We request a sink pad from the audiomixer using the pad template that we aquired earlier.
		Gst.Pad? elem_src_pad   = element.get_static_pad("src");

		elem_src_pad.link(mixer_sink_pad);*/
	}

/*	public void remove(Gst.Element element)		!!!
	{
		this.pipeline.add(element);

		Gst.Pad? mixer_sink_pad = this.mixer.request_pad(this.mixer_sink_templ, null, null);	// We request a sink pad from the audiomixer using the pad template that we aquired earlier.
		Gst.Pad? elem_src_pad   = element.get_static_pad("src");

		elem_src_pad.link(mixer_sink_pad);
	}*/

	private bool on_bus_message (Gst.Bus bus, Gst.Message message)
	{
		switch (message.type)
		{
			case Gst.MessageType.ERROR:		// Trigger the error signal if we recieve an error from the pipeline
			{
				GLib.Error err;
				string debug_info;
				string err_str;		// We'll be passing this to the error signal.

				message.parse_error (out err, out debug_info);

				err_str = "Error received from element %s: %s\nDebug info: %s".printf(message.src.name, err.message, (debug_info ?? "none"));
				this.error(err_str);

				break;
			}
		}

		return true;
	}
}
