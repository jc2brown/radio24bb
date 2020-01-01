
#include <stdlib.h>
#include "sleep.h"
#include "ff.h"
#include "fatfs.h"
#include "roe.h"



int fatfs_ls() {

	int Res;

	DIR dp;
	Res = f_opendir(&dp, "0:/");
	if (Res != FR_OK) {
		xil_printf("no dir\n");
		return XST_FAILURE;
	}


	FILINFO fno;

	while (1) {

		fno.fname[0] = '\0';
		Res = f_readdir(&dp, &fno);

		if (fno.fname[0] == '\0') {		
			xil_printf("end of dir\n");
			break;
		}
		else if (Res != FR_OK) {
			xil_printf("readdir failed\n");
			return XST_FAILURE;
		}
		xil_printf("fname=%s\n", fno.fname);
		usleep(10000);
	}
	Res = f_closedir(&dp);
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


