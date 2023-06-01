#ifndef _MAIN_H_
#define _MAIN_H_

#include "terasic_os_includes.h"
#include "SPI_Hw.h"

#include <math.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <curl/curl.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>


#define q 3        /* for 2^3 points */
#define N (1 << q) /* N-point FFT, iFFT */

// generating a sum of cos @ freq1 and freq2
#define freq1 3
#define freq2 1
// sample rate
#define T 1

// buffer size
#define BSIZE 4
// items the consumer retrieves
#define NUMITEMS N
typedef float real;

typedef struct {
  real Re;
  real Im;
} complex;

typedef struct {
  complex buf[BSIZE];
  int occupied;
  int nextin, nextout;
  pthread_mutex_t mutex;
  pthread_cond_t more;
  pthread_cond_t less;
} buffer_t;



#ifndef PI
#define PI 3.14159265358979323846264338327950288
#endif


#define NUM_THREADS 2

#include "dl_curl.h"
#include "fft.h"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

void *producer(void *);
void *consumer(void *);


#endif //_MAIN_H_
