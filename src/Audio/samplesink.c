#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <gst/gst.h>
#include <gst/app/gstappsink.h>
#include <gst/audio/audio.h>

#include "sample.h"
#include "samplesink.h"

GstFlowReturn samplesink_receive_buffer (GstElement *app_sink, Sample *data);

SampleSink *samplesink_new(Sample *sample)
{
	GstElement *app_sink = gst_element_factory_make ("appsink", NULL);

	/* Set the receive buffer callback */
	g_object_set (app_sink, "emit-signals", TRUE, NULL);
	g_object_set (app_sink, "sync", FALSE, NULL);			// This causes us to ignore timestamps. Without this, the stream would play at normal playback speed, which would make loading samples VERY slow.
	g_signal_connect(app_sink, "new-sample", G_CALLBACK (samplesink_receive_buffer), sample);

	/* Set our caps */
	GstAudioInfo audio_info;
	gst_audio_info_set_format(&audio_info, GST_AUDIO_FORMAT_F32, 44800, 2, NULL);
	GstCaps *audio_caps = gst_audio_info_to_caps(&audio_info);
	g_object_set (app_sink, "caps", audio_caps, NULL);
	gst_caps_unref (audio_caps);

	/* Set our sample's metadata */
	sample->samplerate = audio_info.rate;
	sample->channels   = audio_info.channels;

	return (SampleSink *) app_sink;
}

GstFlowReturn samplesink_receive_buffer (GstElement *app_sink, Sample *sample)
{
	/* Called when we receive a buffer */
	GstSample *gst_sample;

	/* Retrieve the buffer */
	g_signal_emit_by_name (app_sink, "pull-sample", &gst_sample);

	if (gst_sample == NULL)
	{
		return GST_FLOW_ERROR;
	}
	else
	{
		GstBuffer *buffer = gst_sample_get_buffer(gst_sample);
		GstMapInfo info;

		if (buffer != NULL)
		{
			gst_buffer_map   (buffer, &info, GST_MAP_READ);

			sample_append(sample, (float *) info.data, info.size);

			gst_buffer_unmap (buffer, &info);
		}
	}

	gst_sample_unref (gst_sample);

	return GST_FLOW_OK;
}
