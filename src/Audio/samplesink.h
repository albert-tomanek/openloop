/* This is a GStreamer sink element that stores audio to a sample */

#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <gst/gstelement.h>
#include <gst/app/gstappsink.h>

#include "sample.h"

typedef struct
{
	GstAppSink base;
} SampleSink;

SampleSink *samplesink_new(Sample *sample);
