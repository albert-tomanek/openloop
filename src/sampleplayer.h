/* Wrapper around the GStreamer AppSrc element		*
 * which is used by OpenLoop to play sample data.	*
 * Depending on whether ->playing is true or false,	*
 * the element will either send bits of the sample	*
 * or silence down the pipeline. (it timespamps		*
 * buffers). It is essential that there is no queue	*
 * in the pipeline else it would delay playback.	*
 * The element does not send an EOS down the pipel-	*
 * -ine when finished, since the pipeline that is	*
 * intended for has an audiomixer that other, still	*
 * playing elements feed to.						*/

#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <gst/gstelement.h>

#include "sample.h"

typedef struct
{
	Sample *sample;				// The current sample is NOT freed upon destruction; the sample may change over the lifetime of the SamplePlayer
	uint64_t playback_offset;	// Playback offset in BYTES

	/* GStreamer stuff */
	GstElement *bin;
	GstElement *app_source;

	bool playing;
} SamplePlayer;

SamplePlayer *sampleplayer_new (Sample *sample);
void sampleplayer_free (SamplePlayer *player);

void sampleplayer_push_data (GstElement *source, guint size, SamplePlayer *that);	// Callback to push data (either silence or samples) into the AppSrc element. No reason to call this from Vala.
void sampleplayer_rewind (SamplePlayer *player);

/* Properties */
GstElement *sampleplayer_get_element (SamplePlayer *player);		// Returns a GStreamer Bin element that encapsulates the sample player and can be put into a pipeline.
Sample     *sampleplayer_get_sample ();
uint64_t    sampleplayer_get_playback_offset ();
