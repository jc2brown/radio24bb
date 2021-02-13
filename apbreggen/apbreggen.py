
# This program generates the source files required to implement a memory-mapped AXI-Lite register bank.
#
# It accepts a CSV file containing a list of register specifications
#
# It produces the following:
#	- a Verilog RTL module with an AXI-Lite interface and a set of ports which expose the registers to the programmable logic
#	- a C header file with a set of #defines and/or variable declarations which expose the registers to the application software via memory-mapping
#
# The register spec file shall be formatted as a tabular CSV file containing one header row followed by any number of register spec rows
#
# The header row shall contain the following required field names:
#	- Name					Arbitrary textual identifier
#	- Offset				Distance in bytes from a reference address 
#	- Width OR Right		Number of bits OR rightmost bit index
#
# In addition to the required fields listed above, the header row may contain any of the following fields:
#	- Offset				Distance in bytes from a reference address 
#	- Width					Number of bits, 
#	- Right					Rightmost bit index
#	- Left					Leftmost bit index
#	- Direction				I/input or O/output
#	- Access				R or W or RW or WE
#	- Reset					Value upon reset
#	- Description			User-facing comments
#
# Field names are case-sensitive.
#
# The fields listed above are used to determine each register's name, address, bit width and indexes, readability and writeability, reset value, and comments.
# If any attribute cannot be determined due to omitted fields, sensible defaults are assumed. Specifically, unless otherwise specified:
#	- Width is 1 + Right - Left 
#	- Left bit indexes are 0
#	- Right is Left + Width - 1
#	- Direction is output
# 	- Access is RW
#	- Reset is 0
#	- Description is blank
#
# The program will terminate before writing any files if any combination of fields produces an irreconcilable conflict.


import csv
import sys
import os
import os.path
import argparse
# import re		
from math import *

# Register spec CSV file must start with a header row and must contain a 'Name' column and either a 'Number' or 'Offset' column
# Other supported fields include:
#	- 'Width' (in bits, for zero-based registers
#	- 'Left' (MSb index)
#	- 'Right' (LSb index)
#	- 'Description' (used for comments)
#	- 'Access' (AXI mode only. Allowed values are R, W, RW)
#	- 'Reset' (value when reset is asserted)


def str2int(s):
	try:
		value = int(s, 0)
	except (ValueError, TypeError):
		value = None
	return value
	

