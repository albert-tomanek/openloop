/* See sample.h for target struct. */

[CCode (cname="Sample", free_function = "sample_free", cheader_filename = "sample.h")]
[Compact]
class OpenLoop.Audio.Sample
{
	public uint32 samplerate;
	public uint8  channels;
	public ulong  size;

	public ulong length     { [CCode (cname = "sample_length")] get; }

	[CCode (cname = "sample_new")]
	public Sample();

	[CCode (cname = "sample_load_raw")]
	public static Sample load_raw (string path, uint32 samplerate, uint8 channels);

	[CCode (cname = "sample_visual_repr")]
	internal float[] visual_repr (uint16 width);
}
