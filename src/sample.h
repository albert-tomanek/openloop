#pragma once
#include <stdint.h>

typedef struct
{
	uint32_t samplerate;
	uint8_t  channels;
	size_t   size;

	float *data;
} Sample;

void sample_free(Sample *sample);

Sample *sample_load_raw(const char *path, uint32_t samplerate, uint8_t channels);	// Temporary solution.
float  *sample_visual_repr (Sample *that, uint16_t width, int *out_length);

size_t sample_frame_size(Sample *sample);
size_t sample_length(Sample *sample);		// In frames
