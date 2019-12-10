/*
 * Empty C++ Application
 */


#include "xparameters.h"
#include "xparameters_ps.h"
#include "xgpiops.h"
#include "sleep.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "roe.h"

#include "regs.h"

#include "i2c.h"
#include "ina219.h"

#include "adc.h"
#include "dac.h"

#include "aic3204.h"

#include "command.h"


void loopa_handler(void *arg, struct command *cmd) {
	issue_command("outa src ina", NULL);
	issue_command("ina att 0", NULL);
	issue_command("outa att 0", NULL);
	issue_command("ina opt", NULL);
	issue_command("outa opt", NULL);
}



void info_handler(void *arg, struct command *cmd) {
	xil_printf("INFO\n");
}

void led_handler(void *arg, struct command *cmd) {

	int ina_led = 0;
	int inb_led = 0;
	int outa_led = 0;
	int outb_led = 0;

	char buf[64];

	for (int i = 0; i < 8; ++i) {

		sprintf(buf, "ina led %d", ina_led);
		ina_led = (ina_led + 1) % 8;
		issue_command(buf, NULL);

		sprintf(buf, "inb led %d", inb_led);
		inb_led = (inb_led + 1) % 8;
		issue_command(buf, NULL);

		sprintf(buf, "outa led %d", outa_led);
		outa_led = (outa_led + 1) % 8;
		issue_command(buf, NULL);

		sprintf(buf, "outb led %d", outb_led);
		outb_led = (outb_led + 1) % 8;
		issue_command(buf, NULL);

		usleep(100000);
	}

	issue_command("ina led 0", NULL);
	issue_command("inb led 0", NULL);
	issue_command("outa led 0", NULL);
	issue_command("outb led 0", NULL);

}


