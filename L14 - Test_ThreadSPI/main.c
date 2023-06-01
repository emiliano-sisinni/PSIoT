/* Code for Producer/Consumer problem using mutex and condition variables */
/* 16-bit data are sent to the HPS via the SPIM0                          */
/* Result read back is processed by FFT and index of mac power components */
/* is sent to ThingSpeak                                                  */


#include "main.h"

// global variables 
buffer_t buffer; /* shared circular buffer */

pthread_t tid[NUM_THREADS]; /* array of thread IDs */

CURL *curl; /* cURL object*/


int main(int argc, char *argv[]) {

  int i, fd;
  // for cURL
  CURLcode res;
  void *lib_handle;
  struct curl_slist *header = NULL;

  // for mmap
 	void *virtual_base;

  lib_handle = curl_load();
  if (!lib_handle) {
    fprintf(stderr, "curl_load failed!\r\n");
        return 0;
    }

  curl = dl_curl_easy_init();

  /* Modify a header curl otherwise adds differently */
  header = dl_curl_slist_append(header, "Host: api.thingspeak.com");
  header = dl_curl_slist_append(header, "User-Agent: libcurl-agent/1.0");

  /* set our custom set of headers */
  res = dl_curl_easy_setopt(curl, CURLOPT_HTTPHEADER, header);
  if (res != CURLE_OK) {
    fprintf(stderr, "curl_easy_setopt() failed: %s\n", dl_curl_easy_strerror(res));
    }

	// map the address space for the registers into user space so we can interact with them.
	// we'll actually map in the entire CSR span of the HPS since we want to access various registers within that span
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}

	virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );

	if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	// Init the HW SPI
	SPIHW_Init(virtual_base);

  

  printf("Producer - Consumer; buffer length: %d \n", BSIZE);

  pthread_cond_init(&(buffer.more), NULL);
  pthread_cond_init(&(buffer.less), NULL);

  pthread_create(&tid[1], NULL, consumer, NULL);
  pthread_create(&tid[0], NULL, producer, NULL);
  
  // pthread_join is needed to ensure that child threads are executed even if main is ended
  for (i = 0; i < NUM_THREADS; i++)
    pthread_join(tid[i], NULL);

  printf("\nmain() reporting that all %d threads have terminated\n", i);

  dl_curl_easy_cleanup(curl);
  curl_unload(lib_handle);

  SPIHW_Close();

  return(0);

} /* main */

void *producer(void *parm) {
  complex item;
  int i;
  int16_t temp;
  real tempf;
  printf("producer started.\n");
  i = 0;

  while (1) {
    /* produce an item: one cos() sample */
    item.Re = 0.250 * cos(2 * freq1 * PI * i / (double)N) +
              0.125 * cos(2 * freq2 * PI * i / (double)N);
    item.Im = 0;

    temp = (int16_t) (item.Re * 32768);

    printf("Data In SPI: %f; Integer: %d\n", item.Re, (uint16_t) temp);
    
    temp = (int16_t) SPIM_WriteReadTxRxData16( temp );
    tempf = ((real) temp ) / 32768;

    printf("Data Out SPI %f.\n", tempf);

    pthread_mutex_lock(&(buffer.mutex));
    if (buffer.occupied >= BSIZE)
      printf("producer waiting.\n");
    while (buffer.occupied >= BSIZE)
      pthread_cond_wait(&(buffer.less), &(buffer.mutex));

    printf("producer executing and generating: %f %f\n", tempf, item.Im);

    item.Re = tempf;

    buffer.buf[buffer.nextin++] = item;
    buffer.nextin %= BSIZE;
    buffer.occupied++;

    /* now: either buffer.occupied < BSIZE and buffer.nextin is the index
       of the next empty slot in the buffer, or
       buffer.occupied == BSIZE and buffer.nextin is the index of the
       next (occupied) slot that will be emptied by a consumer
       (such as buffer.nextin == buffer.nextout) */

    pthread_cond_signal(&(buffer.more));
    pthread_mutex_unlock(&(buffer.mutex));

    i = (i + 1) % N;

    // determine sample rate putting producer into sleep for T
    usleep(T * 1000 * 1000);
  }

  printf("producer exiting.\n");
  pthread_exit(0);
}

void *consumer(void *parm) {
  complex item[NUMITEMS], scratch[NUMITEMS];
  char bufferurl[200];
  int i, freqmax;
  CURLcode res;

  printf("consumer started.\n");

  while (1) {
    for (i = 0; i < NUMITEMS; i++) {
      pthread_mutex_lock(&(buffer.mutex));

      if (buffer.occupied <= 0)
        printf("consumer waiting.\n");
      while (buffer.occupied <= 0)
        pthread_cond_wait(&(buffer.more), &(buffer.mutex));

      printf("consumer executing.\n");

      item[i] = buffer.buf[buffer.nextout++];
      printf("Acquired: %f %f\n", item[i].Re, item[i].Im);
      buffer.nextout %= BSIZE;
      buffer.occupied--;

      /* now: either buffer.occupied > 0 and buffer.nextout is the index
         of the next occupied slot in the buffer, or
         buffer.occupied == 0 and buffer.nextout is the index of the next
         (empty) slot that will be filled by a producer (such as
         buffer.nextout == buffer.nextin) */

      pthread_cond_signal(&(buffer.less));
      pthread_mutex_unlock(&(buffer.mutex));
    }
    
    fft(item, N, scratch);
    print_vector("FFT", item, N);

    freqmax = max_index(item, N);
    printf("Max power @ frequency: %d\n", freqmax);

    sprintf(bufferurl, "https://api.thingspeak.com/update.json?api_key=HWYUZV1PSPC2HHJV&field1=%d", freqmax);
    dl_curl_easy_setopt(curl, CURLOPT_URL, bufferurl);
    res = dl_curl_easy_perform(curl);
    if (res != CURLE_OK) {
        fprintf(stderr, "curl_easy_perform() failed: %s\n", dl_curl_easy_strerror(res));
    } else {
        printf("\r");
        fflush(stdout);
    }


  }
  printf("consumer exiting.\n");
  pthread_exit(0);

}
