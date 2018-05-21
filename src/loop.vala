/* A sound that may be embodied by multiple LoopTiles.	*/

class OpenLoop.Loop
{
	public OpenLoop.Audio.Sample orig_sample;	// ERROR HERE. The fact that it's in a .vapi causes it to include "appui.h" for some reason.

	public Loop (owned OpenLoop.Audio.Sample sample)
	{
		this.orig_sample = (owned) sample;		// Take ownership of the sample -- it's being given to us to keep.
	}
}