int main()
{

	xil_printf("\nHello\r\n");
	usleep(100000);

	_return_if_error_(spi_init());
	_return_if_error_(i2c_init());
	_return_if_error_(i2c_selftest());
	_return_if_error_(i2c_config());
	_return_if_error_(ina219_config());


	//init_aic3204();

	XGpioPs gpiops_inst;
	XGpioPs *gpiops_ptr = &gpiops_inst;

	XGpioPs_Config *gpiops_config = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	XGpioPs_CfgInitialize(gpiops_ptr, gpiops_config, gpiops_config->BaseAddr);


	XGpioPs_SetDirection(gpiops_ptr, 0, 0x0);
	XGpioPs_SetOutputEnable(gpiops_ptr, 0, 0x0);


	XGpioPs_SetDirection(gpiops_ptr, 1, 0xFFFFFFFF);
	XGpioPs_SetDirection(gpiops_ptr, 2, 0xFFFFFFFF);
	XGpioPs_SetDirection(gpiops_ptr, 3, 0xFFFFFFFF);

	XGpioPs_SetOutputEnable(gpiops_ptr, 1, 0xFFFFFFFF);
	XGpioPs_SetOutputEnable(gpiops_ptr, 2, 0xFFFFFFFF);
	XGpioPs_SetOutputEnable(gpiops_ptr, 3, 0xFFFFFFFF);

	/*
	XGpioPs_Write(gpiops_ptr, 0, 0xFFFFFFFF);
	XGpioPs_Write(gpiops_ptr, 1, 0xFFFFFFFF);
	XGpioPs_Write(gpiops_ptr, 2, 0xFFFFFFFF);
	XGpioPs_Write(gpiops_ptr, 3, 0xFFFFFFFF);

*/

	XGpioPs_Write(gpiops_ptr, 1, 0x0);
	XGpioPs_Write(gpiops_ptr, 2, 0x00);
	XGpioPs_Write(gpiops_ptr, 3, 0x00);
	usleep(500000);
	XGpioPs_Write(gpiops_ptr, 2, 0xFFFFFFFF);
	XGpioPs_Write(gpiops_ptr, 3, 0xFFFFFFFF);


	XGpioPs_WritePin(gpiops_ptr, 54, 1);	// INB ATT0
	XGpioPs_WritePin(gpiops_ptr, 55, 1);	// INB ATT1

	XGpioPs_WritePin(gpiops_ptr, 58, 1);  // INA ATT0
	XGpioPs_WritePin(gpiops_ptr, 59, 1);  // INA ATT1


	XGpioPs_WritePin(gpiops_ptr, 90, 1);	// USB_RESET_N



#define INA_REGS 0x43C00000UL
#define INB_REGS 0x43C01000UL


#define OUTA_REGS 0x43C02000UL
#define OUTB_REGS 0x43C03000UL

//	struct adc_channel_regs *ina_regs  = (struct adc_channel_regs *)(0x43C00000UL);
//	struct adc_channel_regs *inb_regs  = (struct adc_channel_regs *)(0x43C01000UL);


	//xil_printf()


	add_command(NULL, "loopa", loopa_handler);
	add_command(NULL, "info", info_handler);
	add_command(NULL, "led", led_handler);




	struct adc_channel *ina = make_adc_channel(INA_REGS);
	struct adc_channel *inb = make_adc_channel(INB_REGS);

	init_adc_channel_context("ina", ina, NULL);
	init_adc_channel_context("inb", inb, NULL);



	struct dac_channel *outa = make_dac_channel(OUTA_REGS);
	struct dac_channel *outb = make_dac_channel(OUTB_REGS);

	init_dac_channel_context("outa", outa, NULL);
	init_dac_channel_context("outb", outb, NULL);



//	struct dac_channel_regs *outa_regs = (struct dac_channel_regs *)OUTA_REGS;
//	struct dac_channel_regs *outb_regs = (struct dac_channel_regs *)OUTB_REGS;
//
//	init_adc_channel_context("ina", ina, NULL);
//	init_adc_channel_context("inb", inb, NULL);



//	init_adc_channel_regs(ina_regs);
//	init_adc_channel_regs(inb_regs);

//	init_dac_channel_regs(outa_regs);
//	init_dac_channel_regs(outb_regs);


/*
	*((volatile uint32_t*)0x43C02000ULL) = 255;
	*((volatile uint32_t*)0x43C02004ULL) = 0;


	*((volatile uint32_t*)0x43C0200CULL) = 4;
	*((volatile uint32_t*)0x43C02010ULL) = 0;

	for (int i = 0; i < 21; ++i) {
		*((volatile uint32_t*)0x43C02008ULL) = (uint32_t)(outa_filter0_coef[i] * (double)(1<<23));
	}



	*((volatile uint32_t*)0x43C02018ULL) = 0;//((1ULL<<32) / 99.99888e6) * 10.7e6;

	for (int i = 0; i < 4096; ++i) {
		//regs->dds_cfg = (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));

		*((volatile uint32_t*)0x43C02014ULL) = i;// (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));

	}

	//regs->dds_step = 4000000;//((1ULL<<32) / 99.99888e6) * 10.7e6;
	*((volatile uint32_t*)0x43C02018ULL) = 0;//((1ULL<<32) / 99.99888e6) * 10.7e6;
*/










/*
	INA_GAIN = 255;
	INB_GAIN = 1;
	*/

/*

	for (int i = 0; i < 21; ++i) {
		INA_FILTER_COEF = (uint32_t)(ina_filter2_coef[20-i] * (double)(1<<23));
	}*/

/*
	INA_FILTER_COEF = 1<<22;
	INA_FILTER_COEF = 1<<22;

	INB_FILTER_COEF = 1<<22;
	INB_FILTER_COEF = 1<<22;
*/

	DAC_DCE = 0;
	usleep(100000);


	DAC_CFG = 0x40;

	LEDS = 3;

	//*((volatile uint32_t*)(0x43C01000ULL)) = 0xFFFFFFFF;

/*
	for (uint32_t i = 0x43C00000; i < 0x43D00000; i=i+4) {

		*((volatile uint32_t*)(i)) = 0xFFFFFFFF;
	}*/




//#define REG_OUTA_DDS_CFG	*((volatile uint32_t*)0x43C01600)
//#define REG_OUTA_DDS_STEP	*((volatile uint32_t*)0x43C01604)



//
//	REG_OUTA_DDS_STEP = 0;
//
//	for (int i = 0; i < 4096; ++i) {
//		REG_OUTA_DDS_CFG = (int8_t)(127.0*sin((2.0*3.141*(double)i)/4096.0));
//	}
//
//	REG_OUTA_DDS_STEP = ((1ULL<<32) / 99.99888e6) * 10.7e6;
//


//
//
//	REG_OUTA_DDS_STEP = 0;
//
//	for (int i = 0; i < 4096; ++i) {
//		REG_OUTA_DDS_CFG = (int8_t)(  63.0*sin((9.0*2.0*3.141*(double)i)/4096.0)   +   63.0*sin((10.0*2.0*3.141*(double)i)/4096.0)  );
//	}
//
//
//	REG_OUTA_DDS_STEP = ((1ULL<<32) / 99.99888e6) * 10.7e6/9.5;
//



	XGpioPs_WritePin(gpiops_ptr, 72, 1);	// OUTA ATT0
	XGpioPs_WritePin(gpiops_ptr, 71, 1);	// OUTA ATT1
//
//
//	OUTA_MUX = 4;
//	OUTA_RAW = 0;



//	char line[1024];
//	char *tokens[16];








	issue_command("led", NULL);




	while (1) {



		handle_command();



	}


	return 0;
}


