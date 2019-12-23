

#include "xspips.h"

#include "spi.h"


#include "aic3204.h"




void transfer(uint8_t addr, uint8_t data_in, uint8_t *data_out) {
	uint8_t outbuf[2] = {addr, data_in};
	uint8_t inbuf[2] = {0xAA, 0xAA};
	XSpiPs_SetSlaveSelect(xspips_ptr, 0x0);
	XSpiPs_PolledTransfer(xspips_ptr, outbuf, inbuf, 2);
	XSpiPs_SetSlaveSelect(xspips_ptr, 0x7);
	if (data_out != NULL) {
		*data_out = inbuf[1];
	}
}





void select_page(uint8_t page) {
	static uint8_t _page = 0xFF;
	if (page != _page) {
		xil_printf("page=%d\n", page);
		transfer(0, page, NULL);
		_page = page;
	}
}



void read_register(uint8_t page, uint8_t reg, uint8_t *data_out) {
	select_page(page);
	transfer((reg<<1)|1, 0, data_out);
	xil_printf("rd reg 0x%02X: %d\n", reg, *data_out);

}



void _write_register(uint8_t page, uint8_t reg, uint8_t wr_data, int verify) {
	select_page(page);
	transfer(reg<<1, wr_data, NULL);
	xil_printf("wr reg%02X <= %02X\n", reg, wr_data);

	if (verify) {
		uint8_t rd_data;
		transfer((reg<<1)|1, NULL, &rd_data);
		if (rd_data != wr_data) {
			xil_printf("READBACK ERROR: expected 0x%02X from pg%d reg%02X but got 0x%02X\n", (int)wr_data, (int)page, (int)reg>>1, (int)rd_data);
		} else {
			xil_printf("Readback OK\n");			
		}
	}
}


void write_register(uint8_t page, uint8_t reg, uint8_t data_in) {
	_write_register(page, reg, data_in, 1);
}


void write_register_noverify(uint8_t page, uint8_t reg, uint8_t data_in) {
	_write_register(page, reg, data_in, 0);
}



#include <sleep.h>



#define P0_R11 0x0B
#define P0_R12 0x0C
#define P0_R13 0x0D
#define P0_R14 0x0E
#define P0_R18 0x12
#define P0_R19 0x13
#define P0_R20 0x14
#define P0_R27 0x1B
#define P0_R28 0x1C
#define P0_R60 0x3C
#define P0_R61 0x3D
#define P1_R1  0x01
#define P1_R2  0x02
#define P1_R10 0x0A
#define P1_R61 0x3D
#define P1_R71  0x47
#define P1_R123 0x7B


void aic3204_reset() {
	write_register_noverify(0, 0x01, 0x01); 
}

void set_ndac_divider(int n) {
	if (n == 128) {
		n = 0;
	}
	// Always power on
	n |= 0x80;

	write_register(0, P0_R11, (uint8_t)n); 	
}


void set_mdac_divider(int n) {
	if (n == 128) {
		n = 0;
	}
	// Always power on
	n |= 0x80;

	n &= 0xFF;
	write_register(0, P0_R12, (uint8_t)n); 	
}



void set_nadc_divider(int n) {
	if (n == 128) {
		n = 0;
	}
	// Always power on
	n |= 0x80;

	write_register(0, P0_R18, (uint8_t)n); 	
}


void set_madc_divider(int n) {
	if (n == 128) {
		n = 0;
	}
	// Always power on
	n |= 0x80;

	n &= 0xFF;
	write_register(0, P0_R19, (uint8_t)n); 	
}



void set_dac_osr(int n) {
	if (n > 1024) {
		n = 1024;
	}
	if (n == 1024) {
		n = 0;
	}
	// Must be a multiple of 8
	n = n & ~0x07;
	uint16_t buf = n;
	write_register(0, P0_R13, (uint8_t)(buf>>8)); 
	write_register(0, P0_R14, (uint8_t)buf); 
}


void set_adc_osr(int n) {
	uint8_t buf = 0;
	switch (n) {
	case 32:
		buf = 0x20;
		break;
	case 64:
		buf = 0x40;
		break;
	case 128:
		buf = 0x80;
		break;
	case 256:
		buf = 0x00;
		break;
	}
	write_register(0, P0_R20, buf); 
}



