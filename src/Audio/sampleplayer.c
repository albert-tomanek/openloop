#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gst/gst.h>
#include <gst/app/gstappsrc.h>
#include <gst/audio/audio.h>

#include "sample.h"
#include "sampleplayer.h"

#define DEFAULT_CHUNK_SIZE 1024

// Inspiration: https://gist.github.com/floe/e35100f091315b86a5bf
// https://gstreamer.freedesktop.org/documentation/tutorials/basic/short-cutting-the-pipeline.html
// http://amarghosh.blogspot.cz/2012/01/gstreamer-appsrc-in-action.html

/* Constructor and Destructor */
SamplePlayer *sampleplayer_new (Sample *sample)
{
	SamplePlayer *that = malloc(sizeof(SamplePlayer));

	that->playing = false;

	that->sample = sample;
	that->playback_offset = 0;

	/* Create the GStreamer elements */
	that->bin        = gst_bin_new (NULL);
	that->app_source = gst_element_factory_make ("appsrc", NULL);

	/* Link them */
	gst_bin_add_many (GST_BIN(that->bin), that->app_source, NULL);

	/* We need to increment the bin's reference count from 1 to	*
	 * 2 so that it is present for the whole lifetime of the	*
	 * sampleplayer, even if the pipeline that will take		*
	 * ownership of it (when it is added to one) is deleted.	*/

	gst_object_ref(that->bin);

	/* Create a ghost pad (pad proxy) for the src pad at the end of the bin, which outside elements can link to */
	{
		GstPad *src_pad = gst_element_get_static_pad (that->app_source, "src");
		gst_element_add_pad (that->bin, gst_ghost_pad_new("src", src_pad));
		gst_object_unref(GST_OBJECT (src_pad));
	}

	/* Set AppSrc callbacks */
	g_signal_connect (that->app_source, "need-data", G_CALLBACK (sampleplayer_push_data), that);

	/* Configure our appsrc element */
	{
		GstAudioInfo info;		// that will hold information about the format of raw samples that we'll be feeding
		GstCaps *appsrc_caps;

		gst_audio_info_set_format (&info, GST_AUDIO_FORMAT_F32, (gint) that->sample->samplerate, (gint) that->sample->channels, NULL);
		appsrc_caps = gst_audio_info_to_caps (&info);

		g_object_set (that->app_source, "caps", appsrc_caps, "format", GST_FORMAT_TIME, NULL);
		gst_caps_unref(appsrc_caps);
	}

	return that;
}

void sampleplayer_free (SamplePlayer *that)
{
	/* De-initialize all the elements in our bin */
	gst_element_set_state (that->bin, GST_STATE_NULL);

	/* Decrement the reference count to 0 (unless any other references	*
	 * to the bin exist), to free the bin and its elements.				*/

    gst_object_unref (that->bin);

	free(that);
}

/* Other functions */

void sampleplayer_push_data (GstElement *source, guint size, SamplePlayer *that)
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
		g_signal_emit_by_name (that->app_source, "push-buffer", buffer, &ret);

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

void sampleplayer_rewind (SamplePlayer *that)
{
	that->playback_offset = 0;
}

/* Properties */
GstElement *sampleplayer_get_element (SamplePlayer *that)
{
	return that->bin;
}

float sampleplayer_get_progress (SamplePlayer *player)
{
	return (float) player->playback_offset / (float) player->sample->size;
}

Sample *sampleplayer_get_sample (SamplePlayer *that)
{
	return that->sample;
}

uint64_t sampleplayer_get_playback_offset (SamplePlayer *that)
{
	return that->playback_offset;
}