class Register:


	# All infer_* functions accept raw string inputs typically read directly from a CSV file.
	# Each input is converted to the appropriate data type as necessary.
	
	# Inputs are evaluated together and checked against each other for consistency.
	# After checks and rule processing, values which produce a complete and unambiguous  
	# specification are returned to the caller in a tuple.
	
	# The program will terminate immediately if any conversion fails or if any inconsistency 
	# is detected among inputs which produces conflicting or ambiguous directives.

	def infer_dimensions(left_str, right_str, width_str):
	
		left = str2int(left_str)
		right = str2int(right_str)
		width = str2int(width_str)
		
		# 2 invalid options:
		#
		# none
		if left == None and right == None and width == None:
			print("Unable to determine register dimensions: none provided")
			sys.exit()	
		# right only	
		if left == None and right != None and width == None:
			print("Unable to determine register dimensions: need left or width")
			sys.exit()
		
		# 1 possibly invalid option:
		#
		# left & right & width
		if left != None and right != None and width != None:
			if width != 1 + (left - right):
				print("Unable to determine register dimensions: mismatch between width and left/right")
				sys.exit()
					
		# 5 valid options: 
		#
		# width only (assume right=0)
		if left == None and right == None and width != None:
			right = 0
			left = width - 1	
		# left only (assume right=0)
		if left != None and right == None and width == None:
			right = 0
			width = 1 + left
		# left & right
		if left != None and right != None and width == None:
			width = 1 + (left - right)
		# left & width
		if left != None and right == None and width != None:
			right = 1 + (left - width)
		# right & width		
		if left == None and right != None and width != None:
			left = (right + width) - 1
			
		# sanity checks
		if left == None:
			print("ERROR: Sanity check failed: left == None")
			sys.exit()
		if right == None:
			print("ERROR: Sanity check failed: right == None")
			sys.exit()
		if width == None:
			print("ERROR: Sanity check failed: width == None")
			sys.exit()
		if left - right != width - 1:
			print("ERROR: Sanity check failed: left/right inconsistent with width")
			sys.exit()
			
		return (left, right, width)


	def infer_signedness(signed_str):
	
		if signed_str == None or signed_str == "":
			signed_str = ""
		
		signed_str = signed_str.upper()

		signed = 'S' in signed_str or 'Y' in signed_str
			
		return signed

		
	def infer_access(access_str):
	
		if access_str == None or access_str == "":
			access_str = "RW"
			
		readable = 'R' in access_str
		writeable = 'W' in access_str
		enableonly = 'E' in access_str
		
		if not readable and not writeable:
			print("ERROR: sanity check failed: register has no read or write access")
			sys.exit()
			
		return (readable, writeable, enableonly)
			
	
	def infer_direction(direction_str, readable, writeable):
	
		if direction_str == None:
			if writeable:
				direction_str = "output"
			else:
				direction_str = "input"
			
		elif 'i' in direction_str.lower():			
			direction_str = "input"
			
		else:
			direction_str = "output"
					
		return direction_str	
		
		
	def infer_offset(offset_str, num_data_bytes):
		
		offset = str2int(offset_str)
		
		if offset != None and offset % num_data_bytes != 0:
			print("ERROR: Register offset 0x%04X is not word-aligned" % offset)
			sys.exit()
		
		return offset
			
	
	def infer_reset(reset_str):		
		reset = str2int(reset_str)	
		if reset == None:
			reset = 0	
		format_as_hex = reset_str.lower().startswith("0x")		
		return (reset, format_as_hex)
			
	
	def infer_description(description_str):
		if description_str == None:
			description_str = ""
			
		return description_str	
		
		
	def __init__(self, fields, num_data_bits):
		self.fields = fields		
		(self.left, self.right, self.width) = Register.infer_dimensions(self.fields.get('Left'), self.fields.get('Right'), self.fields.get('Width'))
		self.name = self.fields.get('Name')
		self.signed = Register.infer_signedness(self.fields.get('Signed'))
		(self.readable, self.writeable, self.enableonly) = Register.infer_access(self.fields.get('Access'))
		self.direction = Register.infer_direction(self.fields.get('Direction'), self.readable, self.writeable)
		self.offset = Register.infer_offset(self.fields.get('Offset'), num_data_bits//8)
		(self.reset, self.format_as_hex) = Register.infer_reset(self.fields.get('Reset'))
		self.description = Register.infer_description(self.fields.get('Description'))
		if self.direction == 'input':
			self.writeable = False


	def typecode(self):
		return f"{self.width}'{'s' if self.signed else ''}"
		
	
	def __str__(self):
		return "name:{reg.name} \n\toffset:{reg.offset} \n\tresetval:{reg.reset} \n\tleft:{reg.left} right:{reg.right} width:{reg.width} \n\tdir:{reg.direction} \n\treadable:{reg.readable} writeable:{reg.writeable} \n\tdescription:{reg.description}".format(reg=self)



	
class ApbGen:

	# This class generates all elements required for an APB-compatible register bank

	def __init__(self, registers, num_data_bytes, num_addr_bits):	
		self.registers = registers		
		self.num_data_bytes = num_data_bytes
		self.num_addr_bits = num_addr_bits
		

	def gen_all_slv_rd_assns(self):
		assns = '\n'.join([self.gen_slv_rd_assn(self.num_addr_bits, reg) for reg in self.registers])
		while '\n\n' in assns:
			assns = assns.replace('\n\n', '\n')
		return f'''
always @(*)
begin
    case ({{paddr[{self.num_addr_bits-1}:2], 2'b00}})        
{assns}                         
        default: prdata = {self.num_data_bytes*8}'h0;  
    endcase
end'''
		
	def gen_slv_rd_assn(self, num_addr_bits, reg):
		if not reg.readable:
			return ''
		readval = "{{%d{%s}}, %s}" % (self.num_data_bytes*8-reg.width, f'{reg.name}[{reg.left}]' if reg.signed else "1'b0", reg.name)
		return f'''\t\t{num_addr_bits}'h{reg.offset:02X}: prdata = {readval}, {reg.name}}};'''
		

	def gen_all_port_decls(self):
		return '\n'.join([self.gen_port_decl(reg) for reg in self.registers])		

	def gen_port_decl(self, reg):
		type = 'reg' if reg.direction == 'output' else 'wire'
		sign = 'signed ' if reg.signed else ''
		dim = '' if reg.width < 2 else '[{reg.left}:{reg.right}] '.format(reg=reg)
		enable_port = "" if not reg.enableonly else "\n\toutput reg {reg.name}_wr_en,".format(reg=reg)
		return '''\t{reg.direction} {type} {sign}{dim}{reg.name},{enable_port}'''.format(reg=reg, type=type, sign=sign, dim=dim, enable_port=enable_port)
		

	def gen_all_regs(self):
		return '\n'.join([self.gen_reg(reg) for reg in self.registers])

	def gen_reg(self, reg):
		if dir == 'input':
			return
		assert_enable = "" if not reg.enableonly else "\n\t\t\t{reg.name}_wr_en <= 1'b1;".format(reg=reg)
		deassert_enable = "" if not reg.enableonly else "\n\t\t{reg.name}_wr_en <= 1'b0;".format(reg=reg)
		return f'''
always @(posedge clk)
begin
    if (reset) begin                          
        {reg.name} <= {reg.typecode()}d{reg.reset}; {deassert_enable}       
    end
    else begin {deassert_enable}                     
        if (penable && psel && pwrite && {{paddr[{self.num_addr_bits-1}:2], 2'b00}} == {self.num_addr_bits}'h{reg.offset:02X}) begin
            {reg.name} <= pwdata[{reg.left}:{reg.right}]; {assert_enable}      
        end
    end
end'''

		
		

class CGen:

	# This class generates all elements required for a memory-mapped register bank C header
	# - 

	def __init__(self, registers, num_data_bytes, num_addr_bits, regset_name):	
		self.registers = registers		
		self.num_data_bytes = num_data_bytes
		self.num_addr_bits = num_addr_bits			
		self.regset_name = regset_name	
		if self.regset_name == None or self.regset_name == "":
			print("Register set name required")
			sys.exit()
			# and self.regset_name != "":
			# self.regset_name = self.regset_name + '_'
		
		
		
	
		
		
		
		
	def gen_all_reg_defns(self):
		return '\n'.join([self.gen_reg_defn(reg.name, self.regset_name, reg.offset, reg.description) for reg in self.registers])
		
	def gen_reg_defn(self, reg_name, regset_name, reg_offset, reg_desc):
		reg_desc = "" if reg_desc == None or reg_desc == "" else "// %s" % reg_desc
		return '''#define {regset_name}_{reg_name} (*((volatile UINTPTR * const)({regset_name}_BASEADDR + {reg_offset}))) {reg_desc}'''.format(reg_name=reg_name, regset_name=regset_name, reg_offset="0x%04X"%reg_offset, reg_desc=reg_desc)
				
	def gen_all_reg_ptr_decls(self):
		return '\n'.join([self.gen_reg_ptr_decl(reg.name, self.regset_name, reg.offset, reg.description) for reg in self.registers])
		
	def gen_reg_ptr_decl(self, reg_name, regset_name, reg_offset, reg_desc):		
		reg_desc = "" if reg_desc == None or reg_desc == "" else "// %s" % reg_desc
		return '''extern volatile UINTPTR * const __{regset_name}_{reg_name}; {reg_desc}'''.format(reg_name=reg_name, regset_name=regset_name, reg_offset="0x%04X"%reg_offset, reg_desc=reg_desc)
			
	def gen_all_reg_ptr_defns(self):
		return '\n'.join([self.gen_reg_ptr_defn(reg.name, self.regset_name, reg.offset, reg.description) for reg in self.registers])
		
	def gen_reg_ptr_defn(self, reg_name, regset_name, reg_offset, reg_desc):		
		reg_desc = "" if reg_desc == None or reg_desc == "" else "// %s" % reg_desc
		return '''volatile UINTPTR * const __{regset_name}_{reg_name} = &{regset_name}_{reg_name}; {reg_desc}'''.format(reg_name=reg_name, regset_name=regset_name, reg_offset="0x%04X"%reg_offset, reg_desc=reg_desc)
			

		
	def gen_all_struct_fields(self):
		return '\n'.join([self.gen_struct_field(reg.name) for reg in self.registers])
	
	def gen_struct_field(self, reg_name):
		return '''    uint{num_field_bits}_t {reg_name};'''.format(num_field_bits=self.num_data_bytes*8, reg_name=reg_name)
	
	
	
		
	def gen_all_reset_struct_fields(self):
		return '\n'.join([self.gen_reset_struct_field(reg.name, reg.reset, reg.format_as_hex) for reg in self.registers])
	
	def gen_reset_struct_field(self, reg_name, reset_value, format_as_hex):
		reset_value = ("0x%X" if format_as_hex else "%d") % reset_value
		return '''    .{reg_name} = (uint{num_field_bits}_t){reset_value},'''.format(num_field_bits=self.num_data_bytes*8, reg_name=reg_name, reset_value=reset_value)
	
	
	
	
	
	def gen_all_set_proc_stmts(self):
		return '\n'.join([self.gen_set_proc_stmt(reg.name) for reg in self.registers])
	
	def gen_set_proc_stmt(self, reg_name):
		#return '''    {regset_name}_{reg_name} = params->{reg_name};'''.format(regset_name=self.regset_name, reg_name=reg_name)
		return '''    {regset_name}_{reg_name} = params->{reg_name};'''.format(regset_name=self.regset_name, reg_name=reg_name)
		
		
		
		
	
	def gen_all_get_proc_stmts(self):
		return '\n'.join([self.gen_get_proc_stmt(reg.name) for reg in self.registers])
	
	def gen_get_proc_stmt(self, reg_name):
		return '''    params->{reg_name} = {regset_name}_{reg_name};'''.format(regset_name=self.regset_name, reg_name=reg_name)
		
		
		
		
	def gen_all_print_proc_stmts(self):
		return '\n'.join([self.gen_print_proc_stmt(reg.name, reg.format_as_hex) for reg in self.registers])
	
	def gen_print_proc_stmt(self, reg_name, format_as_hex):
		fmt_str = "0x%X" if format_as_hex else "%d"
		return '''    xil_printf("{regset_name}_{reg_name}={fmt_str}\\r\\n", params->{reg_name});'''.format(fmt_str=fmt_str, regset_name=self.regset_name, reg_name=reg_name)
		
	
	
	def gen_all_iopacket_stmts(self):
		return '\n'.join([self.gen_iopacket_stmt(reg.name) for reg in self.registers])		
		
	def gen_iopacket_stmt(self, reg_name):
		return '''    set_named_address("{reg_name}", (uint8_t*)(__{regset_name}_{reg_name}), sizeof({regset_name}_{reg_name}));'''.format(regset_name=self.regset_name, reg_name=reg_name)

	
	
	
# def wrap_generated_content(content):
	# return "\n/* Begin generated content */\n%s\n/* End generated content */\n" % content


# def replace_in_template(template, key, content_list):
	# content = wrap_generated_content('\n'.join(content_list))
	# re_key = '([ \t]*)'+key.replace('$', '\\$')
	# match = re.search(re_key, template)
	# if not match:
		# print("ERROR: missing template key: %s" % key)
		# sys.exit()
	# indent = match.group(1)
	# content = content.replace('\n', '\n'+indent)
	# return template.replace(indent+key, content)

	
def get_key_indent(template, key):
	re_key = '([ \t]*)'+key.replace('$', '\\$')
	match = re.search(re_key, template)
	if not match:
		print("ERROR: missing template key: %s" % key)
		sys.exit()
	return match.group(1)
	

	
def number_keys(template, key):
	keys = []
	i = 0
	re_key = key.replace('$', '\\$')
	while True:
		new_key = re_key+str(len(keys))
		new_template = re.sub(re_key, new_key, template, 1)
		if new_template == template:
			[ print(k) for k in keys ]
			return keys
		else:
			list.append(new_key)
			template = new_template
	
	
	
	
def replace_preserve_indent(template, key, content):
	indent = get_key_indent(template, key)
	content = content.replace('\n', '\n'+indent)
	return template.replace(indent+key, content)
	
	
	
	
	
def write_if_changed(filename, new_contents):		
	if filename:		
		must_write = None
		if not os.path.isfile(filename):
			must_write = True
		else:
			with open(filename, 'r') as f:
				old_contents = f.read()			
			must_write = old_contents != new_contents
		if must_write:
			with open(filename, 'w') as f:
				f.write(new_contents)
				print("INFO: Wrote %s" % filename)		
		else:	
			print("INFO: skipping rewrite of unchanged file: %s" % filename)	
			
			
			
def main():

	# Build command-line argument parser
	parser = argparse.ArgumentParser(description='Generate register banks', add_help=False)	
	parser.add_argument('-i', '--input', required=True)
	parser.add_argument('-v', '--rtl', required=True)
	parser.add_argument('-h', '--c_header', required=False, default="")
	parser.add_argument('-c', '--c_body', required=False, default="")
	parser.add_argument('-n', '--name', required=False, default="")
	parser.add_argument('-w', '--width', required=False, default=64, type=int)	
	parser.add_argument('-b', '--baseaddr', required=True)	
	args = parser.parse_args()
	
	# Validate input arguments
	if not os.path.isfile(args.input):
		print("ERROR: input file does not exist: %s" % args.input)
		sys.exit()	
	if os.path.isfile(args.rtl):
		print("WARNING: RTL file already exists and may be overwritten: %s" % args.rtl)	
	if os.path.isfile(args.c_header):
		print("WARNING: C header file already exists and may be overwritten: %s" % args.c_header)	
	if os.path.isfile(args.c_body):
		print("WARNING: C body file already exists and may be overwritten: %s" % args.c_body)	
	if args.width != 32 and args.width != 64:
		print("ERROR: bit width argument must be 32 or 64. Got %d" % args.width)
		sys.exit()	
	if args.width == 32:
		print("WARNING: generating 32-bit registers. Output products will be incompatible with 64-bit architectures")
		

	templates_dir = os.path.dirname(os.path.abspath(__file__)) + "/templates/"

		
	# Load registers definitions from file
	with open(args.input) as f:
		# Read all lines from the CSV file, keeping only those with a non-empty name
		registers = list(filter(lambda reg: reg['Name'], list(csv.DictReader(f))))

		
	# Build register list
	registers = [ Register(reg, args.width) for reg in registers ]	
	[ print(str(reg)) for reg in registers ]
	
	# Assign offsets to registers which haven't been explicitly defined
	offset = 0
	for reg in registers:
		if reg.offset == None:
			while offset in [reg.offset for reg in registers]:
				offset += args.width // 8
			reg.offset = offset
	
	
	# Verify offsets are word-aligned
	for reg in registers:
		if (reg.offset % (args.width / 8)) != 0:
			print("ERROR: register %s with offset 0x%04X is not a multiple of %d" % (reg.name, reg.offset, args.width))
			sys.exit()
	
	
	# Check for address conflicts between registers
	for i in range(0, len(registers)):
		for j in range(i+1, len(registers)):
			if registers[i].offset == registers[j].offset:
				print("ERROR: multiple registers with offset 0x%04X" % registers[i].offset)
				sys.exit()
			if registers[i].name == registers[j].name:
				print("ERROR: multiple registers with name %s" % registers[i].name)
				sys.exit()
			

	num_data_bytes = args.width // 8
	max_offset = max(registers, key=lambda reg: reg.offset).offset
	num_addr_bits = int(1+floor(log2(max_offset))) #- int(log2(num_data_bytes))
	# num_addr_bits = int(ceil(log2(max_offset)))
		
	# Create APB generator
	apbgen = ApbGen(registers, num_data_bytes, num_addr_bits)
	
	# Calculate application-specific parameters
	module_name = os.path.splitext(os.path.basename(args.rtl))[0]
	opt_mem_addr_bits = num_addr_bits - 1
	num_addr_width = num_addr_bits + 1 + args.width//32

	# Load template from file
	apb_template_filename = templates_dir + "apb_template.sv"
	with open(apb_template_filename, 'r') as f:
		apb_template = f.read()
	
	
	content = {
		"${module_name}": module_name,
		"${apb_data_width}": str(args.width),
		"${apb_addr_width}": str(num_addr_width),
		"${opt_mem_addr_bits}": str(opt_mem_addr_bits),	
		"${port_decls}": apbgen.gen_all_port_decls(),
		"${slv_rd_assns}": apbgen.gen_all_slv_rd_assns(),
		"${regs}": apbgen.gen_all_regs()		
	}
	
	for k, v in content.items():
		apb_template = apb_template.replace(k, v)
	
	
	

		
	# Create C generator
	c_gen = CGen(registers, num_data_bytes, num_addr_bits, args.name)
	
	
	# Load C header template from file
	c_header_template_filename = templates_dir + "cpp_header_template.hpp"
	with open(c_header_template_filename, 'r') as f:
		c_header_template = f.read()
		
	# Calculate application-specific parameters
	include_guard = os.path.basename(args.c_header).upper().replace('.', '_')	
	

	content = {
		"${include_guard}": include_guard,
		"${regset_name}": c_gen.regset_name,
		"${baseaddr}": args.baseaddr,
		"${max_offset}": "0x%04X" % max_offset,
		"${reg_defns}": c_gen.gen_all_reg_defns(),
		"${reg_ptr_decls}": c_gen.gen_all_reg_ptr_decls(),
		"${struct_fields}": c_gen.gen_all_struct_fields()	
	}
	
	for k, v in content.items():
		c_header_template = c_header_template.replace(k, v)
	



	# Load C body template from file
	c_body_template_filename = templates_dir + "cpp_body_template.cpp"
	with open(c_body_template_filename, 'r') as f:
		c_body_template = f.read()	
			
	
	content = {
		"${c_header_filename}": args.c_header,
		"${regset_name}": c_gen.regset_name,
		"${num_data_bytes}": "%d" % c_gen.num_data_bytes,
		"${reg_ptr_defns}": c_gen.gen_all_reg_ptr_defns(),
		"${reset_struct_fields}": c_gen.gen_all_reset_struct_fields(),
		"${set_stmts}": c_gen.gen_all_set_proc_stmts(),
		"${get_stmts}": c_gen.gen_all_get_proc_stmts(),
		"${print_stmts}": c_gen.gen_all_print_proc_stmts(),
		"${iopacket_stmts}": c_gen.gen_all_iopacket_stmts()
	}
	
	for k, v in content.items():
		c_body_template = c_body_template.replace(k, v)
	
			
	write_if_changed(args.rtl, apb_template)
	write_if_changed(args.c_header, c_header_template)
	write_if_changed(args.c_body, c_body_template)
			
			
		
		
		
			

if __name__ == "__main__":
	main()
	sys.exit()	

			
			