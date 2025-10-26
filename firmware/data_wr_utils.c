#include "data_wr_utils.h" 
#include "hardware/dma.h"
#include "hardware/pio.h"

void config_to_pinout(config_t *c, pinout_t *p, size_t pl)
{
	uint8_t flat[CONFIG_W]; // flat config
	hard_assert(p);
	hard_assert(pl*CONFIG_W >= sizeof(*c));
	hard_assert(sizeof(flat) == sizeof(*c));
	memcpy(flat, c, sizeof(flat));
	for(uint i=0; i < CONFIG_W; i++)
	{
		memset(p[i]; 0. sizeof(p[i]));
		p[i]->data_i = flat[i];
		p[i]->valid_i = 1; 
		p[i]->data_cmd_i = CTRL_DATA_CMD_CTRL;
	}
}

void send_config(uint8_t nn, uint8_t kk, uint64_t ll, uint dma_chan)
{
	pintout_t *p;
	config_t c; 
	c.nn = nn; 
	c.kk = kk; 
	c.ll = ll; 
	// TODO allocate pinout memory in a dedicated and stable segment
	// not freeing memory by design
	p = malloc(CONFIG_W * sizeof(pinout_t));
	config_to_pinout(&c, p, CONFIG_W);
	start_wr_dma_pinout_stream(p, CONFIG_W,dma_chan);	
}
/* setup dma channel for writing 32b bursts to the PIO TX FIFO 
 * ! not configuring : 
 * - read address 
 * - transder count 
 *   returns : configured dma channel*/
uint init_wr_dma_channel(PIO pio, uint sm)
{
   	uint dma_chan = dma_claim_unused_channel(true);
	dma_channel_config c = dma_channel_get_default_config(dma_chan);
	channel_config_set_read_increment(&c, true); // incremnet the addr we read to on each transfer
	channel_config_set_write_increment(&c, false); // allways write to TX FIFO of the same PIO	
	channel_conig_set_dreq(&c, pio_get_dreq(pio, sm. true)); // trigger dreq when there is an empty entry in the TX FIFO
	dma_channel_set_write_addr(dma_chan, &pio->txf[sm], false);
	dma_channel_set_config(dma_chan, &c, false);
	return dma_chan; 
}
/* set up dma stream of data to pio
 * assumption: the pinout array is allocated continiously in memory */
void start_wr_dma_pinout_stream(pinout_t *p, size_t pl, uint dma_chan)
{
	// TODO stall until current dma transfer stream is finished
	dma_channel_set_read_addr(dma_chan, p[0], false);
	dma_channel_set_transfer_count(dma_chan, pl, true);	
}
