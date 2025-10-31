#ifndef _DATA_WR_UTILS
#define _DATA_WR_UTILS

#include "pico/stdlib.h"
#include "hardware/pio.h"
#include "pinout.h"

#define CONFIG_W 10

typedef struct __attribute__((packed)) {
	uint8_t kk;
	uint8_t nn;
	uint64_t ll;
} config_t;

typedef struct {
	union {
		uint64_t block;
		uint8_t  chunck[8];
	} data;
} data_blocs_t;

void send_config(uint8_t kk, uint8_t nn, uint64_t ll, uint dma_chan, pinout_t *p, size_t pl);

void send_data(uint8_t *data, size_t dl, uint dma_chan, pinout_t *p, size_t pl);

// conversion functions
void config_to_pinout(config_t *c, pinout_t *p, size_t pl);

void data_to_blocs(uint8_t *d, size_t dl, data_blocs_t* b, size_t bl); 
void block_to_pinout(data_blocs_t *b, size_t bl, pinout_t *p, size_t pl);
void wr_dma_pinout_blocs(pinout_t *t, uint dma_chan);

// init dma
uint init_wr_dma_channel(PIO pio, uint sm);

// start transfer
void start_wr_dma_pinout_stream(pinout_t *p, size_t pl, uint dma_chan);

#endif // _DATA_WR_UTILS

