#ifndef _PINNOUT_H
#define _PINNOUT_H

/* define pinnout to FPGA emulation */ 
#define BUS_CLK_PIN 28

#define DATA_W        8
#define DATA_BASE_PIN 0 
#define CTRL_BASE_PIN 7
#define HASH_BASE_PIN 15

/* data */ 
#define DATA_MASK (uint32_t) 0xFF
 
/* loopback mode ctrl */ 
#define CTRL_LOOPBACK_DATA (uint32_t) 0x10 
#define CTRL_LOOPBACK_CTRL (uint32_t) 0x20 
#define CTRL_LOOPBACK_MASK (uint32_t) 0x30 // bits [5:4] 8'b0011_0000
#endif //_PINNOUT_H
