#ifndef _LOOPBACK_UTILS_H
#define _LOOPBACK_UTILS_H

/* GPIO control of loopback pins, used for experimentations */

/* init loopback ctrl pins */
void init_loopback_ctrl();

/* set loopback modes */
void set_loopback_none();
void set_loopback_data();
void set_loopback_ctrl();

#endif // _LOOPBACK_UTILS_H
