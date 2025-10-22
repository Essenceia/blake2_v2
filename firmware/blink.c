#include "pico/stdlib.h"
#include <stdio.h>

#define LED_DELAY_MS 1000

// Perform initialisation
int pico_led_init(void) {
    // A device like Pico that uses a GPIO for the LED will define PICO_DEFAULT_LED_PIN
    // so we can use normal GPIO functionality to turn the led on and off
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
    return PICO_OK;
}

// Turn the led on or off
void pico_set_led(bool led_on) {
    // Just set the GPIO on or off
    gpio_put(PICO_DEFAULT_LED_PIN, led_on);
}

int main() {
	bool led = true;
    int rc = pico_led_init();
    hard_assert(rc == PICO_OK);
	stdio_init_all();
    while (true) {
        pico_set_led(led);
		led = !led;
		printf("Teapot ! <3\n");
        sleep_ms(LED_DELAY_MS);
    }
}
