#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "sample.h"

#define GROW_SIZE 262144	// Grow the sample by 256k every time data is appended to it

Sample *sample_new()
{
	Sample *sample = malloc(sizeof(Sample));

	sample->samplerate = 0;
	sample->channels   = 0;
	sample->size       = 0;
	sample->allocated  = 0;

	sample->data = NULL;

	return sample;
}

void sample_free(Sample *sample)
{
	free(sample->data);
	free(sample);
}

void sample_append(Sample *sample, float *data, size_t size)
{
	/* Append sample data to the sample */

	/* Grow if more space is needed */
	while (sample->size + size > sample->allocated)
	{
		sample->data = realloc(sample->data, sample->allocated + GROW_SIZE);
		sample->allocated += GROW_SIZE;
	}

	/* Copy the data in */
	memcpy(((uint8_t *) sample->data) + sample->size, data, size);
	sample->size += size;
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
	sample->allocated = sample->size;

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
