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
#include <stdbool.h>

#include "roe.h"

#include "regs.h"

#include "i2c.h"
#include "ina219.h"

#include "radio24bb.h"
#include "xadc.h"

#include "adc.h"
#include "dac.h"
#include "dds.h"
#include "mpx.h"

#include "aic3204.h"

#include "command.h"


void usb_handler(void *arg, struct command *cmd) {

	static int n = 0;
	static char msg[1024];


	//USB_WR_PUSH = 1;


	sprintf(msg, "Hello #%d\n", n++);

	for (char *c = msg; *c != '\0'; ++c) {
		USB_WR_DATA = *c;
	}

	USB_WR_PUSH = 1;
/*

	for (int i = 0; i < 1024; ++i) {
		USB_WR_DATA = i;
	}
*/
}


/*
void tonea_handler(void *arg, struct command *cmd) {
	issue_command("ddsa src dds", NULL);
	issue_command("ddsa freq 10.7e6", NULL);
	issue_command("ddsa fm src aud", NULL);
	issue_command("ddsa fm gain 300", NULL);
	issue_command("outa src ddsa", NULL);
}
*/




char *stereo_script[] = {

	"ddsa am src raw",	
	"ddsa am raw 127",	
	"ddsa am gain 256",	
	"ddsa am offset 0",
	"ddsa fm gain 0",	
	"ddsa fm offset 0",
	"ddsa pm gain 0",	
	"ddsa pm offset 0",

	"ddsa src dds",
	"ddsa freq 10.7e6",
	"ddsa fm src mpx",
	"ddsa fm gain 400",
	"ddsa fm offset 0",

	"mpx pilot 1000",

	"outa src ddsa",

	"outb src ddsb",
	"outb att 0",

	"ddsb src mpx"


};




char *amtone_script[] = {

	"ddsb src dds",
	"ddsb freq 1e3",
	"ddsb fm src raw",


	"ddsa am src raw",	
	"ddsa am raw 127",	
	"ddsa am gain 256",	
	"ddsa am offset 0",
	"ddsa fm gain 0",	
	"ddsa fm offset 0",
	"ddsa pm gain 0",	
	"ddsa pm offset 0",



	"ddsa src dds",
	"ddsa freq 19.7e6",
	"ddsa am src ddsb",
	"ddsa am gain 127",
	"ddsa am offset 64",

	"outa src ddsa",
	"outb src ddsa",

};





char *fmtone_script[] = {

	"ddsb src dds",
	"ddsb freq 1e3",
	"ddsb fm src raw",

	"ddsa am src raw",	
	"ddsa am raw 127",	
	"ddsa am gain 256",	
	"ddsa am offset 0",
	"ddsa fm gain 0",	
	"ddsa fm offset 0",
	"ddsa pm gain 0",	
	"ddsa pm offset 0",

	"ddsa src dds",
	"ddsa freq 19.7e6",
	"ddsa fm src ddsb",
	"ddsa fm gain 10000",
	"ddsa fm offset 0",

	"outa src ddsa",
	"outb src ddsa",

};





char *pmtone_script[] = {

	"ddsb src dds",
	"ddsb freq 1e3",
	"ddsb fm src raw",

	"ddsa am src raw",	
	"ddsa am raw 127",	
	"ddsa am gain 256",	
	"ddsa am offset 0",
	"ddsa fm gain 0",	
	"ddsa fm offset 0",
	"ddsa pm gain 0",	
	"ddsa pm offset 0",

	"ddsa src dds",
	"ddsa freq 19.7e6",
	"ddsa fm src raw",
	"ddsa am src raw",
	"ddsa pm src ddsb",
	"ddsa pm gain 2048",

	"outa src ddsa",
	"outb src ddsa",

};


void stereo_handler(void *arg, struct command *cmd) {
	run_script(stereo_script);
}

void amtone_handler(void *arg, struct command *cmd) {
	run_script(amtone_script);
}
	
void fmtone_handler(void *arg, struct command *cmd) {
	run_script(fmtone_script);
}
	
void pmtone_handler(void *arg, struct command *cmd) {
	run_script(pmtone_script);
}
	



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




