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

Given `CVC` is currently the only free-of-charge ( not open source, but free for none comercial applications )
simulator supporting SDF ( Standard Delay Format ), we will be using it for running our testing. 



**Note** SVF used for gate-level simulation with timing information.
