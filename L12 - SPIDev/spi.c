// SPI in C - Using spidev char driver
// Connect MOSI and MISO in loopback
// Usage spidev: send 21930 (0x55AA)
// Usage spidev num1 num2 .. numN: send numi one after the other (numi must be decimal)


#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>

static const char *device = "/dev/spidev32766.0";
static uint8_t mode = 1;			// SPI_MODE_1 
static uint8_t bits = 16;			// 16 bit at a time
static uint8_t len = 2;				// length
static uint32_t speed = 500000;		// Clock frequency [Hz]
static uint16_t delay = 0;			// Time between end of data and CS de-assert

static void exit_on_error (const char *s)	// Exit and print error code
{ 	perror(s);
  	abort();
} 

int main(int argc, char *argv[])
{
	int fd, index;
	char *p; //for string conversion

	uint16_t *tx;
	uint16_t *rx;

	rx = malloc(2);
	tx = malloc(2);

					
	struct spi_ioc_transfer tr = 
	{	.tx_buf = (unsigned long)tx,         
		.rx_buf = (unsigned long)rx,        
		.len = len,               
		.delay_usecs = delay,
		.speed_hz = speed,   
		.bits_per_word = bits,
		.cs_change = 0,
	};
	
	// Open SPI device
	if ((fd = open(device, O_RDWR)) < 0) exit_on_error ("Can't open SPI device");

	// Set SPI mode
	if (ioctl(fd, SPI_IOC_WR_MODE, &mode) == -1) exit_on_error ("Can't set SPI mode");
	// Set SPI message length
	if (ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits) == -1) exit_on_error ("Can't set SPI bits per word length");
	
	if (argc == 1)	  
		{                          
			tx[0] = (uint16_t) 0x55AA;
			printf ("Data from SPI Tx buffer: %d ", tx[0]);

			// Read and write data (full duplex)
			if (ioctl(fd, SPI_IOC_MESSAGE(1), &tr) < 1) exit_on_error ("Can't send SPI message");
					
			printf ("Data from SPI Rx buffer: %d ", rx[0]);
			printf ("\n");
		}
	else
		{
			for (index = 0; index < argc-1; index++)
				{ 
					tx[0] = (uint16_t) strtol(argv[index+1], &p, 10); 
					printf ("Data from SPI Tx buffer: %d ", tx[0]);

					// Read and write data (full duplex)
					if (ioctl(fd, SPI_IOC_MESSAGE(1), &tr) < 1) exit_on_error ("Can't send SPI message");
					
					printf ("Data from SPI Rx buffer: ");		
					printf("%d ", rx[0]);
					printf ("\n");
				}
			usleep(100 * 1000); //100ms delay
		}


	free(rx);
	free(tx);					
	close(fd);

	return (0);
}
