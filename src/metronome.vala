class OpenLoop.Metronome : Object
{
	public uint bpm { get; set; default = 120; }
	public uint bpb { get; set; default = 4; }	// Beats per bar
	public uint beat_no = 0;	// The beat number [1 .. bpb]. 0 for the initial beat to be the start of a bar.

	public signal void beat();
	public signal void bar();

	public Gst.ClockTime last_beat;

	/* Threads */
	Thread<void *> thread;

	/* Audible */
	public  bool sound = false;
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
		this.thread = new Thread<void *>("metronome-thread", this.thread_func);

		this.beat.connect(() => {
			if (this.sound)
			{
				this.gst_smplsrc.rewind();
				this.gst_smplsrc.playing = true;
				//this.gst_smplsrc.start();	// It's already playing but flush the stream.
			}
		});
	}

	~Metronome()
	{
		this.gst_pipeline.set_state(Gst.State.NULL);
	}
public static uint64 d;
	private void *thread_func()
	{
		while (App.threads.running)
		{
			//print(@"$(App.pipeline.pipeline.get_pipeline_clock().get_time() - this.last_beat)\n");
			d=App.pipeline.pipeline.get_pipeline_clock().get_time();
			if (this.beat_no % this.bpb == 0)
			{
				this.beat_no = 1;
				this.bar();
			}
			else
			{
				this.beat_no++;
			}

			this.beat();

			this.last_beat = App.pipeline.pipeline.get_pipeline_clock().get_time();
print("%lu\n", (ulong) (last_beat - d));
			Thread.usleep(1000 * (60000 / this.bpm));
		}

		return null;
	}

	public Gst.ClockTime beat_duration()
	{
		return (60 * Gst.SECOND) / this.bpm;
	}

	public float beat_progress {
		get {
			return (float) (App.pipeline.pipeline.get_clock().get_time() - this.last_beat) / (float) this.beat_duration();
		}
	}
}
