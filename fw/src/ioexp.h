



#ifndef IOEXP_H
#define IOEXP_H



#define IOEXP_IICPS 0
#define IOEXP_GPIO 1

struct ioexp {
	XIicPs *iicps;
	uint32_t *bus_sel_ptr;
	int if_type;
	uint8_t bus_addr;
	int bus_sel;
};




struct ioexp *make_ioexp();


int init_ioexp(
		struct ioexp *ioe, 
		XIicPs *iicps,
		uint32_t *bus_sel_ptr,
		int if_type, 
		uint8_t bus_addr, 
		int bus_sel,
		uint8_t port0_inputs, 
		uint8_t port1_inputs
);

int ioexp_read_port(struct ioexp *ioe, int port, uint8_t *value);
int ioexp_write_port(struct ioexp *ioe, int port, uint8_t value);

// int ioexp_write(struct ioexp *ioe, int port, uint8_t value, uint8_t mask);


#endif