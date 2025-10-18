# asic emulation on fpga for testing
PROJ=emulator

# board support package
BSP=bsp.pcf
# board using package vq100 
PKG=vq100
DEVICE=hx1k

sv_files=$(wildcard ../*.v)  $(wildcard ../../*.v)

$(PROJ).blif: $(sv_files)
	yosys -p 'read -sv $^' -p 'synth_ice40 -top $(PROJ) -blif $(PROJ).blif'

$(PROJ).asc: $(PROJ).blif $(BSP)
	arachne-pnr -P $(PKG) -d 1k -o $(PROJ).asc -p $(BSP) $(PROJ).blif
	
$(PROJ).bin: $(PROJ).asc
	icepack $(PROJ).asc $(PROJ).bin

syn: $(PROJ).blif
	echo "Syn finished"

place: $(PROJ).bin
	echo "Build finished"

explain: $(PROJ).asc 
	icebox_explain $(PROJ).asc

vlog: $(PROJ).asc
	icebox_vlog -p $(PROJ).pcf $(PROJ).asc

prog: $(PROJ).bin
	iceprog $(PROJ).bin

time: $(PROJ).asc	
	icetime -p $(BSP) -d $(DEVICE) -t $(PROJ).asc -r timeing.txt

clean:
	rm -f *.asc
	rm -f *.bin
	rm -f *.blif
