class OpenLoop.Metronome
{
	public uint bpm = 120;

	public signal void beat();

	/* Threads */
	Thread<void *> thread;

	/* Audible */
	public  bool sound = true;
	private Audio.Sample click_smpl = Audio.Sample.load_raw("../media/click", 44100, 1);

	private Gst.Pipeline gst_pipeline;
	private Audio.SampleSrc gst_smplsrc;
	private Gst.Element  gst_audioconv;
	private Gst.Element  gst_audiosink;

	public Metronome()
	{
		/* Set up audio */
		this.gst_pipeline = new Gst.Pipeline("metronome");

		this.gst_smplsrc = new Audio.SampleSrc(this.click_smpl);
		this.gst_smplsrc.playing = true;
		this.gst_audioconv  = Gst.ElementFactory.make("audioconvert", null);
		this.gst_audiosink  = Gst.ElementFactory.make("autoaudiosink", null);

		this.gst_pipeline.add_many(this.gst_smplsrc, this.gst_audioconv, this.gst_audiosink);
		this.gst_smplsrc.link_many(this.gst_audioconv, this.gst_audiosink);

		this.gst_pipeline.set_state(Gst.State.PLAYING);

		/* Start the thread */
		this.thread = new Thread<void *>(null, this.thread_func);

		this.beat.connect(() => {
			if (this.sound)
			{
				this.gst_smplsrc.rewind();
				this.gst_smplsrc.playing = true;
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
