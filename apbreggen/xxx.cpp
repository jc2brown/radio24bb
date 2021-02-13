
// GENERATED FILE: DO NOT MODIFY
// See https://github.com/thalmic/axireggen

#include <stdint.h>
#include "xil_types.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "xparameters.h"

#include "xxx.hpp"

//#include "iopacket/iopacket.h"
#ifdef IOPACKET_H
#include "iopacket/named_addr.h"
#endif

volatile UINTPTR * const __XxX_FRAME_WIDTH = &XxX_FRAME_WIDTH; // Active video + blanking
volatile UINTPTR * const __XxX_FRAME_HEIGHT = &XxX_FRAME_HEIGHT; // Active video + blanking
volatile UINTPTR * const __XxX_VFRONTPORCH_WIDTH = &XxX_VFRONTPORCH_WIDTH; 
volatile UINTPTR * const __XxX_VSYNC_WIDTH = &XxX_VSYNC_WIDTH; 
volatile UINTPTR * const __XxX_VBACKPORCH_WIDTH = &XxX_VBACKPORCH_WIDTH; 
volatile UINTPTR * const __XxX_HFRONTPORCH_WIDTH = &XxX_HFRONTPORCH_WIDTH; 
volatile UINTPTR * const __XxX_HSYNC_WIDTH = &XxX_HSYNC_WIDTH; 
volatile UINTPTR * const __XxX_HBACKPORCH_WIDTH = &XxX_HBACKPORCH_WIDTH; 
volatile UINTPTR * const __XxX_IMAGE_WIDTH = &XxX_IMAGE_WIDTH; // Active video only
volatile UINTPTR * const __XxX_IMAGE_HEIGHT = &XxX_IMAGE_HEIGHT; // Active video only
volatile UINTPTR * const __XxX_TEST_PATTERN_DESIRED_WIDTH = &XxX_TEST_PATTERN_DESIRED_WIDTH; 
volatile UINTPTR * const __XxX_TEST_PATTERN_DESIRED_HEIGHT = &XxX_TEST_PATTERN_DESIRED_HEIGHT; 
volatile UINTPTR * const __XxX_TEST_PATTERN_X_OFFSET = &XxX_TEST_PATTERN_X_OFFSET; 
volatile UINTPTR * const __XxX_TEST_PATTERN_Y_OFFSET = &XxX_TEST_PATTERN_Y_OFFSET; 
volatile UINTPTR * const __XxX_BOX_WIDTH = &XxX_BOX_WIDTH; 
volatile UINTPTR * const __XxX_BOX_HEIGHT = &XxX_BOX_HEIGHT; 
volatile UINTPTR * const __XxX_FG_COLOR = &XxX_FG_COLOR; 
volatile UINTPTR * const __XxX_BG_COLOR = &XxX_BG_COLOR; 
volatile UINTPTR * const __XxX_OUTLINE_MODE = &XxX_OUTLINE_MODE; 
volatile UINTPTR * const __XxX_OUTLINE_THICKNESS = &XxX_OUTLINE_THICKNESS; 

struct XxX_Params reset_XxX_params = {
    .FRAME_WIDTH = (uint64_t)0,
    .FRAME_HEIGHT = (uint64_t)0,
    .VFRONTPORCH_WIDTH = (uint64_t)0,
    .VSYNC_WIDTH = (uint64_t)0,
    .VBACKPORCH_WIDTH = (uint64_t)0,
    .HFRONTPORCH_WIDTH = (uint64_t)0,
    .HSYNC_WIDTH = (uint64_t)0,
    .HBACKPORCH_WIDTH = (uint64_t)0,
    .IMAGE_WIDTH = (uint64_t)0,
    .IMAGE_HEIGHT = (uint64_t)0,
    .TEST_PATTERN_DESIRED_WIDTH = (uint64_t)0,
    .TEST_PATTERN_DESIRED_HEIGHT = (uint64_t)0,
    .TEST_PATTERN_X_OFFSET = (uint64_t)0,
    .TEST_PATTERN_Y_OFFSET = (uint64_t)0,
    .BOX_WIDTH = (uint64_t)0,
    .BOX_HEIGHT = (uint64_t)0,
    .FG_COLOR = (uint64_t)100,
    .BG_COLOR = (uint64_t)0,
    .OUTLINE_MODE = (uint64_t)0,
    .OUTLINE_THICKNESS = (uint64_t)0x33,
};

