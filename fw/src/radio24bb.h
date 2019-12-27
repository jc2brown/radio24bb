

#ifndef R24BB_H
#define R24BB_H

#include "xadcps.h"


struct radio24bb {	
	XAdcPs *xadc;
	struct radio24bb_regs *regs;
};


struct radio24bb_regs {


};




struct radio24bb *make_radio24bb(uint32_t regs_addr);

void init_radio24bb(struct radio24bb *r24bb);








#endif
