import re
import sys

# Replace each occurrence of key in template with key_N where N is the
# number of replacements made prior to the current occurrence
# Returns a tuple (new_template, keys) where new_template is the template 
# after all replacements, and keys is a list of each generated key_N 
def number_keys(template, key):
	keys = []
	i = 0
	re_key = "\\$\{%s\}" % key
	while True:
		new_key = "%s_%d" % (key, len(keys))
		new_template = re.sub(re_key, "${%s}" % new_key, template, 1)
		if new_template == template:
			return (new_template, keys)
		else:
			keys.append(new_key)
			template = new_template
			
			
			
	
def get_key_indent(template, key):
	re_key = "([ \t]*)\\$\\{%s\\}" % key
	match = re.search(re_key, template)
	if not match:
		print("ERROR: missing template key: %s" % key)
		sys.exit()
	return match.group(1)
	
	
	
# Preserves indentation
def replace_in_template(template, key, content):
	(template, keys) = number_keys(template, key)
	for k in keys:
		print("k="+k)
		indent = get_key_indent(template, k)
		k = "${%s}" % k
		new_content = content.replace('\n', '\n'+indent)
		template = template.replace(k, new_content, 1)
	return template
			
			
def fill_template(template, content):
	for k, v in content.items():
		template = replace_in_template(template, k, v)
	return template

	
			
template = '''
${key_a}
	 ${key_a}
	${key_a}
   ${key_a}
${key_b}
 ${key_b}
${key_c}
'''


content = {
	"key_a" : "KEY\nA\nCONTENT\n",
	"key_b" : "KEY\nB\nCONTENT\n",
	"key_c" : "KEY\nC\nCONTENT\n",
}



print(fill_template(template, content))
