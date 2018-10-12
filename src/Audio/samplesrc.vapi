/* See sampleplayer.h for target struct. */

[CCode (cname="SampleSrc", cheader_filename = "samplesrc.h")]
class OpenLoop.Audio.SampleSrc : Gst.App.Src
{
	public bool playing;
	public Audio.Sample sample;
	public uint64 playback_offset;

	[CCode (cname = "samplesrc_new")]
	public SampleSrc (OpenLoop.Audio.Sample sample);

	[CCode (cname = "samplesrc_start")]
	public void start ();
	[CCode (cname = "samplesrc_stop")]
	public void stop ();
	[CCode (cname = "samplesrc_rewind")]
	public void rewind ();

	/* Properties */
	public Gst.Element gst_element { /*[CCode (cname = "sampleplayer_get_element")]*/ get { return this; } }
	public float progress { [CCode (cname = "samplesrc_get_progress")] get; }
}
