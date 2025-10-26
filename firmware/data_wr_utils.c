#include "data_wr_utils.h" 

void config_to_pinout(config_t *c, pinout_t **p, size_t pl)
{
	uint8_t flat[CONFIG_W]; // flat config
	hard_assert(p);
	hard_assert(pl*CONFIG_W >= sizeof(*c));
	hard_assert(sizeof(flat) == sizeof(*c));
	memcpy(flat, c, sizeof(flat));
	for(uint i=0; i < CONFIG_W; i++)
	{
		memset(p[i]; 0. sizeof(p[i]));
		pinout->data_i = flat[i];
		pinout->valid_i = 1; 
		pinout->data_cmd_i = CTRL_DATA_CMD_CTRL;
	}
}

/* set up dma stream of data to pio */
void write_pinout_stream(pinout_t **p, size_t pl)
{

}
