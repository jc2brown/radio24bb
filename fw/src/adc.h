
#ifndef ADC_H
#define ADC_H


#include "command.h"


struct adc_channel {
	struct adc_channel_regs *regs;
};


struct adc_channel *make_adc_channel(uint32_t regs_addr);

void init_adc_channel(struct adc_channel *channel);

void init_adc_channel_context(char *name, void *arg, struct cmd_context *parent_ctx) ;




static double ina_filter0_coef[21] = {
		/*
		    0.018121627, -0.0025737102, -0.049848193,
			-0.048790703, 0.046189787, 0.086422509, -0.075657994, -0.24352923, -0.050645060,
			0.45368918, 0.73324356, 0.45368918, -0.050645060, -0.24352923, -0.075657994,
			0.086422509, 0.046189787, -0.048790703, -0.049848193, -0.0025737102, 0.018121627
			*/
			/*
			0.0020676081, -0.0010862434, -0.028109706,
		        -0.015849916, 0.0067964367, 0.0043629139, 0.015229101, -0.12102499, -0.24878713,
		        0.37998359, 1.0128367, 0.37998359, -0.24878713, -0.12102499, 0.015229101,
		        0.0043629139, 0.0067964367, -0.015849916, -0.028109706, -0.0010862434, 0.0020676081
		        */
		        /*
		      0.000019538157, 0.000029681056, 0.000016285841,
		            0.000045572917, 0.000013777408, 0.000085082212, 0.000012272895, 0.00022904898, 0.000011470952,
		            0.0020298291, 0.99501488, 0.0020298291, 0.000011470952, 0.00022904898, 0.000012272895,
		            0.000085082212, 0.000013777408, 0.000045572917, 0.000016285841, 0.000029681056, 0.000019538157,
		            */


        0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0
};

static double ina_filter1_coef[21] = {

		-0.0043883602, 0.00031565442, 0.0017003562,
			-0.013089587, -0.050334464, -0.094678034, -0.10854188, -0.057842500, 0.052184995,
			0.16681251, 0.21572262, 0.16681251, 0.052184995, -0.057842500, -0.10854188,
			-0.094678034, -0.050334464, -0.013089587, 0.0017003562, 0.00031565442, -0.0043883602




};


// 0.5dB-flat between 7MHz-13MHz
static double ina_filter2_coef[21] = {
		/*
		0.00083361730, 0.0049833431, 0.010994397, 0.010550922, 0.0044100972, -0.025195274,
		-0.12993985, -0.20641016, -0.0044258790, 0.34565486, 0.34565486, -0.0044258790,
		-0.20641016, -0.12993985, -0.025195274, 0.0044100972, 0.010550922, 0.010994397,
		0.0049833431, 0.00083361730
*/
		0.0086061177, -0.014499215, 0.014741051,
			0.052044280, -0.033934747, -0.039228125, 0.049100553, -0.24203432, -0.46529025,
			0.24094970, 0.86553072, 0.24094970, -0.46529025, -0.24203432, 0.049100553,
			-0.039228125, -0.033934747, 0.052044280, 0.014741051, -0.014499215, 0.0086061177
};



static double ina_filter3_coef[21] = {
		/*
		0.00019650309, -0.0011634096, -0.0029005943,
			-0.0030360476, 0.0013716988, 0.0055533369, -0.014427315, -0.034860653, -0.14142311,
			0.22235950, 0.70580393, 0.22235950, -0.14142311, -0.034860653, -0.014427315,
			0.0055533369, 0.0013716988, -0.0030360476, -0.0029005943, -0.0011634096, 0.00019650309
			*/
		/*
		 0.0037293212, 0.0026582177, -0.0052461240,
			-0.026234382, -0.060484918, -0.093310896, -0.097989150, -0.041391629, 0.048577946,
			0.24839704, 0.40958283, 0.24839704, 0.048577946, -0.041391629, -0.097989150,
			-0.093310896, -0.060484918, -0.026234382, -0.0052461240, 0.0026582177, 0.0037293212
			*/
		/*
		0.0035921455, 0.0050803075, 0.010399698,
			0.015523064, 0.025171368, 0.036328236, 0.061582277, 0.046174460, 0.13089438,
			-0.023983045, 0.25892037, -0.023983045, 0.13089438, 0.046174460, 0.061582277,
			0.036328236, 0.025171368, 0.015523064, 0.010399698, 0.0050803075, 0.0035921455
			*/
		/*
		0.0011960867, 0.0082956604, 0.019339728,
			0.018077735, -0.014784497, -0.075236340, -0.12058392, -0.095022718, 0.014027448,
			0.14540166, 0.20446608, 0.14540166, 0.014027448, -0.095022718, -0.12058392,
			-0.075236340, -0.014784497, 0.018077735, 0.019339728, 0.0082956604, 0.0011960867
			*/
		0.0091849059, -0.019084909, 0.0033509231,
			0.040091750, -0.036572322, -0.013564985, 0.12903680, -0.12903350, -0.42604124,
			0.11707684, 0.65213891, 0.11707684, -0.42604124, -0.12903350, 0.12903680,
			-0.013564985, -0.036572322, 0.040091750, 0.0033509231, -0.019084909, 0.0091849059

};








struct adc_channel_regs {

	uint32_t gain;
	uint32_t offset;
	uint32_t filter_coef;
	uint32_t stat_cfg;
	uint32_t stat_min;
	uint32_t stat_max;
	uint32_t stat_limit;
	uint32_t stat_count;
	uint32_t att;
	uint32_t amp_en;
	uint32_t led;

};




void init_adc_channel_regs(struct adc_channel_regs *regs);

void adc_stat(struct adc_channel *channel);
#endif
