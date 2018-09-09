#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gst/gst.h>
#include <gst/app/gstappsrc.h>
#include <gst/audio/audio.h>

#include "sample.h"
#include "samplesrc.h"

#define DEFAULT_CHUNK_SIZE 1024

// Inspiration: https://gist.github.com/floe/e35100f091315b86a5bf
// https://gstreamer.freedesktop.org/documentation/tutorials/basic/short-cutting-the-pipeline.html
// http://amarghosh.blogspot.cz/2012/01/gstreamer-appsrc-in-action.html

G_DEFINE_TYPE (SampleSrc, samplesrc, GST_TYPE_APP_SRC);

/* Constructor and Destructor */
void samplesrc_class_init(SampleSrcClass *cls)
{
}

void samplesrc_init (SampleSrc *that)
{
	/* Don't use this. To create a new istance use `samplesrc_new`. */
}

SampleSrc *samplesrc_new (Sample *sample)
{
	SampleSrc *that = g_object_new(OPENLOOP_TYPE_SAMPLESRC, NULL);//(SampleSrc *) g_type_create_instance(OPENLOOP_TYPE_SAMPLESRC);

	that->playing = false;

	that->sample = sample;
	that->playback_offset = 0;

	/* Set AppSrc callbacks */
	g_signal_connect (that, "need-data", G_CALLBACK (samplesrc_push_data), that);

	/* Configure our appsrc element */
	{
		GstAudioInfo info;		// that will hold information about the format of raw samples that we'll be feeding
		GstCaps *appsrc_caps;

		gst_audio_info_set_format (&info, GST_AUDIO_FORMAT_F32, (gint) that->sample->samplerate, (gint) that->sample->channels, NULL);
		appsrc_caps = gst_audio_info_to_caps (&info);

		g_object_set (that, "caps", appsrc_caps, "format", GST_FORMAT_TIME, NULL);
		gst_caps_unref(appsrc_caps);
	}

	return that;
}

void samplesrc_dispose (GObject *gobj)
{
	SampleSrc *that = (SampleSrc *) gobj;

	gst_element_set_state (GST_ELEMENT(that), GST_STATE_NULL);

	G_OBJECT_CLASS (samplesrc_parent_class)->dispose (gobj);
}

/* Other functions */

void samplesrc_push_data (GstElement *source, guint size, SampleSrc *that)
{
	/* that is called to push a chunk of	*
	 * sample data into the appsrc.			*/

	size_t frame_size = sizeof(float) * that->sample->channels;
	size_t chunk_size;				// How many bytes we're going to put into the CURRENT CHUNK
	size_t num_frames;				// How many frames fit into chunk_size.

	/* Firstly, check whether we've got to the end of the sample */
	if (that->playback_offset >= that->sample->size)
	{
		/* If we've got to the end of the sample */
		that->playback_offset = 0;	// Reset playback
		that->playing = false;		// Remember to end silence now that we've finished the sample
	}

	/* Calculate the size of the chunk we'll be sending */
	if (that->playing &&
		that->playback_offset + DEFAULT_CHUNK_SIZE > that->sample->size)
	{
		chunk_size = that->sample->size - that->playback_offset;
	}
	else
	{
		chunk_size = DEFAULT_CHUNK_SIZE;
	}

	/* Set the number of frames according to the chunk size */
	num_frames = chunk_size / frame_size;

	/* Create a new empty buffer */
	GstBuffer *buffer = gst_buffer_new();
	GstMemory *sample_data;					// Points to the Gstmemory object containing the final sample data that we'll push

	if (that->playing)
	{
		/* If we are playing, send memory containing the samples */
		sample_data = gst_memory_new_wrapped (GST_MEMORY_FLAG_READONLY, that->sample->data, that->sample->size, that->playback_offset, chunk_size, NULL, NULL);

		/* Increment the playback offset, now that these samples will be played */
		that->playback_offset += num_frames * frame_size;

		GST_BUFFER_OFFSET (buffer)     = that->playback_offset;
		GST_BUFFER_OFFSET_END (buffer) = that->playback_offset + chunk_size;		// The offset in the file of the end of that BUFFER
	}
	else
	{
		sample_data = gst_allocator_alloc(NULL, chunk_size, NULL);

		/* We need to initialize all of the samples to 0 (/silence), since the sample is not playing */
		GstMapInfo info;
		gst_memory_map (sample_data, &info, GST_MAP_WRITE);

		for (float *sample = (float *) info.data; sample < (float *)(info.data + chunk_size); sample++)		// We can't use memset to clear the memory here because we can't be sure that setting a float to {0x00, 0x00, 0x00, 0x00} makes its value 0.
		{
			*sample = 0;
		}

		gst_memory_unmap (sample_data, &info);
	}

	gst_buffer_append_memory (buffer, sample_data);


	/* Push the buffer into the appsrc */
	{
		GstFlowReturn ret;
		g_signal_emit_by_name (that, "push-buffer", buffer, &ret);

		if (ret != GST_FLOW_OK)
		{
			/* We got some error, stop sending data */
			fprintf(stderr, "ERROR: GstFlowReturn %d\n", ret);
			return;
		}
	}

	/* Free the buffer now that we are done with it */
	gst_buffer_unref (buffer);

	return;
}

void samplesrc_rewind (SampleSrc *that)
{
	that->playback_offset = 0;
}

/* Properties */
float samplesrc_get_progress (SampleSrc *player)
{
	return (float) player->playback_offset / (float) player->sample->size;
}
