#include "pico/stdlib.h"
#include <stdio.h>
#include "hardware/pio.h"
#include "loopback.pio.h"

#define LED_DELAY_MS 1000
int main() {
	PIO pio;
	uint sm, offset, led = 1;
	
	stdio_init_all();
	bool s = pio_claim_free_sm_and_add_program_for_gpio_range(
		&loopback_program, 
		&pio,
		&sm, 
		&offset,
		PICO_DEFAULT_LED_PIN, 
		1, 
		true);
	printf("Starting PIO test, init sucess %d:{%d:%d}", s, sm, offset);
	hard_assert(s);

	loopback_program_init(pio, sm, offset, PICO_DEFAULT_LED_PIN);	
    while (true) {
		pio_sm_put_blocking(pio, sm, led);
		led = led ? 0:1;
		printf("Teapot ! <3\n");
        sleep_ms(LED_DELAY_MS);
    }
}
