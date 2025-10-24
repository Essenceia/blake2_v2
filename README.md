# Blake2s RTL implementation

Implementation of the Blake2 cryptographic hash function (RFC7693) in 
synthesizable RTL.

This code was designed and tested for the smaller blake2s variants in order 
to help reduce area, for a performance optimized blake2b implementation please reffer : 
- https://github.com/Essenceia/blake2


This is a fully featured blake2s implementation supporting both block streaming and 
proving the secret key. 

It has been optimized for area usage ahead of an ASIC tapeout, at the 
expense of performance. Also, this design is current I/O bottlnecked as the block data
interface is only 8 bits wide. 

![asic floorplan](/doc/layout.png)

## Testing 

### Simulation 

To run simulations :
```
cd tb
make
```
:warning: If you are using cocotb with a python virtual enviroment make sure if is sourced before running `make`

#### Cocotb 

Given `CVC` is currently the only free-of-charge ( not open source, but free for none comercial applications )
simulator supporting SDF ( Standard Delay Format ), we will be using it for running our testing. 

As such, I will be using `cocotb` to validate this design as it allows to easily 
switch between multiple simulators on the backend and will simplify porting of the
tb to tapeout flows that also used `cocotb`. 

**Note** SVF used for gate-level simulation with timing information.

#### Test vectors 

In order to help debug each step of the blake2s algorythme a more granular insight into the 
values of the intermediary vectors at each step is very handy. 
The test vector `tv` directory contains the `blake2s` implementation, as provided by the original
specification instrumented with logging of intermediary values. 
To build and run : 
```
cd tb
make run
```

### Emulation 

In order to further validate the design, it is emulated onto an 
FPGA mimicing conditions of the ASIC and connected to an external 
PR2040 microcontroller 

#### FPGA 

#### Firmware
 