//		XGpioPs_WritePin(gpiops_ptr, 67, !XGpioPs_ReadPin(gpiops_ptr, 57)); // INB_R on DORB
//		XGpioPs_WritePin(gpiops_ptr, 68, !XGpioPs_ReadPin(gpiops_ptr, 61)); // INA_R on DORA




		/*

		fgets(line, 1024, stdin);
		int i = 0;
		tokens[i++] = line;
		for (char *c = line+1; *c != '\0'; ++c) {
			if (*c == ' ') {
				tokens[i++] = c+1;
			}
			if (*c == ' ' || *c == '\n') {
				*c = '\0';
			}
		}

		xil_printf("%d tokens\n", i);


		if (!strncmp(tokens[0], "power", 5)) {
			int vled_mv;
			ina219_read_vled_mv(&vled_mv);
			xil_printf("vled_mv=%d\n", vled_mv);
			int iled_ma;
			ina219_read_iled_ma(&iled_ma);
			xil_printf("iled_ma=%d\n", iled_ma);
			int pled_mw;
			ina219_read_pled_mw(&pled_mw);
			xil_printf("pled_mw=%d\n", pled_mw);
		}



		if (!strcmp(tokens[0], "ina")) {
			if (!strcmp(tokens[1], "gain")) {
				xil_printf("INA_GAIN <= %d\n", INA_GAIN = strtoul(tokens[2], NULL, 0));
			}
			if (!strcmp(tokens[1], "offset")) {
				xil_printf("INA_OFFSET <= %d\n", INA_OFFSET = strtoul(tokens[2], NULL, 0));
			}
			if (!strcmp(tokens[1], "att")) {
				int att = ~strtoul(tokens[2], NULL, 0);
				XGpioPs_WritePin(gpiops_ptr, 58, att&0x01);
				XGpioPs_WritePin(gpiops_ptr, 59, (att>>1)&0x01);
				//xil_printf("INA_ATT0 <= %d\n", INA_ATT0 = strtoul(tokens[2], NULL, 0));
			}


			if (!strcmp(tokens[1], "stat")) {
				INA_STAT_CFG = 0x01;
				INA_STAT_CFG = 0x00;
				INA_STAT_LIMIT = 1000000000;
				INA_STAT_CFG = 0x02;
				usleep(100000);
				INA_STAT_CFG = 0x00;

				xil_printf("INA_STAT_MIN: %d\n", (int8_t)INA_STAT_MIN);
				xil_printf("INA_STAT_MAX: %d\n", (int8_t)INA_STAT_MAX);
				xil_printf("INA_STAT_COUNT: %d\n", INA_STAT_COUNT);

			}
			if (!strcmp(tokens[1], "filt")) {

				switch (atoi(tokens[2])) {
				case 0:
					for (int i = 0; i < 21; ++i) {
						INA_FILTER_COEF = (uint32_t)(ina_filter0_coef[i] * (double)(1<<23));
					}
					xil_printf("INA_FILTER_COEF <= ina_filter0\n");
					break;
				case 1:
					for (int i = 0; i < 21; ++i) {
						INA_FILTER_COEF = (uint32_t)(ina_filter1_coef[i] * (double)(1<<23));
					}
					xil_printf("INA_FILTER_COEF <= ina_filter1\n");
					break;
				case 2:
					for (int i = 0; i < 21; ++i) {
						INA_FILTER_COEF = (uint32_t)(ina_filter2_coef[20-i] * (double)(1<<23));
					}
					xil_printf("INA_FILTER_COEF <= ina_filter2\n");
					break;
				case 3:
					for (int i = 0; i < 21; ++i) {
						INA_FILTER_COEF = (uint32_t)(ina_filter3_coef[20-i] * (double)(1<<23));
					}
					xil_printf("INA_FILTER_COEF <= ina_filter3\n");
					break;

				}



				//xil_printf("INA_FILTER_COEF <= %d\n", INA_FILTER_COEF = strtoul(tokens[2], NULL, 0));
			}




			if (!strcmp(tokens[1], "opt")) {

				INA_OFFSET = 0;
				INA_GAIN = 256;

				INA_STAT_CFG = 0x01;
				INA_STAT_CFG = 0x00;
				INA_STAT_LIMIT = 1000000000;
				INA_STAT_CFG = 0x02;
				usleep(100000);
				INA_STAT_CFG = 0x00;

				int min = (int8_t)INA_STAT_MIN;
				int max = (int8_t)INA_STAT_MAX;
				int ampl = max - min;
				int avg = (min + max) / 2;


				xil_printf("INA_GAIN <= %d\n", INA_GAIN = (256UL * 128UL) / ampl);

				xil_printf("INA_OFFSET <= %d\n", INA_OFFSET = -avg);



			}


		}

		if (!strcmp(tokens[0], "outa")) {
			if (!strcmp(tokens[1], "raw")) {
				xil_printf("OUTA_RAW <= %d\n", OUTA_RAW = strtoul(tokens[2], NULL, 0));
			}
			if (!strcmp(tokens[1], "mux")) {
				xil_printf("OUTA_MUX <= %d\n", OUTA_MUX = strtoul(tokens[2], NULL, 0));
			}
			if (!strcmp(tokens[1], "count")) {
				xil_printf("REG_OUTA_WR_COUNT: %d\n", REG_OUTA_WR_COUNT);
			}



		}

		if (!strcmp(tokens[0], "dac")) {
			if (!strcmp(tokens[1], "cfg")) {
				xil_printf("DAC_CFG <= %d\n", DAC_CFG = strtoul(tokens[2], NULL, 0));
			}
		}

		if (!strcmp(tokens[0], "usb")) {
			if (!strcmp(tokens[1], "wrmux")) {
				xil_printf("USB_WR_MUX <= %d\n", USB_WR_MUX = strtoul(tokens[2], NULL, 0));
			}
			if (!strcmp(tokens[1], "wr")) {
				for (int i = 0; i < 1024; ++i) {
					xil_printf("USB_WR_DATA <= %d\n", USB_WR_DATA = strtoul(tokens[2], NULL, 0));
				}
			}
		}

		if (!strcmp(tokens[0], "outb")) {
			if (!strcmp(tokens[1], "count")) {
				xil_printf("REG_OUTB_WR_COUNT: %d\n", REG_OUTB_WR_COUNT);
			}

		}

*/








