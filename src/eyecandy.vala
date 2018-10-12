using Math;

namespace OpenLoop.Eyecandy
{
	float get_highlight_intensity()
	{
		/* Returns a float between 0 and 1.	*
		 * Use this in GUI code to pulsate	*
		 * in time to the beat.				*/

		var x = (double) App.metronome.beat_progress;
		return (float) (cos(x * PI) / 7 + (6f / 7f));			// https://www.desmos.com/calculator/myz7wuhecm
	}
}
