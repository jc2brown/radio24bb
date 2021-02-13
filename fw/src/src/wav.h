
#include <stdint.h>
#include "ff.h"

#ifndef WAV_H
#define WAV_H

struct wav_riff {
	char id[4];
	uint32_t size;
	uint8_t format[4];
};

struct wav_fmt {
	char id[4];
	uint32_t size;
	uint16_t audio_format;
	uint16_t num_channels;
	uint32_t sample_rate;
	uint32_t byte_rate;
	uint16_t block_align;
	uint16_t bits_per_sample;
};

struct wav_data { 
	char id[4];
	uint32_t size;
	uint8_t *buf;
};

struct WAV {
	struct wav_riff riff;
	struct wav_fmt fmt;
	struct wav_data data;
};




void read_wav_header_from_file(struct WAV *wav, FIL *f);

void print_wav_header(struct WAV *wav);


// If wav is NULL, the header will be read into a temporary location
// Otherwise the header will be read into wav
void wavstat(char *path, struct WAV *wav);


#endif
