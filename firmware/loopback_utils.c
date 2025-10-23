#include "loopback_utils.h" 
#include "pinout.h"
#include "hardware/gpio.h" 

void init_loopback_clk()
{
	for(uint x= CTRL_BASE_PIN; x < CTRL_BASE_PIN+DATA_W; x++) {
		gpio_init(x);
		gpio_set_dir(x, GPIO_OUT);
		gpio_set_drive_strength(x, GPIO_DRIVE_STRENGTH_12MA);	
	}
}

void set_loopback_none() {
	gpio_clr_mask((uint32_t)CTRL_LOOPBACK_MASK << CTRL_BASE_PIN);
}
void set_loopback_data() {
	gpio_clr_mask((uint32_t)CTRL_LOOPBACK_MASK << CTRL_BASE_PIN);
	gpio_set_mask((uint32_t)CTRL_LOOPBACK_DATA << CTRL_BASE_PIN);
}
void set_loopback_ctrl() {
	gpio_clr_mask((uint32_t)CTRL_LOOPBACK_MASK << CTRL_BASE_PIN);
	gpio_set_mask((uint32_t)CTRL_LOOPBACK_CTRL << CTRL_BASE_PIN);
}

