#include <math.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <curl/curl.h>

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



void *producer(void *);
void *consumer(void *);
