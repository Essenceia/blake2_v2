#ifndef _PINNOUT_H
#define _PINNOUT_H

/* define pinnout to FPGA emulation */ 
#define BUS_CLK_PIN 28

#define DATA_W        8
#define DATA_BASE_PIN 0 
#define CTRL_BASE_PIN 7
#define HASH_BASE_PIN 16

/* data */ 
#define DATA_MASK (uint32_t) 0xFF
 
/* loopback mode ctrl */ 
#define CTRL_LOOPBACK_DATA (uint32_t) 0x08 
#define CTRL_LOOPBACK_CTRL (uint32_t) 0x10 
#define CTRL_LOOPBACK_MASK (uint32_t) 0x18 // bits [4:3] 8'b0001_1000
#endif //_PINNOUT_H
