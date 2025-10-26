#ifndef _DATA_WR_UTILS
#define _DATA_WR_UTILS

#define CONFIG_W 10

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

// conversion functions
void config_to_pinout(config_t *c, pinout_t **p, size_t pl);

// init dma

#endif // _DATA_WR_UTILS

