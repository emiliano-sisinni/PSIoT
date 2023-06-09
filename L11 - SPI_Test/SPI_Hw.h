// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================

#ifndef _SPI_HW_H_
#define _SPI_HW_H_

#include "terasic_os_includes.h"



void SPIHW_Init(void *virtual_base);
void SPIHW_Write8(uint8_t bIsData, uint8_t Data);
void SPIM_WriteTxData(uint8_t Data);
uint8_t SPIM_WriteReadTxRxData(uint8_t Data);
uint16_t SPIM_WriteReadTxRxData16(uint16_t Data);


#endif //_SPI_HW_H_