// ============================================================================
// SPI Test
// ============================================================================

#include "terasic_os_includes.h"
#include "SPI_Hw.h"


#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )


int main(int argc, char *argv[]) {
	//argc = 1(name of the program) + parameters
	/*
	argv[0] program name (always present)
	argv[1] first  parameter (if existing)
	argv[argc-1] last parameter
	argv[argc] is always '\0' (null pointer).
	*/
	
	void *virtual_base;
	char *p; //for strtol
	int fd, index;

	// map the address space for the LED registers into user space so we can interact with them.
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

	SPIHW_Init(virtual_base);

	if (argc == 1)	  
		{                          
			MY_DEBUG("ARGC=1\r\n");
			SPIM_WriteReadTxRxData16(0x55);
		}
	else
		{
			MY_DEBUG("ARGC!=1\r\n");
			for (index = 0; index < argc-1; index++)
				{ SPIM_WriteReadTxRxData16((uint16_t) strtol(argv[index+1], &p, 10)); }
		}
		
  
	// clean up our memory mapping and exit
	
	if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) {
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	close( fd );

	return( 0 );
}
