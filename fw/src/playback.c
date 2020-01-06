
#include <stdlib.h>
#include "xil_printf.h"
#include "xstatus.h"

#include "roe.h"

#include "playback.h"
#include "ff.h"
#include "wav.h"

#include "xscugic.h"
#include "scugic.h"



#define PBK_BUF_CAPACITY 65536





char *playback_state_str(int state) {

	char *status_str = "UNKNOWN";
	switch (state) {
	case PBK_CLOSED: 
		status_str = "CLOSED";
		break;
	case PBK_OPENED: 
		status_str = "OPENED";
		break;
	case PBK_PLAYING: 
		status_str = "PLAYING";
		break;
	case PBK_STOPPED: 
		status_str = "STOPPED";
		break;
	case PBK_PAUSED: 
		status_str = "PAUSED";
		break;
	}
	return status_str;
}


int playback_elapsed_milliseconds(struct playback *pbk) {
	if (pbk->state != PBK_PLAYING) {
		return -1;
	}

	return (1000LL * pbk->bytes_played) / (pbk->wav.fmt.block_align * pbk->wav.fmt.sample_rate);
}


void decompose_time(int time_in_millis, int *hours, int *minutes, int *seconds, int *milliseconds) {

	*milliseconds = time_in_millis % 1000;
	int time_in_seconds = time_in_millis / 1000;

	*seconds = time_in_seconds % 60;
	int time_in_minutes = time_in_seconds / 60;

	*minutes = time_in_minutes % 60;
	int time_in_hours = time_in_minutes / 60;

	*hours = time_in_hours;

}