void Set_XxX_Params(struct XxX_Params *params) {	
    XxX_FRAME_WIDTH = params->FRAME_WIDTH;
    XxX_FRAME_HEIGHT = params->FRAME_HEIGHT;
    XxX_VFRONTPORCH_WIDTH = params->VFRONTPORCH_WIDTH;
    XxX_VSYNC_WIDTH = params->VSYNC_WIDTH;
    XxX_VBACKPORCH_WIDTH = params->VBACKPORCH_WIDTH;
    XxX_HFRONTPORCH_WIDTH = params->HFRONTPORCH_WIDTH;
    XxX_HSYNC_WIDTH = params->HSYNC_WIDTH;
    XxX_HBACKPORCH_WIDTH = params->HBACKPORCH_WIDTH;
    XxX_IMAGE_WIDTH = params->IMAGE_WIDTH;
    XxX_IMAGE_HEIGHT = params->IMAGE_HEIGHT;
    XxX_TEST_PATTERN_DESIRED_WIDTH = params->TEST_PATTERN_DESIRED_WIDTH;
    XxX_TEST_PATTERN_DESIRED_HEIGHT = params->TEST_PATTERN_DESIRED_HEIGHT;
    XxX_TEST_PATTERN_X_OFFSET = params->TEST_PATTERN_X_OFFSET;
    XxX_TEST_PATTERN_Y_OFFSET = params->TEST_PATTERN_Y_OFFSET;
    XxX_BOX_WIDTH = params->BOX_WIDTH;
    XxX_BOX_HEIGHT = params->BOX_HEIGHT;
    XxX_FG_COLOR = params->FG_COLOR;
    XxX_BG_COLOR = params->BG_COLOR;
    XxX_OUTLINE_MODE = params->OUTLINE_MODE;
    XxX_OUTLINE_THICKNESS = params->OUTLINE_THICKNESS;	
	Flush_XxX_Params();
}

void Get_XxX_Params(struct XxX_Params *params) {
	Flush_XxX_Params();
    params->FRAME_WIDTH = XxX_FRAME_WIDTH;
    params->FRAME_HEIGHT = XxX_FRAME_HEIGHT;
    params->VFRONTPORCH_WIDTH = XxX_VFRONTPORCH_WIDTH;
    params->VSYNC_WIDTH = XxX_VSYNC_WIDTH;
    params->VBACKPORCH_WIDTH = XxX_VBACKPORCH_WIDTH;
    params->HFRONTPORCH_WIDTH = XxX_HFRONTPORCH_WIDTH;
    params->HSYNC_WIDTH = XxX_HSYNC_WIDTH;
    params->HBACKPORCH_WIDTH = XxX_HBACKPORCH_WIDTH;
    params->IMAGE_WIDTH = XxX_IMAGE_WIDTH;
    params->IMAGE_HEIGHT = XxX_IMAGE_HEIGHT;
    params->TEST_PATTERN_DESIRED_WIDTH = XxX_TEST_PATTERN_DESIRED_WIDTH;
    params->TEST_PATTERN_DESIRED_HEIGHT = XxX_TEST_PATTERN_DESIRED_HEIGHT;
    params->TEST_PATTERN_X_OFFSET = XxX_TEST_PATTERN_X_OFFSET;
    params->TEST_PATTERN_Y_OFFSET = XxX_TEST_PATTERN_Y_OFFSET;
    params->BOX_WIDTH = XxX_BOX_WIDTH;
    params->BOX_HEIGHT = XxX_BOX_HEIGHT;
    params->FG_COLOR = XxX_FG_COLOR;
    params->BG_COLOR = XxX_BG_COLOR;
    params->OUTLINE_MODE = XxX_OUTLINE_MODE;
    params->OUTLINE_THICKNESS = XxX_OUTLINE_THICKNESS;		
}

void Print_XxX_Params() {
	struct XxX_Params params;
	Get_XxX_Params(&params);
	Print_XxX_Param_struct(&params);
}

void Print_XxX_Param_struct(struct XxX_Params *params) {
    xil_printf("XxX_FRAME_WIDTH=%d\r\n", params->FRAME_WIDTH);
    xil_printf("XxX_FRAME_HEIGHT=%d\r\n", params->FRAME_HEIGHT);
    xil_printf("XxX_VFRONTPORCH_WIDTH=%d\r\n", params->VFRONTPORCH_WIDTH);
    xil_printf("XxX_VSYNC_WIDTH=%d\r\n", params->VSYNC_WIDTH);
    xil_printf("XxX_VBACKPORCH_WIDTH=%d\r\n", params->VBACKPORCH_WIDTH);
    xil_printf("XxX_HFRONTPORCH_WIDTH=%d\r\n", params->HFRONTPORCH_WIDTH);
    xil_printf("XxX_HSYNC_WIDTH=%d\r\n", params->HSYNC_WIDTH);
    xil_printf("XxX_HBACKPORCH_WIDTH=%d\r\n", params->HBACKPORCH_WIDTH);
    xil_printf("XxX_IMAGE_WIDTH=%d\r\n", params->IMAGE_WIDTH);
    xil_printf("XxX_IMAGE_HEIGHT=%d\r\n", params->IMAGE_HEIGHT);
    xil_printf("XxX_TEST_PATTERN_DESIRED_WIDTH=%d\r\n", params->TEST_PATTERN_DESIRED_WIDTH);
    xil_printf("XxX_TEST_PATTERN_DESIRED_HEIGHT=%d\r\n", params->TEST_PATTERN_DESIRED_HEIGHT);
    xil_printf("XxX_TEST_PATTERN_X_OFFSET=%d\r\n", params->TEST_PATTERN_X_OFFSET);
    xil_printf("XxX_TEST_PATTERN_Y_OFFSET=%d\r\n", params->TEST_PATTERN_Y_OFFSET);
    xil_printf("XxX_BOX_WIDTH=%d\r\n", params->BOX_WIDTH);
    xil_printf("XxX_BOX_HEIGHT=%d\r\n", params->BOX_HEIGHT);
    xil_printf("XxX_FG_COLOR=%d\r\n", params->FG_COLOR);
    xil_printf("XxX_BG_COLOR=%d\r\n", params->BG_COLOR);
    xil_printf("XxX_OUTLINE_MODE=%d\r\n", params->OUTLINE_MODE);
    xil_printf("XxX_OUTLINE_THICKNESS=0x%X\r\n", params->OUTLINE_THICKNESS);
}

