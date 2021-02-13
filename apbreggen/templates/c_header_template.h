
// GENERATED FILE: DO NOT MODIFY
// See https://github.com/thalmic/axireggen

#ifndef ${include_guard}
#define ${include_guard}

#include <stdint.h>
#include "xil_types.h"
#include "xil_printf.h"
#include "xparameters.h"

//#include "iopacket/iopacket.h"
#ifdef IOPACKET_H
#include "iopacket/named_addr.h"
#endif

#define ${regset_name}_BASEADDR ((u8*)${baseaddr})
#define ${regset_name}_MAXOFFSET ${max_offset}

${reg_defns}

${reg_ptr_decls}

struct ${regset_name}_Params {
${struct_fields}	
};

extern struct ${regset_name}_Params reset_${regset_name}_params;

void Set_${regset_name}_Params(struct ${regset_name}_Params *params);
void Get_${regset_name}_Params(struct ${regset_name}_Params *params);
void Print_${regset_name}_Params(void);
void Print_${regset_name}_Param_struct(struct ${regset_name}_Params *params);	
void Reset_${regset_name}_Params(void);
void Flush_${regset_name}_Params(void);

#ifdef IOPACKET_H
void Register_${regset_name}_IOPacket_Addresses(void);
#endif

#endif
