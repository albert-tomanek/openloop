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
