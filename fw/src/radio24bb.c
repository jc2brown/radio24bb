
#include <stdlib.h>

#include "radio24bb.h"

#include "xadcps.h"
#include "xadc.h"




void init_radio24bb_regs(struct radio24bb_regs *regs) {

}


struct radio24bb *make_radio24bb(uint32_t regs_addr) {	
	struct radio24bb *r24bb = (struct radio24bb *)malloc(sizeof(struct radio24bb));

	r24bb->xadc = (XAdcPs *)malloc(sizeof(XAdcPs));

	r24bb->regs = (struct radio24bb_regs *)regs_addr;
	init_radio24bb_regs(r24bb->regs);
	return r24bb;
}








void init_radio24bb(struct radio24bb *r24bb) {
	init_radio24bb_regs(r24bb->regs);
}


