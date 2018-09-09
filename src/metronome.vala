class OpenLoop.Metronome
{
	public uint bpm = 120;

	public signal void beat();

	/* Threads */
	Thread<void *> thread;

	/* Audible */
	public  bool sound = true;
	private Audio.Sample click_smpl = Audio.Sample.load_raw("media/click", 44100, 1);

	private Gst.Pipeline gst_pipeline;
	private Audio.SampleSrc gst_smplplayer;
	private Gst.Element  gst_audioconv;
	private Gst.Element  gst_audiosink;

	public Metronome()
	{
		/* Set up audio */
		this.gst_pipeline = new Gst.Pipeline("metronome");

		this.gst_smplplayer = new Audio.SampleSrc(this.click_smpl);
		this.gst_audioconv  = Gst.ElementFactory.make("audioconvert", null);
		this.gst_audiosink  = Gst.ElementFactory.make("autoaudiosink", null);

		this.gst_pipeline.add_many(this.gst_smplplayer, this.gst_audioconv, this.gst_audiosink);
		this.gst_smplplayer.link_many(this.gst_audioconv, this.gst_audiosink);

		this.gst_pipeline.set_state(Gst.State.PLAYING);

		/* Start the thread */
		this.thread = new Thread<void *>(null, this.thread_func);

		this.beat.connect(() => {
			if (this.sound)
			{print("Beat!\n");
				this.gst_smplplayer.rewind();
			}
		});
	}

	~Metronome()
	{
		this.gst_pipeline.set_state(Gst.State.NULL);
	}

	private void *thread_func()
	{
		while (App.threads.running)
		{
			this.beat();

			Thread.usleep(1000 * (60000 / this.bpm));
		}

		return null;
	}
}