//
//
//		//xil_printf("%d\n", *((volatile uint32_t*)(0x43C01000ULL)));
//		//xil_printf("%d\n", *((volatile uint32_t*)(0x43C00008)));
//
//		XGpioPs_WritePin(gpiops_ptr, 67, !XGpioPs_ReadPin(gpiops_ptr, 57)); // INB_R on DORB
//		XGpioPs_WritePin(gpiops_ptr, 68, !XGpioPs_ReadPin(gpiops_ptr, 61)); // INA_R on DORA
//
//		//XGpioPs_WritePin(gpiops_ptr, 72, 0);	// OUTA ATT0
//		//XGpioPs_WritePin(gpiops_ptr, 77, 0);  // OUTB ATT0
//
//		//xil_printf("USB_RD_EMPTY = %d\r\n", USB_RD_EMPTY);
//		if (!USB_RD_EMPTY) {
//			xil_printf("Starting read...\r\n");
//			int i = 0;
//			uint32_t x = 0, y = 0;
//			while (!USB_RD_EMPTY) {
//				y = x;
//				x = USB_RD_DATA;
//				//if (x-y!=1) {
//				if (x-y!=0x01010101 && !(x==0&&y==-1)) {
//					xil_printf("E 0x%08X 0x%08X\n", x, y);
//				}
//				/*
//				if (i < 20) {
//					xil_printf("0x%08X\n", x);
//				}
//				*/
//				++i;
//			}
//			xil_printf("Done read.\r\n");
//			xil_printf("%d\n", i);
//
//		}


		//usleep(100000);



		//USB_WR_DATA = c++;



		/*
		xil_printf("Hi\r\n");
		XGpioPs_Write(gpiops_ptr, 0, 0x0);
		XGpioPs_Write(gpiops_ptr, 1, 0x0);
		XGpioPs_Write(gpiops_ptr, 2, 0x0);
		XGpioPs_Write(gpiops_ptr, 3, 0x0);
		usleep(500000);
		XGpioPs_Write(gpiops_ptr, 0, 0xFFFFFFFF);
		XGpioPs_Write(gpiops_ptr, 1, 0xFFFFFFFF);
		XGpioPs_Write(gpiops_ptr, 2, 0xFFFFFFFF);
		XGpioPs_Write(gpiops_ptr, 3, 0xFFFFFFFF);
		usleep(500000);
		*/



