#ifndef _PINNOUT_H
#define _PINNOUT_H

/* define pinnout to FPGA emulation */ 
#define BUS_CLK_PIN 28

#define DATA_W        8
#define DATA_BASE_PIN 0 
#define HASH_BASE_PIN 8
#define CTRL_BASE_PIN 16

/* data */ 
#define DATA_MASK (uint32_t) 0xFF

/* data ctrl */
#define CTRL_DATA_W 3
#define CTRL_DATA_BASE_PIN CTRL_BASE_PIN
#define CTRL_VALID_PIN CTRL_DATA_BASE_PIN 
#define CTRL_MODE0_PIN CTRL_DATA_BASE_PIN+1
#define CTRL_MODE1_PIN CTRL_DATA_BASE_PIN+2

#define CTRL_READY_PIN      (CTRL_BASE_PIN+3)
#define CTRL_HASH_VALID_PIN (CTRL_BASE_PIN+7)

/* loopback mode ctrl */ 
#define CTRL_LOOPBACK_DATA (uint32_t) 0x10 
#define CTRL_LOOPBACK_CTRL (uint32_t) 0x20 
#define CTRL_LOOPBACK_MASK (uint32_t) 0x30 // bits [5:4] 8'b0011_0000

/* PIO defines */ 
// side of data to write OUT, also used as autopull threshold
#define DATA_WR_W CTRL_MODE1_PIN



/* checking PIO defines and pinout values match */
//__Static_assert((DATA_WR_CTRL_READY_PIN) == CTRL_READY_PIN)
//__Static_assert(DATA_WR_BUS_CLK_PIN == BUS_CLK_PIN)
//__Static_assert(DATA_WR_DATA_WR_W == DATA_WR_W)
#endif //_PINNOUT_H