void Reset_XxX_Params() {	
	Set_XxX_Params(&reset_XxX_params);
}

void Flush_XxX_Params() {
	Xil_DCacheFlushRange(XxX_BASEADDR, XxX_MAXOFFSET+8);
}

#ifdef IOPACKET_H
void Register_XxX_IOPacket_Addresses() {
    set_named_address("FRAME_WIDTH", (uint8_t*)(__XxX_FRAME_WIDTH), sizeof(XxX_FRAME_WIDTH));
    set_named_address("FRAME_HEIGHT", (uint8_t*)(__XxX_FRAME_HEIGHT), sizeof(XxX_FRAME_HEIGHT));
    set_named_address("VFRONTPORCH_WIDTH", (uint8_t*)(__XxX_VFRONTPORCH_WIDTH), sizeof(XxX_VFRONTPORCH_WIDTH));
    set_named_address("VSYNC_WIDTH", (uint8_t*)(__XxX_VSYNC_WIDTH), sizeof(XxX_VSYNC_WIDTH));
    set_named_address("VBACKPORCH_WIDTH", (uint8_t*)(__XxX_VBACKPORCH_WIDTH), sizeof(XxX_VBACKPORCH_WIDTH));
    set_named_address("HFRONTPORCH_WIDTH", (uint8_t*)(__XxX_HFRONTPORCH_WIDTH), sizeof(XxX_HFRONTPORCH_WIDTH));
    set_named_address("HSYNC_WIDTH", (uint8_t*)(__XxX_HSYNC_WIDTH), sizeof(XxX_HSYNC_WIDTH));
    set_named_address("HBACKPORCH_WIDTH", (uint8_t*)(__XxX_HBACKPORCH_WIDTH), sizeof(XxX_HBACKPORCH_WIDTH));
    set_named_address("IMAGE_WIDTH", (uint8_t*)(__XxX_IMAGE_WIDTH), sizeof(XxX_IMAGE_WIDTH));
    set_named_address("IMAGE_HEIGHT", (uint8_t*)(__XxX_IMAGE_HEIGHT), sizeof(XxX_IMAGE_HEIGHT));
    set_named_address("TEST_PATTERN_DESIRED_WIDTH", (uint8_t*)(__XxX_TEST_PATTERN_DESIRED_WIDTH), sizeof(XxX_TEST_PATTERN_DESIRED_WIDTH));
    set_named_address("TEST_PATTERN_DESIRED_HEIGHT", (uint8_t*)(__XxX_TEST_PATTERN_DESIRED_HEIGHT), sizeof(XxX_TEST_PATTERN_DESIRED_HEIGHT));
    set_named_address("TEST_PATTERN_X_OFFSET", (uint8_t*)(__XxX_TEST_PATTERN_X_OFFSET), sizeof(XxX_TEST_PATTERN_X_OFFSET));
    set_named_address("TEST_PATTERN_Y_OFFSET", (uint8_t*)(__XxX_TEST_PATTERN_Y_OFFSET), sizeof(XxX_TEST_PATTERN_Y_OFFSET));
    set_named_address("BOX_WIDTH", (uint8_t*)(__XxX_BOX_WIDTH), sizeof(XxX_BOX_WIDTH));
    set_named_address("BOX_HEIGHT", (uint8_t*)(__XxX_BOX_HEIGHT), sizeof(XxX_BOX_HEIGHT));
    set_named_address("FG_COLOR", (uint8_t*)(__XxX_FG_COLOR), sizeof(XxX_FG_COLOR));
    set_named_address("BG_COLOR", (uint8_t*)(__XxX_BG_COLOR), sizeof(XxX_BG_COLOR));
    set_named_address("OUTLINE_MODE", (uint8_t*)(__XxX_OUTLINE_MODE), sizeof(XxX_OUTLINE_MODE));
    set_named_address("OUTLINE_THICKNESS", (uint8_t*)(__XxX_OUTLINE_THICKNESS), sizeof(XxX_OUTLINE_THICKNESS));
}
#endif