void set_if_config() {

	uint8_t buf = 
		((0b00) << 6) | // I2S mode
		((0b00) << 4) | // 16 bit
		((0b00) << 3) | // BCLK input
		((0b00) << 2) | // WCLK input
		((0b00) << 1) | // Reserved - write 0
		((0b00) << 0);  // DOUT not HiZ

	write_register(0, P0_R27, buf); 

	// No bit offset
	write_register(0, P0_R28, 0); 

}




void set_adc_prb(int n) {
	if (n < 1 || n > 18) {
		return;
	}
	uint8_t buf = n;
	write_register(0, P0_R61, buf); 
}

void set_dac_prb(int n) {
	if (n < 1 || n > 25) {
		return;
	}
	uint8_t buf = n;
	write_register(0, P0_R60, buf); 
}


void set_weak_vdd(int en) {
	uint8_t buf = 0;
	if (!en) {
		buf = 0x08;
	}
	write_register(1, P1_R1, buf); 
}



void set_ldo_ctrl() {
	// 1.72V AVDD DVDD LDOs
	// Analog block power enabled, AVDD LDO enabled
	write_register(1, P1_R2, 1); 
}


void set_cm() {

	uint8_t buf = 
		((0b0) << 7) |  // Reserved
		((0b0) << 6) |  // Full-chip CM = 0.9V
		((0b11) << 4) | // HP CM = 1.65V
		((0b1) << 3) |  // LO CM = 1.65V, powered from LDOIN
		((0b0) << 2) |  // Reserved
		((0b1) << 1) |  // LO powered from LDOIN
		((0b1) << 0);   // LDOIN range = 1.8-3.6V

	write_register(1, P1_R10, buf); 
}


void set_power_tune() {
	// PTM_R4
	write_register(1, P1_R61, 0); 
}

#define P1_R3 0x03

void set_left_playback_config() {

	uint8_t buf = 
		((0b00) << 6) |  // DACL class AB
		((0b0) << 5) |   // Reserved
		((0b000) << 2) | // DACL in PTM 3,4
		((0b00) << 0);   // Reserved

	write_register(1, P1_R3, buf); 
}


#define P1_R4 0x04

void set_right_playback_config() {

	uint8_t buf = 
		((0b00) << 6) |  // DACR class AB
		((0b0) << 5) |   // Reserved
		((0b000) << 2) | // DACR in PTM 3,4
		((0b00) << 0);   // Reserved

	write_register(1, P1_R4, buf); 
}


enum P1_R71_PWRUP_TIME {
	P1_R71_PWRUP_TIME_1600US,
	P1_R71_PWRUP_TIME_3100US,
	P1_R71_PWRUP_TIME_6400US
};

void set_mic_pga_startup_delay(enum P1_R71_PWRUP_TIME t) {
	uint8_t buf = 0;
	switch (t) {
	case P1_R71_PWRUP_TIME_1600US:
		buf = 0x33;
		break;
	case P1_R71_PWRUP_TIME_3100US:
		buf = 0x31;
		break;
	case P1_R71_PWRUP_TIME_6400US:
		buf = 0x32;
		break;
	}
	write_register(1, P1_R71, buf); 
}



void set_ref_charge_time() {
	// 40ms
	write_register(1, P1_R123, 0x01); 
}


#define P1_R52 0x34

void set_left_mic_pga_pos_src() {
	
	uint8_t buf = 
		((0b10) << 6) |  // IN1L -> 20kOhm -> MICPGA_L+
		((0b00) << 4) |  // IN2L -> InfOhm -> MICPGA_L+
		((0b00) << 2) |  // IN3L -> InfOhm -> MICPGA_L+
		((0b00) << 0);   // IN1R -> InfOhm -> MICPGA_L+

	write_register(1, P1_R52, buf); 
}




#define P1_R54 0x36

void set_left_mic_pga_neg_src() {
	
	uint8_t buf = 
		((0b10) << 6) |  // CM1L -> 20kOhm -> MICPGA_L-
		((0b00) << 4) |  // IN2R -> InfOhm -> MICPGA_L-
		((0b00) << 2) |  // IN3R -> InfOhm -> MICPGA_L-
		((0b00) << 0);   // CM2L -> InfOhm -> MICPGA_L-

	write_register(1, P1_R54, buf); 
}




#define P1_R55 0x37

void set_right_mic_pga_pos_src() {
	
	uint8_t buf = 
		((0b10) << 6) |  // IN1R -> 20kOhm -> MICPGA_R+
		((0b00) << 4) |  // IN2R -> InfOhm -> MICPGA_R+
		((0b00) << 2) |  // IN3R -> InfOhm -> MICPGA_R+
		((0b00) << 0);   // IN2L -> InfOhm -> MICPGA_R+

	write_register(1, P1_R55, buf); 
}




