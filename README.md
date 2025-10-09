# Blake2s RTL implementation

Implementation of the Blake2 cryptographic hash function (RFC7693) in 
synthesizable RTL.

This code was written in a configurable manner to support both BLAKE2
b and s variants, but **only the s variant has been thougrougly tested thus far**.

This version supports both block streaming and proving the secret key. 

It has been optimized for area usage ahead of an ASIC tapeout, at the 
expense of performance. This design is current I/O bottlnecked as the block data
interface is only 8 bits wide. 

![asic floorplan](/doc/layout.png)
