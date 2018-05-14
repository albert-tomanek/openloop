/* See sampleplayer.h for target struct. */

[CCode (cname="SamplePlayer", free_function = "sampleplayer_free")]
[Compact]
class OpenLoop.Audio.SamplePlayer
{
	public bool playing;

	[CCode (cname = "sampleplayer_new")]
	public SamplePlayer (OpenLoop.Audio.Sample sample);

	[CCode (cname = "sampleplayer_rewind")]
	public void rewind ();

	/* Properties */
	public  Gst.Element gst_element { [CCode (cname = "sampleplayer_get_element")] get; }
	public  unowned OpenLoop.Audio.Sample sample   { [CCode (cname = "sampleplayer_get_sample")] get; }
	public  uint64 playback_offset  { [CCode (cname = "sampleplayer_get_playback_offset")] get; }
}
