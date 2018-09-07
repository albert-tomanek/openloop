#include <stdio.h>
#include <stdlib.h>

#include "sample.h"

void sample_free(Sample *sample)
{
	free(sample->data);
	free(sample);
}

Sample *sample_load_raw(const char *path, uint32_t samplerate, uint8_t channels)
{
	Sample *sample = (Sample *) calloc(1, sizeof(Sample));

	sample->samplerate = samplerate;
	sample->channels = channels;
	FILE *file = fopen(path, "r");

	if (! file) { fprintf(stderr, "Error opening file!\n"); exit(1); }

	/* Go to the end of the file to get its length */
	fseek(file, 0L, SEEK_END);
	sample->size = ftell(file);

	rewind(file);

	/* Read the data */
	sample->data = (float *) malloc(sample->size);

	fread(sample->data, 1, sample->size, file);

	fclose(file);

	return sample;
}

float *sample_visual_repr (Sample *that, uint16_t width, int *out_length)
{
	*out_length = width;	// Just used by Vala to know the array length

	/* Creates a visual representation of a sample by averaging all	*
	 * samples in the first channel and splitting the averages into	*
	 * `width` blocks. For usage see OpenLoop.LoopTile.draw_sample.	*/

	float *repr = malloc(width * sizeof(float));

	float sum;
	size_t block_size = (sample_length(that) / width);		// This many frames represented by one pixel on the tile
																				// NOTE: Sample = a single value representing the state of one channel; frame = the state of all channels (two consecutive floats in the case of stereo data)
	float *sample = that->data;

	for (uint32_t x = 0, i; x < width; x++)
	{
		sum = 0;

		for (i = 0; i < block_size * that->channels; i++)
		{
			sum += *sample;
			sample++;	// We only visualize the first channel, so skip the other samples in the frame
		}

		repr[x] = sum / i;
	}

	return repr;
}

size_t sample_frame_size(Sample *sample)
{
	return (sample->channels * sizeof(float));
};

size_t sample_length(Sample *sample)
{
	return (sample->size / sample_frame_size(sample));
};
