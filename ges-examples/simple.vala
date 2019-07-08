/* Compile: valac -g simple.vala --pkg gio-2.0 --pkg gstreamer-1.0 --pkg gstreamer-pbutils-1.0 --pkg gst-editing-services-1.0 --vapidir ../vapi/ */

void main(string[] args)
{
	Gst.init(ref args);
	GES.init();

	var pipeline = new GES.Pipeline();
	var timeline = new GES.Timeline.audio_video();

	var tracka = new GES.AudioTrack();
	var trackv = new GES.VideoTrack();

	var layer1 = new GES.Layer();
	var layer2 = new GES.Layer();
	layer2.priority = 1;

	timeline.add_track(tracka);
	timeline.add_track(trackv);
	timeline.add_layer(layer1);
	timeline.add_layer(layer2);

	pipeline.set_timeline(timeline);

	var clip = new GES.UriClip(args[1]);
	if (clip == null) { printerr("Error loading URI\n"); return; }
	clip.duration = 5 * Gst.SECOND;
	clip.start    = 0 * Gst.SECOND;

	layer1.add_clip(clip);

	timeline.commit();	/* Commiting the timeline is always necessary for changes inside it to be taken into account by the Non Linear Engine */

	/* Play the timeline */
    Gst.Bus bus = pipeline.get_bus();

    pipeline.set_state(Gst.State.PLAYING);

    /* Simple way to just play the pipeline until EOS or an error pops on the bus */
    Gst.Message? msg = bus.timed_pop_filtered(10 * Gst.SECOND, Gst.MessageType.EOS | Gst.MessageType.ERROR);
	print(@"$(msg.type)");

    pipeline.set_state(Gst.State.NULL);
}
