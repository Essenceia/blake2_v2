set file_list [glob ../*.v *.v]

foreach f $file_list {
	xfile add $f
}
