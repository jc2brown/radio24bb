
set COMMON_TCL 1

proc list_from_file {filename} {
    set f [open $filename r]
    set data [split [string trim [read $f]]]
    close $f
    return $data
}


proc add_prefix {prefix lst} {
	set x {}
	foreach e $lst {
		lappend x ${prefix}$e
	}
	return $x
}



proc puts_list {lst} {
	foreach e $lst {
		puts $e
	}
}

proc readfile {filename} {
    set f [open $filename]
    set data [read $f]
    close $f
    return $data
}