void print_formatted_time(int time_in_millis) {
	int hours;
	int minutes;
	int seconds;
	int milliseconds;
	decompose_time(time_in_millis, &hours, &minutes, &seconds, &milliseconds);
	xil_printf("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds);
}




void playback_print_info(struct playback *pbk) {
	char *status_str = playback_state_str(pbk->state);
	xil_printf("state: %s\n", status_str);
	xil_printf("elapsed: ");
	print_formatted_time(playback_elapsed_milliseconds(pbk));
	xil_printf("\n");
}



void playback_handle_info_cmd(void *arg, struct command *cmd) {
	struct playback *pbk = (struct playback *)arg;
	playback_print_info(pbk);
}



void playback_handle_open_cmd(void *arg, struct command *cmd) {
	struct playback *pbk = (struct playback *)arg;
	char *path = cmd->tokens[cmd->index++];
	playback_open(pbk, path);
}


void playback_handle_close_cmd(void *arg, struct command *cmd) {
	struct playback *pbk = (struct playback *)arg;
	playback_close(pbk);
}

void playback_handle_play_cmd(void *arg, struct command *cmd) {
	struct playback *pbk = (struct playback *)arg;

	// If no arguments given...
	if (cmd->index == cmd->num_tokens) {
		// play the current file if one is opened...
		if (pbk->state != PBK_CLOSED) {
			playback_play(pbk);
			return;
		// otherwise print a message and do nothing
		} else {
			xil_printf("ERROR: no file opened\n");
			return;
		}
	}

	// If arguments are given...
	else {
		char *path = cmd->tokens[cmd->index++];
		playback_open(pbk, path);
		playback_play(pbk);
	}
}


void playback_handle_stop_cmd(void *arg, struct command *cmd) {
	struct playback *pbk = (struct playback *)arg;
	playback_stop(pbk);
}


void playback_handle_pause_cmd(void *arg, struct command *cmd) {
	struct playback *pbk = (struct playback *)arg;
	playback_pause(pbk);
}







struct playback *make_playback() {

	struct playback *pbk = (struct playback *)malloc(sizeof(struct playback));
	if (pbk == NULL) return NULL;

	pbk->buf = (uint8_t *)malloc(PBK_BUF_CAPACITY);
	if (pbk == NULL) return NULL;

	return pbk;
}





void playback_open(struct playback *pbk, char *path) {

	// TODO: stat the given path and don't close the current file if the new path is not a wav file

	// Close the current file if opened
	if (pbk->state != PBK_CLOSED) {
		xil_printf("WARNING: closing previously-opened file\n");
		playback_close(pbk);
	}

	wavstat(path, &pbk->wav);
/*
	pbk->wav.data.buf = (uint8_t *)malloc(pbk->wav.data.size);
	if (pbk->wav.data.buf == NULL) {
		xil_printf("ERROR: failed to allocate %d bytes for data buffer\n", pbk->wav.data.size);
		return;
	}
	*/

	pbk->bytes_unread = pbk->wav.data.size;

	//FIL f;
	f_open(&pbk->fil, path, FA_READ);

	//pbk->burst_count = 0;
	pbk->state = PBK_OPENED;

}


#define MIN(x, y) (((x)<(y))?(x):(y))

// Playback buffers report themselves as "not full" when they have at least this many free bytes
// This sets the maximum size of DMA transfers from the software buffer to the hardware buffer
#define PBK_NOT_FULL_THRESH 		2048 // bytes 
#define PBK_MAX_DMA_TRANSFER_SIZE   PBK_NOT_FULL_THRESH  // bytes


// Read as many bytes as possible from the file into the software buffer
// without overflowing the buffer or reading past the end of the file.
// Return the number of bytes which were read from the file and added to the buffer.
int playback_fill_buffer(struct playback *pbk) {
	int buffer_space_available = PBK_BUF_CAPACITY - pbk->bytes_buffered;
	UINT bytes_to_read = MIN(buffer_space_available, pbk->bytes_unread);
	UINT bytes_read = 0;
	f_read(&(pbk->fil), pbk->buf, bytes_to_read, &bytes_read);
	pbk->buf_ptr = pbk->buf;
	pbk->bytes_buffered += bytes_read;
	pbk->bytes_unread -= bytes_read;
	return bytes_read;
}


// Fill the software buffer if it does not contain enough bytes to source a maximum-size DMA transfer
int playback_maybe_fill_buffer(struct playback *pbk) {

	// This doesn't work with the simple buffering scheme currently in use
	//if (pbk->bytes_buffered < PBK_MAX_DMA_TRANSFER_SIZE && pbk->bytes_unread > 0) {

	if (pbk->bytes_buffered == 0 && pbk->bytes_unread > 0) {
		return playback_fill_buffer(pbk);
	}
	return 0;
}




void playback_dma_transfer(struct playback *pbk) {

	playback_maybe_fill_buffer(pbk);

	int bytes_to_transfer = MIN(pbk->bytes_buffered, PBK_MAX_DMA_TRANSFER_SIZE);

	if (bytes_to_transfer == 0) {
		playback_stop(pbk);
		return;
	}


	pbk->bytes_buffered -= bytes_to_transfer;
	pbk->bytes_played += bytes_to_transfer;


	memset(&(pbk->dma_cmd), 0, sizeof(XDmaPs_Cmd));

	pbk->dma_cmd.ChanCtrl.SrcBurstSize = 4;
	pbk->dma_cmd.ChanCtrl.SrcBurstLen = 1;
	pbk->dma_cmd.ChanCtrl.SrcInc = 1;
	pbk->dma_cmd.ChanCtrl.DstBurstSize = 4;
	pbk->dma_cmd.ChanCtrl.DstBurstLen = 1;
	pbk->dma_cmd.ChanCtrl.DstInc = 0;
	pbk->dma_cmd.BD.SrcAddr = (u32)(pbk->buf_ptr);
	pbk->dma_cmd.BD.DstAddr = (u32)(pbk->hw_buf);
	pbk->dma_cmd.BD.Length = bytes_to_transfer;


	XDmaPs_Start(pbk->dmaps, pbk->dmaps_channel, &(pbk->dma_cmd), 0);
	/*
	// Simulate DMA transfer
	for (int i = 0; i < bytes_to_transfer/pbk->wav.fmt.block_align; ++i) {
		*pbk->hw_buf = ((uint32_t *)pbk->buf_ptr)[i];
	}
	*/

	pbk->buf_ptr += bytes_to_transfer;

}



void playback_dma_done_handler(unsigned int channel, XDmaPs_Cmd *dma_cmd, void *arg) {
	struct playback *pbk = (struct playback *)arg;

	CS_START();
	XScuGic_Enable(pbk->scugic, pbk->not_full_intr_id);
	CS_END();

}



void playback_buffer_not_full_handler(void *arg) {
	struct playback *pbk = (struct playback *)arg;

	CS_START();
	XScuGic_Disable(pbk->scugic, pbk->not_full_intr_id);
	CS_END();

	playback_dma_transfer(pbk);

}


void playback_play(struct playback *pbk) {

	if (pbk->state == PBK_CLOSED) {
		xil_printf("ERROR: playback_play: closed\n");
		return;
	}

	pbk->state = PBK_PLAYING;

	CS_START();
	XScuGic_Enable(pbk->scugic, pbk->not_full_intr_id);
	CS_END();



/*
	UINT bytes_to_read = pbk->wav.data.size;
	UINT bytes_read;

	f_read(&(pbk->fil), pbk->wav.data.buf, bytes_to_read, &bytes_read);

	if (bytes_read != bytes_to_read) {
		xil_printf("ERROR: playback_play: expected %d bytes but got %d\n", bytes_to_read, bytes_read);
	}
*/

/*

	for (int i = 0; i < pbk->wav.data.size/pbk->wav.fmt.block_align; i=i+1) {


		if (pbk->burst_count == 0) {
			while (*pbk->hw_buf_full);
		}

		// We can only get away with casting the uint8_t-filled data buffer to uint32_t
		// when the source file matches the 16 bits/sample * 2 channel format expected by pbka_data
		*pbk->hw_buf = ((uint32_t *)pbk->wav.data.buf)[i];

		pbk->burst_count += 1;
		if (pbk->burst_count == 512) {
			pbk->burst_count = 0;
		}
	}
*/
}


void playback_pause(struct playback *pbk) {

	if (pbk->state != PBK_PLAYING) {
		xil_printf("ERROR: playback_pause: not playing\n");
		return;
	}


	CS_START();
	XScuGic_Disable(pbk->scugic, pbk->not_full_intr_id);
	CS_END();

	pbk->state = PBK_PAUSED;

}




void playback_stop(struct playback *pbk) {

	if (pbk->state != PBK_PLAYING) {
		xil_printf("ERROR: playback_stop: not playing\n");
		return;
	}

	CS_START();
	XScuGic_Disable(pbk->scugic, pbk->not_full_intr_id);
	CS_END();

	pbk->state = PBK_STOPPED;

	pbk->buf_ptr = pbk->buf;
	pbk->bytes_buffered = 0;
	pbk->bytes_unread = pbk->wav.data.size;
	pbk->bytes_played = 0;

}



void playback_close(struct playback *pbk) {


	//free(pbk->wav.data.buf);

	pbk->state = PBK_CLOSED;

}






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
) {

	pbk->scugic = scugic;
	pbk->not_full_intr_id = not_full_intr_id;

	pbk->dmaps = dmaps;
	pbk->dmaps_channel = dmaps_channel;

	pbk->state = PBK_CLOSED;

	pbk->bytes_unread = 0;
	pbk->bytes_buffered = 0;
	pbk->bytes_played = 0;

	pbk->hw_buf = hw_buf;
	pbk->hw_buf_full = hw_buf_full;


	_return_if_error_(
		XScuGic_Connect(
			pbk->scugic, 
			pbk->not_full_intr_id, 
			(Xil_ExceptionHandler)playback_buffer_not_full_handler, 
			(void *)pbk
	));


	XDmaPs_SetDoneHandler(
		pbk->dmaps, 
		pbk->dmaps_channel, 
		playback_dma_done_handler, 
		(void *)pbk
	);




	struct cmd_context *playback_ctx = make_cmd_context(name, pbk);
	add_subcontext(parent_ctx, playback_ctx);

	add_command(playback_ctx, "info", playback_handle_info_cmd);
	add_command(playback_ctx, "open", playback_handle_open_cmd);
	add_command(playback_ctx, "close", playback_handle_close_cmd);
	add_command(playback_ctx, "play", playback_handle_play_cmd);
	add_command(playback_ctx, "pause", playback_handle_pause_cmd);
	add_command(playback_ctx, "stop", playback_handle_stop_cmd);


	return XST_SUCCESS;
}




