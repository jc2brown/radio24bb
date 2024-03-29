
#ifndef PLAYBACK_H
#define PLAYBACK_H

#include "xscugic.h"
#include "xdmaps.h"
#include "command.h"

#include "ff.h"
#include "wav.h"


enum PlaybackState {
	PBK_CLOSED,
	PBK_OPENED,
	PBK_PLAYING,
	PBK_PAUSED,
	PBK_STOPPED
};




struct playback {

	XScuGic *scugic;
	int not_full_intr_id;

	XDmaPs *dmaps;
	XDmaPs_Cmd dma_cmd;
	int dmaps_channel;

	FIL fil;
	struct WAV wav;
	enum PlaybackState state;
	uint8_t *buf;
	uint8_t *buf_ptr;

	// int bytes_played;
	// int bytes_buffered;
	// int bytes_remaining;

	int bytes_unread;
	int bytes_buffered;
	int bytes_played;

	// int bytes_remaining;
	// int buf_size;
	// int burst_count;

	volatile uint32_t *hw_buf;
	volatile uint32_t *hw_buf_full;

};




struct playback *make_playback();


int init_playback(
		struct playback *pbk, 
		XScuGic *scugic, 
		XDmaPs *dmaps, 
		char *name,
		struct cmd_context *parent_ctx,
		int not_full_intr_id, 
		int dmaps_channel,
		volatile uint32_t *hw_buf, 
		volatile uint32_t *hw_buf_full
);


void playback_dma_done_handler(unsigned int channel, XDmaPs_Cmd *dma_cmd, void *arg);

void playback_open(struct playback *pbk, char *path);
void playback_play(struct playback *pbk) ;
void playback_pause(struct playback *pbk);
void playback_stop(struct playback *pbk);
void playback_close(struct playback *pbk);


#endif

