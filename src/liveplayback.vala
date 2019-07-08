class OpenLoop.LivePlayback
{
	private GES.Timeline timeline;

	public LivePlayback(GES.Timeline timeline)
	{
		this.timeline = timeline;
	}

	public void add_clip(GES.Clip clip)
	{
		/* Clips loop indefinitely and we don't know whether the'll overlap each other,	*
		 * so we need to create a new layer for each clip.								*/

		 weak GES.Layer layer = this.timeline.append_layer();
		 layer.add_clip(clip);
	}

	public void remove_clip(GES.Clip clip)
	{
		var layer = clip.layer;
		layer.remove_clip(clip);
		this.timeline.remove_layer(layer);
	}
}
