
// GENERATED FILE: DO NOT MODIFY
// See https://github.com/thalmic/axireggen

#include <stdint.h>
#include "xil_types.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "xparameters.h"

#include "${c_header_filename}"

//#include "iopacket/iopacket.h"
#ifdef IOPACKET_H
#include "iopacket/named_addr.h"
#endif

${reg_ptr_defns}

struct ${regset_name}_Params reset_${regset_name}_params = {
${reset_struct_fields}
};

void Set_${regset_name}_Params(struct ${regset_name}_Params *params) {	
${set_stmts}	
	Flush_${regset_name}_Params();
}

void Get_${regset_name}_Params(struct ${regset_name}_Params *params) {
	Flush_${regset_name}_Params();
${get_stmts}		
}

void Print_${regset_name}_Params() {
	struct ${regset_name}_Params params;
	Get_${regset_name}_Params(&params);
	Print_${regset_name}_Param_struct(&params);
}

void Print_${regset_name}_Param_struct(struct ${regset_name}_Params *params) {
${print_stmts}
}

void Reset_${regset_name}_Params() {	
	Set_${regset_name}_Params(&reset_${regset_name}_params);
}

void Flush_${regset_name}_Params() {
	Xil_DCacheFlushRange(${regset_name}_BASEADDR, ${regset_name}_MAXOFFSET+${num_data_bytes});
}

#ifdef IOPACKET_H
void Register_${regset_name}_IOPacket_Addresses() {
${iopacket_stmts}
}
#endif