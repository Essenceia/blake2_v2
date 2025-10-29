# Blake2s RTL implementation

Implementation of the Blake2 cryptographic hash function (RFC7693) in 
synthesizable RTL.

This code was designed and tested for the smaller blake2s variants in order 
to help reduce area, for a performance optimized blake2b implementation please reffer : 
- https://github.com/Essenceia/blake2


This is a fully featured blake2s implementation supporting both block streaming and 
proving the secret key. 

It has been optimized for area usage ahead of an ASIC tapeout, at the 
expense of performance. Also, this design is current I/O bottlenecked as the block data
interface is only 8 bits wide. 

![asic floorplan](/doc/layout.png)

## Testing 

### Simulation 

To run simulations :
```
cd tb
make
```
:warning: If you are using cocotb with a python virtual environment make sure if is sourced before running `make`

#### Cocotb 

Given `CVC` is currently the only free-of-charge ( not open source, but free for none commercial applications )
simulator supporting SDF ( Standard Delay Format ), we will be using it for running our testing. 

As such, I will be using `cocotb` to validate this design as it allows to easily 
switch between multiple simulators on the backend and will simplify porting of the
tb to tapeout flows that also used `cocotb`. 

**Note** SVF used for gate-level simulation with timing information.

#### Test vectors 

In order to help debug each step of the blake2s algorithm a more granular insight into the 
values of the intermediary vectors at each step is very handy. 
The test vector `tv` directory contains the `blake2s` implementation, as provided by the original
specification instrumented with logging of intermediary values. 
To build and run : 
```
cd tb
make run
```

### Emulation 

In order to further validate the design, and to most closely resemble an industry grade validation 
process, the design emulated onto an 
FPGA mimicking conditions of the ASIC and connected to an external 
firmware. 

#### FPGA 

For emulating the design, we are using a `basys3` FPGA board because of the
large number of pinnouts provided by it's 4 Pmod connectors and because it
embarks an official Xilinx supported JTAG probe directly on the board. 
The native presence of this probe will make debugging much more convergent as
it will allow us to use the ILA debug cores. 

Scripts are provided to automatically the entire FPGA flow in the `fpga/basys3` folder. 
```
cd fpga/basys3
```
Create the Vivado project :
```
make setup
```
Run synthesis and PnR :
```
make build
```
Write the bitstream over JTAG to the FPGA ( this doesn't write to the QSPI ):
```
make prog
``

##### Debugging 

Optionally, the flow also includes a debug option that will automatically scan the synthetised
design for all signals with the `mark_debug` property and automatically : 
- create a ILA debug core
- connect all signals marked for debug to it
To invoke this debug mode, call make with the `debug=1` argument : 
```
make build debug=1
```
Or to both build and flash :
```
make prog debug=1
```

See `debug_core.tcl` for more information on this part of the flow.

#### Firmware

For the software part of the emulation we are targetting the RP2040 microcontroller given 
it's PIO hardware allow us to implement support for the custom parallel bus protocols used
to comunicate between the firmware and the hardware.

We are using the RaspberryPi PICO board given, again, it's large number of pins, and it's
ease of access ( aka: next day shipping on amazon ). 

Code for this software lives under `firmware`, all future instructions will assume you are
in this folder.

:warning: Building this firmware requires to have a working `gcc` toolchain for the arm M0+
core family and a copy the Raspberry PI PIC SDK. The debugging process will also assume 
you are using gdb, openocd and a jlink probe.

Start by updating the `CMakeLists.txt` sdk include directive to point to your own 
copy of the SDK. 

Generate makefiles from CMakeLists : 
```
make setup
```

Build `.elf` and `.uf2` binaries 
```
make build
```

##### Debugging

For debugging the firmware we are using JLink connected via the SWD interface to the 
PICO board. 
Low level interfacing will be handled by OpenOCD and we will be using GDB for debugging. 

To start OpenOCD and connect to the cores DAP: 
```
make debug
```
If this is sucessful openOCD will start a GDB server. 
To start a new GDB session connected to this server : 
```
make gdb
```

###### Remote GDB server 

This setup doesn't assume the machine connected to the JTAG probe and the machine you will actually doing the debugging
on are the same machines. In case this is the case of your setup and you are indeed using different machines,
you simply provide the IP address of the machine running your GDB server using the `GDB_SERVER_ADDR=X.X.X.X` when 
starting gdb. 
```
make gdb GDB_SERVER_ADDR=192.168.0.145
```



