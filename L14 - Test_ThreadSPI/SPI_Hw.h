// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//

//
// ============================================================================


#ifndef _SPI_HW_H_
#define _SPI_HW_H_

#include "terasic_os_includes.h"



void SPIHW_Init(void *virtual_base);
void SPIHW_Close(void);
void SPIHW_Write8(uint8_t bIsData, uint8_t Data);
void SPIM_WriteTxData(uint8_t Data);
uint8_t SPIM_WriteReadTxRxData(uint8_t Data);
uint16_t SPIM_WriteReadTxRxData16(uint16_t Data);


#endif //_SPI_HW_H_