void aud_rate_handler(void *arg, struct command *cmd) {

	int aud_rate = atoi(cmd->tokens[cmd->index++]);
	if (aud_rate == 0) {
		AUD_RATE = 0;		
		set_adc_osr(128);
		set_adc_prb(1);
		set_dac_osr(128);
		set_dac_prb(17);
	}
	if (aud_rate == 11) {
		set_adc_prb(1);
	}
	if (aud_rate == 12) {
		set_adc_prb(2);
	}
	if (aud_rate == 13) {
		set_adc_prb(3);
	}
	if (aud_rate == 1) {
		AUD_RATE = 1;		
		set_adc_osr(64);
		set_adc_prb(14); //??
		set_dac_osr(64);
		set_dac_prb(8);  //??
	}
	if (aud_rate == 2) {
		AUD_RATE = 2;		
		set_adc_osr(32);
		set_adc_prb(14);
		set_dac_osr(32);
		set_dac_prb(8);
	}

}


struct radio24bb *r24bb;


void adc_handler(void *arg, struct command *cmd) {
	xadc_report(r24bb->xadc);
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

	AUD_RATE = 2;
	init_aic3204();

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

#define R24BB_REGS 0x43C04000UL

#define DDSA_REGS 0x43C05000UL
#define DDSB_REGS 0x43C06000UL

#define MPX_REGS 0x43C07000UL

//	struct adc_channel_regs *ina_regs  = (struct adc_channel_regs *)(0x43C00000UL);
//	struct adc_channel_regs *inb_regs  = (struct adc_channel_regs *)(0x43C01000UL);


	//xil_printf()



	r24bb = make_radio24bb(R24BB_REGS);
	init_radio24bb(r24bb);

	add_command(NULL, "adc", adc_handler);


	//add_command(NULL, "tonea", tonea_handler);
	add_command(NULL, "usb", usb_handler);
	add_command(NULL, "stereo", stereo_handler);
	add_command(NULL, "amtone", amtone_handler);
	add_command(NULL, "fmtone", fmtone_handler);
	add_command(NULL, "pmtone", pmtone_handler);
	add_command(NULL, "loopa", loopa_handler);
	add_command(NULL, "info", info_handler);
	add_command(NULL, "led", led_handler);



	struct cmd_context * aud = make_cmd_context("aud", NULL);	
	add_command(aud, "rate", aud_rate_handler);

	add_subcontext(NULL, aud);



	struct adc_channel *ina = make_adc_channel(INA_REGS);
	struct adc_channel *inb = make_adc_channel(INB_REGS);

	init_adc_channel_context("ina", ina, NULL);
	init_adc_channel_context("inb", inb, NULL);



	struct dac_channel *outa = make_dac_channel(OUTA_REGS);
	struct dac_channel *outb = make_dac_channel(OUTB_REGS);

	init_dac_channel_context("outa", outa, NULL);
	init_dac_channel_context("outb", outb, NULL);


	struct dds_channel *ddsa = make_dds_channel(DDSA_REGS);
	struct dds_channel *ddsb = make_dds_channel(DDSB_REGS);

	init_dds_channel_context("ddsa", ddsa, NULL);
	init_dds_channel_context("ddsb", ddsb, NULL);


	struct mpx_channel *mpx = make_mpx_channel(MPX_REGS);

	init_mpx_channel_context("mpx", mpx, NULL);


	issue_command("outa att 0", NULL);
	issue_command("outb att 3", NULL);







	DAC_DCE = 0;
	usleep(100000);


	DAC_CFG = 0x40;

	LEDS = 3;


	// XGpioPs_WritePin(gpiops_ptr, 72, 1);	// OUTA ATT0
	// XGpioPs_WritePin(gpiops_ptr, 71, 1);	// OUTA ATT1







	issue_command("led", NULL);


	//issue_command("fmtone", NULL);
	issue_command("stereo", NULL);



	print_cmd_responses(true);


	USB_WR_MUX = 0;
	USB_LED_R = 1;
	PWR_LED_R = 1;



	while (1) {



		handle_command();



	}


	return 0;
}

/*

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