#define P1_R57 0x39

void set_right_mic_pga_neg_src() {
	
	uint8_t buf = 
		((0b10) << 6) |  // CM1R -> 20kOhm -> MICPGA_R-
		((0b00) << 4) |  // IN1L -> InfOhm -> MICPGA_R-
		((0b00) << 2) |  // IN3L -> InfOhm -> MICPGA_R-
		((0b00) << 0);   // CM2R -> InfOhm -> MICPGA_R-

	write_register(1, P1_R57, buf); 
}









#define P1_R12 0x0C

void set_left_hp_src() {
	
	uint8_t buf = 
		((0b0000) << 4) | // Reserved
		((0b1) << 3) |   // DACL+ -> 0hm -> HPL
		((0b0) << 2) |   // IN1L -> InfOhm -> HPL
		((0b0) << 1) |   // MAL -> InfOhm -> HPL
		((0b0) << 0);    // MAR -> InfOhm -> HPL

	write_register(1, P1_R12, buf); 
}


#define P1_R13 0x0D

void set_right_hp_src() {
	
	uint8_t buf = 
		((0b000) << 5) | // Reserved
		((0b0) << 4) |   // DACL- -> InfOhm -> HPR
		((0b1) << 3) |   // DACL- -> 0hm -> HPR
		((0b0) << 2) |   // IN1R+ -> InfOhm -> HPR
		((0b0) << 1) |   // MAR -> InfOhm -> HPR
		((0b0) << 0);    // HPL -> InfOhm -> HPR

	write_register(1, P1_R13, buf); 
}







#define P1_R14 0x0E

void set_left_lo_src() {
	
	uint8_t buf = 
		((0b000) << 5) | // Reserved
		((0b0) << 4) |   // DACR- -> InfOhm -> LOL
		((0b1) << 3) |   // DACL -> 0hm -> LOL
		((0b0) << 2) |   // IN1L -> InfOhm -> LOL
		((0b0) << 1) |   // MAL -> InfOhm -> LOL
		((0b0) << 0);    // MAR -> InfOhm -> LOL

	write_register(1, P1_R14, buf); 
}


#define P1_R15 0x0F

void set_right_lo_src() {
	
	uint8_t buf = 
		((0b0000) << 4) | // Reserved
		((0b1) << 3) |    // DACR -> 0hm -> HPR
		((0b0) << 2) |    // Reserved
		((0b0) << 1) |    // MAR -> InfOhm -> HPR
		((0b0) << 0);     // Reserved

	write_register(1, P1_R15, buf); 
}







#define P1_R16 0x10

void set_left_hp_gain() {
	
	uint8_t buf = 
		((0b0) << 7) | // Reserved
		((0b0) << 6) | // Unmute
		((0x00) << 0); // 0dB gain

	write_register(1, P1_R16, buf); 
}


#define P1_R17 0x11

void set_right_hp_gain() {
	
	uint8_t buf = 
		((0b0) << 7) | // Reserved
		((0b0) << 6) | // Unmute
		((0x00) << 0); // 0dB gain

	write_register(1, P1_R17, buf); 
}







#define P1_R18 0x12

void set_left_lo_gain() {
	
	uint8_t buf = 
		((0b0) << 7) | // Reserved
		((0b0) << 6) | // Unmute
		((0x00) << 0); // 0dB gain

	write_register(1, P1_R18, buf); 
}


#define P1_R19 0x13

void set_right_lo_gain() {
	
	uint8_t buf = 
		((0b0) << 7) | // Reserved
		((0b0) << 6) | // Unmute
		((0x00) << 0); // 0dB gain

	write_register(1, P1_R19, buf); 
}






#define P1_R58 0x3A

void set_floating_inputs() {

	uint8_t buf = 
		((0b1) << 7) | // IN1L <- weak <- CM
		((0b1) << 6) | // IN1R <- weak <- CM
		((0b1) << 5) | // IN2L <- weak <- CM
		((0b1) << 4) | // IN2R <- weak <- CM
		((0b1) << 3) | // IN3L <- weak <- CM
		((0b1) << 2) | // IN3R <- weak <- CM
		((0b0) << 1) | // Reserved
		((0b0) << 0);  // Reserved

	write_register(1, P1_R58, buf); 


}




