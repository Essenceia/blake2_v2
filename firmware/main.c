#include "pico/stdlib.h"
#include <stdio.h>
#include "pinout.h" 
#include "pinout_pio_match.h" 

#include "hardware/clocks.h"
#include "hardware/pio.h"
#include "hardware/dma.h"

#include "loopback.pio.h"
#include "bus_clk.pio.h"
#include "data_wr.pio.h"
#include "data_wr_utils.h" 

#define DELAY_MS 1000

#define PIO_N 3 // number of PIO SM used
#define PIO_LED 0
#define PIO_CLK 1
#define PIO_WR  2
#define macro_str(x) #x

#define PICO_SYS_CLK_HW 200000000 // 200 MHz
#define BUS_CLK_FREQ_HZ (float) 40000000.0 // 40 MHz

#define _DMA_BASE (uint32_t) 0x50000000
#define TC_OFF   (uint32_t) 0x008
#define TRANSFER_COUNT_ADDR (_DMA_BASE + TC_OFF)

#define log_init(PIO_IDX) printf(#PIO_IDX " init sucess %d:{%d:%d}", s, sm[PIO_IDX], offset[PIO_IDX]);
int main() {
	PIO pio[PIO_N];
	uint sm[PIO_N];
	uint offset[PIO_N];
	float clk_div; 
	uint led = 1;

	// set system clk
	set_sys_clock_hz(PICO_SYS_CLK_HW, true);
	
	stdio_init_all();
	
	/* led */
	bool s = pio_claim_free_sm_and_add_program_for_gpio_range(
		&loopback_program, 
		&pio[PIO_LED], &sm[PIO_LED], &offset[PIO_LED],
		PICO_DEFAULT_LED_PIN, 1, true);
	log_init(PIO_LED);
	hard_assert(s);
	loopback_program_init(pio[PIO_LED], sm[PIO_LED], offset[PIO_LED], PICO_DEFAULT_LED_PIN);	

	/* bus clk */
	s &= pio_claim_free_sm_and_add_program_for_gpio_range(
		&bus_clk_program, 
		&pio[PIO_CLK], &sm[PIO_CLK], &offset[PIO_CLK],
		BUS_CLK_PIN, 1, true);
	log_init(PIO_CLK);
	hard_assert(s);
	clk_div = (float)clock_get_hz(clk_sys) / (BUS_CLK_FREQ_HZ*2); 
	bus_clk_program_init(pio[PIO_CLK], sm[PIO_CLK], offset[PIO_CLK], BUS_CLK_PIN, clk_div);

	gpio_set_drive_strength(BUS_CLK_PIN, GPIO_DRIVE_STRENGTH_12MA);
	gpio_set_slew_rate(BUS_CLK_PIN, GPIO_SLEW_RATE_FAST);

	/* data wr */ 
	s &= pio_claim_free_sm_and_add_program(&data_wr_program, &pio[PIO_WR], &sm[PIO_WR], &offset[PIO_WR]);
	log_init(PIO_WR);
	hard_assert(s);
	data_wr_program_init(pio[PIO_WR], sm[PIO_WR], offset[PIO_WR], clk_div);

	/* start PIOs: let clock pio start a bit earlier since it is used to clk hw and we need to aquire a lock */
	hard_assert(pio[PIO_CLK] == pio[PIO_WR]);
	pio_enable_sm_mask_in_sync(pio[PIO_CLK], 1 << sm[PIO_CLK] | 1 << sm[PIO_WR]);

	/* data wr */ 
	uint wr_dma_chan = init_wr_dma_channel(pio[PIO_WR], sm[PIO_WR]);
	send_config(0xde, 0xad, 0xbeafbeaf, wr_dma_chan);	

	uint32_t *tc = (uint32_t*)TRANSFER_COUNT_ADDR; 
    while (true) {
		pio_sm_put_blocking(pio[PIO_LED], sm[PIO_LED], led);
		led = led ? 0:1;
		printf("DMA channel busy %d wr PIO TX FIFO lvl %d trans count %d\n",
			dma_channel_is_busy(wr_dma_chan),
			pio_sm_get_tx_fifo_level(pio[PIO_WR], sm[PIO_WR]), 
			*tc);
		sleep_ms(DELAY_MS);
    }
}
