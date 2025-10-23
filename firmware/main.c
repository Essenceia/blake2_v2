#include "pico/stdlib.h"
#include <stdio.h>
#include "hardware/clocks.h"
#include "hardware/pio.h"
#include "loopback.pio.h"
#include "bus_clk.pio.h"
#include "pinout.h" 
#include "loopback_utils.h" 

#define DELAY_MS 1000

#define PIO_N 2 // number of PIO SM used
#define PIO_LED 0
#define PIO_CLK 1
#define macro_str(x) #x

#define PICO_SYS_CLK_HW 200000000 // 200 MHz
#define BUS_CLK_FREQ_HZ (float) 40000000.0 // 40 MHz

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

	pio_sm_set_enabled(pio[PIO_CLK], sm[PIO_CLK], true); 	

	/* loopback test */ 
	init_loopback_ctrl();
	init_loopback_data_hash_bus();
	
    while (true) {
		pio_sm_put_blocking(pio[PIO_LED], sm[PIO_LED], led);
		led = led ? 0:1;
		printf("Teapot ! clk div %f <3\n", clk_div);
        sleep_ms(DELAY_MS);
		test_data_loopback(2, 50);	
    }
}
