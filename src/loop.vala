/* A sound that may be embodied by multiple LoopTiles.	*/

class OpenLoop.Loop
{
	/* Metadata */
	public string name;

	public GES.Asset asset;

	/* Samples */
	public Audio.Sample orig_sample;

	public Loop (owned Audio.Sample sample)
	{
		this.orig_sample = (owned) sample;		// Take ownership of the sample -- it's being given to us to keep.
	}

	public Loop.from_asset(GES.Asset asset)
	{
		this.asset = asset;
	}

	public static Loop import_path(string path)
	{
		Audio.Sample sample = new Audio.Sample();

		{
			Gst.Pipeline pipeline = new Gst.Pipeline(null);
			Gst.Element uridecodebin, audioresample, audioconvert, samplesink;

			/* Create elements */
			uridecodebin  = Gst.ElementFactory.make ("uridecodebin", null);
			uridecodebin.set("uri", "file://" + path);
			audioresample = Gst.ElementFactory.make ("audioresample", null);
			audioconvert  = Gst.ElementFactory.make ("audioconvert", null);
			samplesink    = new Audio.SampleSink (sample);

			/* Link elements */
			pipeline.add_many(uridecodebin, audioresample, audioconvert, samplesink);
			audioresample.link_many(audioconvert, samplesink);

			uridecodebin.pad_added.connect((pad) => {pad.link(audioresample.get_static_pad("sink"));});

			pipeline.set_state(Gst.State.PLAYING);
//			pipeline.get_bus().message.connect((msg) => {print(Gst.MessageType.get_name(msg.type)+"\n"); if (msg.type == Gst.MessageType.ERROR) {Error error;string dbg; msg.parse_error(out  error, out dbg); print(error.message+"\n"+dbg+"\n");} });

			pipeline.get_bus().poll(Gst.MessageType.EOS, Gst.CLOCK_TIME_NONE);	// Wait for the stream to end.

			pipeline.set_state(Gst.State.NULL);
		}

		return new Loop((owned) sample);
	}
}
