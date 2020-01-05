
#include "xil_printf.h"

#include "ff.h"
#include "wav.h"




void read_wav_header_from_file(struct WAV *wav, FIL *f) {

	UINT bytes_to_read = sizeof(struct WAV) - sizeof(wav->data.buf); // Don't read data pointer from file
	UINT bytes_read;
	f_read(f, (uint8_t *)wav, bytes_to_read, &bytes_read);

	if (bytes_read != bytes_to_read) {
		xil_printf("ERROR: read_wav_header_from_file: expected %d bytes but got %d\n", bytes_to_read, bytes_read);
	}

}



void print_wav_header(struct WAV *wav) {
	xil_printf("\n");
	xil_printf("RIFF:\n");
	xil_printf("  ID: %.4s\n", wav->riff.id);
	xil_printf("  size: %d\n", wav->riff.size);
	xil_printf("  format: %d\n", (uint32_t)(wav->riff.format));
	xil_printf("FMT:\n");
	xil_printf("  ID: %.4s\n", wav->fmt.id);
	xil_printf("  size: %d\n", wav->fmt.size);
	xil_printf("  audio format: %d\n", wav->fmt.audio_format);
	xil_printf("  #channels: %d\n", wav->fmt.num_channels);
	xil_printf("  sample rate: %d\n", wav->fmt.sample_rate);
	xil_printf("  byte rate: %d\n", wav->fmt.byte_rate);
	xil_printf("  block align: %d\n", wav->fmt.block_align);
	xil_printf("  bits per sample: %d\n", wav->fmt.bits_per_sample);
	xil_printf("DATA:\n");
	xil_printf("  ID: %.4s\n", wav->data.id);
	xil_printf("  size: %d\n", wav->data.size);
	xil_printf("\n");
}


// If wav is NULL, the header will be read into a temporary location
// Otherwise the header will be read into wav
void wavstat(char *path, struct WAV *wav) {

	FILINFO fno;

	//f_stat(path, &fno);

	FIL f;
	f_open(&f, path, FA_READ);


	struct WAV _wav;
	if (wav == NULL) {
		wav = &_wav;
	}
	read_wav_header_from_file(wav, &f);
	print_wav_header(wav);

	if (strncmp(wav->riff.id, "RIFF", 4)) {
		xil_printf("ERROR: '%s' is not a wav file\n", path);
	}



	f_close(&f);


}