#define P1_R9 0x09

void set_driver_power() {

	uint8_t buf = 
		((0b00) << 6) | // Reserved
		((0b1) << 5) |  // HPL powered
		((0b1) << 4) |  // HPR powered
		((0b1) << 3) |  // LOL powered
		((0b1) << 2) |  // LOR powered
		((0b1) << 1) |  // MAL powered
		((0b1) << 0);   // MAR powered

	write_register(1, P1_R9, buf); 

}





#define P1_R59 0x3B

void set_left_mic_pga_gain(int db) {

	uint8_t buf = 0;
	if (db < 0) { // Is this a mute condition or unity gain??? Datasheet says 0dB but could be an error
		buf = 0x80; // Mute
	}
	else if (db < 48) {
		buf = db << 1; // Adjust for actual PGA step size which is 0.5dB 
	}

	write_register(1, P1_R59, buf); 
}




#define P1_R60 0x3C

void set_right_mic_pga_gain(int db) {

	uint8_t buf = 0;
	if (db < 0) {
		buf = 0x80; // Mute
	}
	else if (db < 48) {
		buf = db << 1; // Adjust for actual PGA step size which is 0.5dB 
	}

	write_register(1, P1_R60, buf); 
}





#define P0_R81 0x51

void adc_channel_setup() {

	uint8_t buf = 
		((0b1) << 7) |  // Left ADC power up
		((0b1) << 6) |  // Right ADC power up
		((0b00) << 4) | // Digital MIC -> GPIO
		((0b0) << 3) |  // Left ADC no digital mic
		((0b0) << 2) |  // Right ADC no digital mic
		((0b0) << 0);   // Soft-step ADC volume 1 word clock per step

	write_register(0, P0_R81, buf); 

}




#define P0_R63 0x3F

void dac_channel_setup() {

	uint8_t buf = 
		((0b1) << 7) |  // Left DAC power up
		((0b1) << 6) |  // Right DAC power up
		((0b01) << 4) | // Left DAC data Left Channel Audio Interface Data
		((0b01) << 2) | // Right DAC data Left Channel Audio Interface Data
		((0b00) << 0);  // Soft-step ADC volume 1 word clock per step

	write_register(0, P0_R63, buf); 

}





#define P0_R82 0x52

void adc_unmute() {

	uint8_t buf = 
		((0b0) << 7) |   // Left ADC unmute
		((0b000) << 4) | // Left ADC fine-gain 0dB
		((0b0) << 3) |   // Right ADC unmute
		((0b000) << 0);  // Right ADC fine-gain 0dB

	write_register(0, P0_R82, buf); 

}





#define P0_R64 0x40

void dac_unmute() {

	write_register(0, P0_R64, 0); 

}




void aic3204_dump() {
	uint8_t buf;
	for (int i = 0; i < 128; ++i) {
		read_register(0, i, &buf); 
	}
}



void adc_pre_init() {	
	set_nadc_divider(1);
	set_madc_divider(2);
	set_adc_osr(128);
	set_adc_prb(1);
}


void dac_pre_init() {
	set_ndac_divider(1);
	set_mdac_divider(2);
	set_dac_osr(128);
	set_dac_prb(8);
}




void core_init() {	
	set_weak_vdd(0);
	set_ldo_ctrl();
	set_cm();
	set_power_tune();
	set_mic_pga_startup_delay(P1_R71_PWRUP_TIME_6400US);
	set_ref_charge_time();
}


void adc_post_init() {	
	set_left_mic_pga_pos_src();
	set_left_mic_pga_neg_src();
	set_right_mic_pga_pos_src();
	set_right_mic_pga_neg_src();
	set_floating_inputs();
	set_left_mic_pga_gain(6);
	set_right_mic_pga_gain(6);
	adc_channel_setup();
	adc_unmute();
}


void dac_post_init() {
	set_left_hp_src();
	set_right_hp_src();
	set_left_lo_src();
	set_right_lo_src();
	set_driver_power();
	set_left_playback_config();
	set_right_playback_config();
	set_left_hp_gain();
	set_right_hp_gain();
	set_left_lo_gain();
	set_right_lo_gain(); 
	set_driver_power();
	//usleep(3000000);
	dac_channel_setup();
	dac_unmute();
}




void init_aic3204() {	
	aic3204_reset();
	adc_pre_init();
	dac_pre_init();
	core_init();
	adc_post_init();
	dac_post_init();
	aic3204_dump();
}

