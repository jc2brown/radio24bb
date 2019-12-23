


/*

#define INA_GAIN 			*((volatile uint32_t*)0x43C00008)
#define INA_OFFSET 			*((volatile uint32_t*)0x43C0000C)
#define INA_FILTER_COEF  	*((volatile uint32_t*)0x43C00010)

#define INA_STAT_CFG 		*((volatile uint32_t*)0x43C00020)
#define INA_STAT_MIN 		*((volatile uint32_t*)0x43C00024)
#define INA_STAT_MAX 		*((volatile uint32_t*)0x43C00028)
#define INA_STAT_LIMIT 		*((volatile uint32_t*)0x43C0002C)
#define INA_STAT_COUNT 		*((volatile uint32_t*)0x43C00030)



#define INB_GAIN 			*((volatile uint32_t*)0x43C00408)
#define INB_OFFSET 			*((volatile uint32_t*)0x43C0040C)
#define INB_FILTER_COEF  	*((volatile uint32_t*)0x43C00410)

#define INB_STAT_CFG 		*((volatile uint32_t*)0x43C00420)
#define INB_STAT_MIN 		*((volatile uint32_t*)0x43C00424)
#define INB_STAT_MAX 		*((volatile uint32_t*)0x43C00428)
#define INB_STAT_LIMIT 		*((volatile uint32_t*)0x43C0042C)
#define INB_STAT_COUNT 		*((volatile uint32_t*)0x43C00430)

*/

#define LEDS				*((volatile uint32_t*)0x43C04000)
/*

#define USB_WR_DATA			*((volatile uint32_t*)0x43C01100)
#define USB_WR_FULL 		*((volatile uint32_t*)0x43C01104)

#define USB_RD_DATA			*((volatile uint32_t*)0x43C01140)
#define USB_RD_EMPTY 		*((volatile uint32_t*)0x43C01144)


#define USB_WR_MUX 			*((volatile uint32_t*)0x43C01180)
*/


// 0: CPU/regs
// 1: INA
// 2: INA FILTERED
// 3: USB
//#define OUTA_MUX	 		*((volatile uint32_t*)0x43C01200)

#define DAC_CFG	 			*((volatile uint32_t*)0x43C04018)

#define DAC_DCE	 			*((volatile uint32_t*)0x43C0401C)

#define AUD_RATE 			*((volatile uint32_t*)0x43C04020)

/*
#define OUTA_RAW	 		*((volatile uint32_t*)0x43C01400)


#define REG_OUTA_WR_COUNT	*((volatile uint32_t*)0x43C01500)
#define REG_OUTB_WR_COUNT	*((volatile uint32_t*)0x43C01504)

#define REG_OUTA_DDS_CFG	*((volatile uint32_t*)0x43C01600)
#define REG_OUTA_DDS_STEP	*((volatile uint32_t*)0x43C01604)


*/



