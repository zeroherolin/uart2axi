#ifndef __UART2AXI_H__
#define __UART2AXI_H__

#include <ap_int.h>
#include <hls_stream.h>

void uart2axi(
    hls::stream<ap_uint<8>> &rx_data,
	hls::stream<ap_uint<8>> &tx_data,
	ap_uint<32>* axi
);

#endif
