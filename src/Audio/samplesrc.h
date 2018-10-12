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
#include <gst/app/gstappsrc.h>

#include "sample.h"

// https://github.com/yashi/gobject-subclass-example/blob/master/myfoo.c

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE (SampleSrc, samplesrc, , SAMPLESRC, GstAppSrc)

/* Static class members */
struct _SampleSrcClass
{
  GObjectClass parent_class;
};

/* Instace class members */
struct _SampleSrc
{
	GstAppSrc base;				// Parent class; has to come first

	Sample *sample;				// The current sample is NOT freed upon destruction; the sample may change over the lifetime of the SampleSrc
	uint64_t playback_offset;	// Playback offset in BYTES

	bool playing;
};

#define OPENLOOP_TYPE_SAMPLESRC (samplesrc_get_type())

static void samplesrc_class_init (SampleSrcClass *cls);
static void samplesrc_init (SampleSrc *that);
SampleSrc *samplesrc_new (Sample *sample);
void samplesrc_dispose (GObject *gobj);

void samplesrc_push_data (GstElement *source, guint size, SampleSrc *that);	// Callback to push data (either silence or samples) into the AppSrc element. No reason to call this from Vala.

void samplesrc_start  (SampleSrc *player);
void samplesrc_stop   (SampleSrc *player);
void samplesrc_rewind (SampleSrc *player);

/* Properties */
float      samplesrc_get_progress (SampleSrc *player);		// Returns how far the player is through the sample as a float between 0 and 1.0

G_END_DECLS