/*
	while (1) {
		xil_printf("Hi\r\n");
		XGpioPs_WritePin(gpiops_ptr, 56, 0);
		usleep(500000);
		XGpioPs_WritePin(gpiops_ptr, 56, 1);
		usleep(500000);
	}
	*/






#if 0

#include "xdevcfg.h"

#include "bitfile1.h"

#include "xparameters.h"
#include "xdevcfg.h"

#define DCFG_DEVICE_ID		XPAR_XDCFG_0_DEVICE_ID

#define SLCR_LOCK	0xF8000004
#define SLCR_UNLOCK	0xF8000008
#define SLCR_LVL_SHFTR_EN 0xF8000900
#define SLCR_PCAP_CLK_CTRL XPAR_PS7_SLCR_0_S_AXI_BASEADDR + 0x168

#define SLCR_PCAP_CLK_CTRL_EN_MASK 0x1
#define SLCR_LOCK_VAL	0x767B
#define SLCR_UNLOCK_VAL	0xDF0D


XDcfg DcfgInst;

int XDcfgPolledExample(uint8_t *bitfile, uint32_t bitfile_size)
{
	int Status;
	u32 IntrStsReg = 0;
	u32 StatusReg;
	u32 PartialCfg = 0;

	XDcfg *DcfgInstPtr = &DcfgInst;



	XDcfg_Config *ConfigPtr;

	/*
	 * Initialize the Device Configuration Interface driver.
	 */
	ConfigPtr = XDcfg_LookupConfig(XPAR_XDCFG_0_DEVICE_ID);

	/*
	 * This is where the virtual address would be used, this example
	 * uses physical address.
	 */
	Status = XDcfg_CfgInitialize(DcfgInstPtr, ConfigPtr,
					ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	Status = XDcfg_SelfTest(DcfgInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Check first time configuration or partial reconfiguration
	 */
	IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
	if (IntrStsReg & XDCFG_IXR_DMA_DONE_MASK) {
		PartialCfg = 1;
	}

	/*
	 * Enable the pcap clock.
	 */
	StatusReg = Xil_In32(SLCR_PCAP_CLK_CTRL);
	if (!(StatusReg & SLCR_PCAP_CLK_CTRL_EN_MASK)) {
		Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
		Xil_Out32(SLCR_PCAP_CLK_CTRL,
				(StatusReg | SLCR_PCAP_CLK_CTRL_EN_MASK));
		Xil_Out32(SLCR_UNLOCK, SLCR_LOCK_VAL);
	}

	/*
	 * Disable the level-shifters from PS to PL.
	 */
	if (!PartialCfg) {
		Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
		Xil_Out32(SLCR_LVL_SHFTR_EN, 0xA);
		Xil_Out32(SLCR_LOCK, SLCR_LOCK_VAL);
	}

	/*
	 * Select PCAP interface for partial reconfiguration
	 */
	if (PartialCfg) {
		XDcfg_EnablePCAP(DcfgInstPtr);
		XDcfg_SetControlRegister(DcfgInstPtr, XDCFG_CTRL_PCAP_PR_MASK);
	}

	/*
	 * Clear the interrupt status bits
	 */
	XDcfg_IntrClear(DcfgInstPtr, (XDCFG_IXR_PCFG_DONE_MASK |
					XDCFG_IXR_D_P_DONE_MASK |
					XDCFG_IXR_DMA_DONE_MASK));

	/* Check if DMA command queue is full */
	StatusReg = XDcfg_ReadReg(DcfgInstPtr->Config.BaseAddr,
				XDCFG_STATUS_OFFSET);
	if ((StatusReg & XDCFG_STATUS_DMA_CMD_Q_F_MASK) ==
			XDCFG_STATUS_DMA_CMD_Q_F_MASK) {
		return XST_FAILURE;
	}

	/*
	 * Download bitstream in non secure mode
	 */

	// Set 2 LSbs to 0b01 - see example notes
	if ((uint32_t)bitfile & 0b11) {
		xil_printf("MISALIGNED ADDRESS\n");
	}
	if (bitfile_size % 4 != 0) {
		xil_printf("Size not multiple of 4! - %d extra\n", bitfile_size % 4);
	}
	bitfile = (uint8_t*)((uint32_t)bitfile | 1);


	xil_printf("Starting transfer...\n");

	XDcfg_Transfer(DcfgInstPtr, bitfile, bitfile_size/4,
			(u8 *)XDCFG_DMA_INVALID_ADDRESS,
			0, XDCFG_NON_SECURE_PCAP_WRITE);

	/* Poll IXR_DMA_DONE */
	IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
	while ((IntrStsReg & XDCFG_IXR_DMA_DONE_MASK) !=
			XDCFG_IXR_DMA_DONE_MASK) {
		IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
	}

	if (PartialCfg) {
		/* Poll IXR_D_P_DONE */
		while ((IntrStsReg & XDCFG_IXR_D_P_DONE_MASK) !=
				XDCFG_IXR_D_P_DONE_MASK) {
			IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
		}
	} else {
		/* Poll IXR_PCFG_DONE */
		while ((IntrStsReg & XDCFG_IXR_PCFG_DONE_MASK) !=
				XDCFG_IXR_PCFG_DONE_MASK) {
			IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
		}
		/*
		 * Enable the level-shifters from PS to PL.
		 */
		Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
		Xil_Out32(SLCR_LVL_SHFTR_EN, 0xF);
		Xil_Out32(SLCR_LOCK, SLCR_LOCK_VAL);
	}

	return XST_SUCCESS;
}







void load_bitfile1() {

	xil_printf("Loading bitfile1...\n");
	int status = XDcfgPolledExample(bitfile1, sizeof(bitfile1));
	if (status == XST_SUCCESS) {
		xil_printf("Done\n");
	} else {
		xil_printf("ERROR\n");
	}

}


#endif

