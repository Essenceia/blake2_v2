#ifndef _DATA_WR_UTILS
#define _DATA_WR_UTILS

#define CONFIG_W 10
#include "pico/stdlib.h"
#include "hardware/pio.h"
#include "pinout.h"

typedef struct __attribute__((packed)) {
	uint8_t nn;
	uint8_t kk;
	uint64_t ll;
} config_t;

typedef struct {
	union {
		uint64_t block;
		uint8_t  chunck[8];
	} data;
} data_block_t;

void send_config(uint8_t nn, uint8_t kk, uint64_t ll, uint dma_chan);

// conversion functions
void config_to_pinout(config_t *c, pinout_t *p, size_t pl);


// init dma
uint init_wr_dma_channel(PIO pio, uint sm);

// start transfer
void start_wr_dma_pinout_stream(pinout_t *p, size_t pl, uint dma_chan);

#endif // _DATA_WR_UTILS

