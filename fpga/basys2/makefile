PROJ:= emulator 

setup:
	echo "creating ise project"
	xtclsh setup.tcl

build: $(PROJ).xise
	echo "synth and building"
	xtclsh build.tcl

clean: 
	rm -f *.xise
	rm -f *.gise
	rm -rf xst
	rm -rf _xmsgs
	rm -rf _ngo
	rm -rf xlnx_*
	rm -f *_map.*
	rm -r *.{ngc,bld,ngr,stx}
	rm -f *.{syr,lso,pcf,xml,xst,xrpt,cmd_log,blif,prj}
