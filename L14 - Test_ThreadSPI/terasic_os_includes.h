#ifndef _TERASIC_OS_INCLUDE_H_
#define _TERASIC_OS_INCLUDE_H_

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h> // for clock_gettime
#include <math.h>
#include <string.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "socal/alt_spim.h" 
#include "socal/alt_rstmgr.h"

#define MY_DEBUG(msg, arg...) printf("%s:%s(%d): " msg, __FILE__, __FUNCTION__, __LINE__, ##arg)
// Uncomment following line if you want to disable debug
// #define MY_DEBUG(msg, arg...) 


#endif  //_TERASIC_OS_INCLUDE_H_
