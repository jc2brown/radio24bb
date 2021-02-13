
// GENERATED FILE: DO NOT MODIFY
// See https://github.com/thalmic/axireggen

#ifndef XXX_HPP
#define XXX_HPP

#include <stdint.h>
#include "xil_types.h"
#include "xil_printf.h"
#include "xparameters.h"

//#include "iopacket/iopacket.h"
#ifdef IOPACKET_H
#include "iopacket/named_addr.h"
#endif

#define XxX_BASEADDR ((u8*)0x40001200)
#define XxX_MAXOFFSET 0x0098

#define XxX_FRAME_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0000))) // Active video + blanking
#define XxX_FRAME_HEIGHT (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0008))) // Active video + blanking
#define XxX_VFRONTPORCH_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0010))) 
#define XxX_VSYNC_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0018))) 
#define XxX_VBACKPORCH_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0020))) 
#define XxX_HFRONTPORCH_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0028))) 
#define XxX_HSYNC_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0030))) 
#define XxX_HBACKPORCH_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0038))) 
#define XxX_IMAGE_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0040))) // Active video only
#define XxX_IMAGE_HEIGHT (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0048))) // Active video only
#define XxX_TEST_PATTERN_DESIRED_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0050))) 
#define XxX_TEST_PATTERN_DESIRED_HEIGHT (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0058))) 
#define XxX_TEST_PATTERN_X_OFFSET (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0060))) 
#define XxX_TEST_PATTERN_Y_OFFSET (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0068))) 
#define XxX_BOX_WIDTH (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0070))) 
#define XxX_BOX_HEIGHT (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0078))) 
#define XxX_FG_COLOR (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0080))) 
#define XxX_BG_COLOR (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0088))) 
#define XxX_OUTLINE_MODE (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0090))) 
#define XxX_OUTLINE_THICKNESS (*((volatile UINTPTR * const)(XxX_BASEADDR + 0x0098))) 

extern volatile UINTPTR * const __XxX_FRAME_WIDTH; // Active video + blanking
extern volatile UINTPTR * const __XxX_FRAME_HEIGHT; // Active video + blanking
extern volatile UINTPTR * const __XxX_VFRONTPORCH_WIDTH; 
extern volatile UINTPTR * const __XxX_VSYNC_WIDTH; 
extern volatile UINTPTR * const __XxX_VBACKPORCH_WIDTH; 
extern volatile UINTPTR * const __XxX_HFRONTPORCH_WIDTH; 
extern volatile UINTPTR * const __XxX_HSYNC_WIDTH; 
extern volatile UINTPTR * const __XxX_HBACKPORCH_WIDTH; 
extern volatile UINTPTR * const __XxX_IMAGE_WIDTH; // Active video only
extern volatile UINTPTR * const __XxX_IMAGE_HEIGHT; // Active video only
extern volatile UINTPTR * const __XxX_TEST_PATTERN_DESIRED_WIDTH; 
extern volatile UINTPTR * const __XxX_TEST_PATTERN_DESIRED_HEIGHT; 
extern volatile UINTPTR * const __XxX_TEST_PATTERN_X_OFFSET; 
extern volatile UINTPTR * const __XxX_TEST_PATTERN_Y_OFFSET; 
extern volatile UINTPTR * const __XxX_BOX_WIDTH; 
extern volatile UINTPTR * const __XxX_BOX_HEIGHT; 
extern volatile UINTPTR * const __XxX_FG_COLOR; 
extern volatile UINTPTR * const __XxX_BG_COLOR; 
extern volatile UINTPTR * const __XxX_OUTLINE_MODE; 
extern volatile UINTPTR * const __XxX_OUTLINE_THICKNESS; 

struct XxX_Params {
    uint64_t FRAME_WIDTH;
    uint64_t FRAME_HEIGHT;
    uint64_t VFRONTPORCH_WIDTH;
    uint64_t VSYNC_WIDTH;
    uint64_t VBACKPORCH_WIDTH;
    uint64_t HFRONTPORCH_WIDTH;
    uint64_t HSYNC_WIDTH;
    uint64_t HBACKPORCH_WIDTH;
    uint64_t IMAGE_WIDTH;
    uint64_t IMAGE_HEIGHT;
    uint64_t TEST_PATTERN_DESIRED_WIDTH;
    uint64_t TEST_PATTERN_DESIRED_HEIGHT;
    uint64_t TEST_PATTERN_X_OFFSET;
    uint64_t TEST_PATTERN_Y_OFFSET;
    uint64_t BOX_WIDTH;
    uint64_t BOX_HEIGHT;
    uint64_t FG_COLOR;
    uint64_t BG_COLOR;
    uint64_t OUTLINE_MODE;
    uint64_t OUTLINE_THICKNESS;	
};

extern struct XxX_Params reset_XxX_params;

void Set_XxX_Params(struct XxX_Params *params);
void Get_XxX_Params(struct XxX_Params *params);
void Print_XxX_Params(void);
void Print_XxX_Param_struct(struct XxX_Params *params);	
void Reset_XxX_Params(void);
void Flush_XxX_Params(void);

#ifdef IOPACKET_H
void Register_XxX_IOPacket_Addresses(void);
#endif

#endif
