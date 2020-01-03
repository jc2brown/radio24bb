
#include <stdlib.h>
#include "sleep.h"
#include "ff.h"
#include "fatfs.h"
#include "roe.h"
#include "command.h"





int fatfs_ls() {

	int Res;

	DIR dp;
	Res = f_opendir(&dp, "0:/");
	if (Res != FR_OK) {
		xil_printf("no dir\n");
		return XST_FAILURE;
	}


	FILINFO fno;


	xil_printf("%6s  %9s  %16s\n", "ATTRIB", "SIZE", "NAME");

	while (1) {

		fno.fname[0] = '\0';
		Res = f_readdir(&dp, &fno);

		if (fno.fname[0] == '\0') {		
			break;
		}
		else if (Res != FR_OK) {
			xil_printf("readdir failed\n");
			return XST_FAILURE;
		}



		char s[7];
		strcpy(s, "------");

		if (fno.fattrib & AM_RDO) {
			s[5] = 'R';
		}
		if (fno.fattrib & AM_HID) {
			s[4] = 'H';
		}
		if (fno.fattrib & AM_SYS) {
			s[3] = 'S';
		}
		if (fno.fattrib & AM_VOL) {
			s[2] = 'V';
		}
		if (fno.fattrib & AM_DIR) {
			s[1] = 'D';
		}
		 if (fno.fattrib & AM_ARC) {
		 	s[0] = 'A';
		 }


		// xil_printf("%8X  %9d  %16s\n", fno.fattrib, fno.fsize, fno.fname);
		xil_printf("%6s  %9d  %16s\n", s, fno.fsize, fno.fname);
		usleep(10000);
	}
	Res = f_closedir(&dp);

	xil_printf("\n");

	if (Res != FR_OK) {
		xil_printf("closedir failed\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}




FATFS *make_fatfs() {
	FATFS *fatfs = (FATFS *)malloc(sizeof(FATFS));
	return fatfs;
}




int init_fatfs(FATFS *fatfs) {
	_return_if_error_(f_mount(fatfs, "0:/", 0));
	return XST_SUCCESS;
}


