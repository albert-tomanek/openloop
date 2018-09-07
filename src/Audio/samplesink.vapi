/* See samplesink.h */

[CCode (cname="SampleSink", cheader_filename = "samplesink.h")]
class OpenLoop.Audio.SampleSink : Gst.Element
{
	[CCode (cname = "samplesink_new")]
	public SampleSink (Sample sample);
}
