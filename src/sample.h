#pragma once
#include <stdint.h>

typedef struct
{
	uint32_t samplerate;
	uint8_t  channels;
	size_t   size;

	float *data;
} Sample;

Sample *sample_load_raw(const char *path, uint32_t samplerate, uint8_t channels);	// Temporary solution.
void sample_free(Sample *sample);

inline size_t sample_frame_size(Sample *sample) { return (sample->channels * sizeof(float)); };
inline size_t sample_length(Sample *sample) { return (sample->size / sample_frame_size(sample)); };	// in frames
