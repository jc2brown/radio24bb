

#include "xspips.h"



#ifndef AIC3204_H
#define AIC3204_H



struct aic3204 {
	XSpiPs *spips;
	uint8_t page;
};




struct aic3204 *make_aic3204();
int init_aic3204(struct aic3204 *aic, XSpiPs *spips);




#endif
