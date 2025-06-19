#include "uart2axi.h"

//#include <stdio.h>

void uart2axi(
    hls::stream<ap_uint<8>> &rx_data,
	hls::stream<ap_uint<8>> &tx_data,
	ap_uint<32>* axi
) {
#pragma HLS PIPELINE off
#pragma HLS INTERFACE mode=ap_fifo port=rx_data
#pragma HLS INTERFACE mode=ap_fifo port=tx_data
#pragma HLS INTERFACE mode=m_axi bundle=gmem depth=512 max_read_burst_length=256 max_write_burst_length=256 port=axi offset=off

	ap_uint<8>  rx_type;
	ap_uint<8>  u8_temp[4];
	ap_uint<32> addr;
	ap_uint<8>  burst_len;
	ap_uint<8>  uart_buffer[256*4];
	ap_uint<32> axi_temp[256];

    if(!rx_data.empty()) {
    	rx_type = rx_data.read();
    	u8_temp[0] = rx_data.read();
    	u8_temp[1] = rx_data.read();
    	u8_temp[2] = rx_data.read();
    	u8_temp[3] = rx_data.read();
    	burst_len = rx_data.read();
    	addr = ((ap_uint<32>)u8_temp[0] << 24)
    	     + ((ap_uint<32>)u8_temp[1] << 16)
    	     + ((ap_uint<32>)u8_temp[2] << 8 )
    	     + ((ap_uint<32>)u8_temp[3] << 0 );
//      printf("-----------------------------\r\n");
//    	printf("u8_temp[0]: 0x%x\r\n", u8_temp[0]);
//    	printf("u8_temp[1]: 0x%x\r\n", u8_temp[1]);
//    	printf("u8_temp[2]: 0x%x\r\n", u8_temp[2]);
//    	printf("u8_temp[3]: 0x%x\r\n", u8_temp[3]);
//    	printf("ADDR: 0x%x\r\n", addr);
//    	printf("-----------------------------\r\n");
    	if(rx_type == 0) { // READ
            for(ap_uint<9> j=0; j<256; j++) {
#pragma HLS PIPELINE II=1 style=flp
                if(j<burst_len+1) {
                    axi_temp[j] = axi[addr+j];
                } else break;
            }
            for(ap_uint<9> j=0; j<256; j++) {
#pragma HLS PIPELINE II=1 style=flp
                if(j<burst_len+1) {
                	uart_buffer[j*4+0] = (ap_uint<8>)(axi_temp[j] >> 24);
                	uart_buffer[j*4+1] = (ap_uint<8>)(axi_temp[j] >> 16);
                	uart_buffer[j*4+2] = (ap_uint<8>)(axi_temp[j] >> 8 );
                	uart_buffer[j*4+3] = (ap_uint<8>)(axi_temp[j] >> 0 );
                } else break;
            }
            for(ap_uint<11> i=0; i<1024; i++) {
#pragma HLS PIPELINE II=1 style=flp
                if(i<(burst_len+1)*4) {
                	tx_data.write(uart_buffer[i]);
                } else break;
            }
    	} else {           // WRITE
            for(ap_uint<11> i=0; i<1024; i++) {
#pragma HLS PIPELINE II=1 style=flp
                if(i<(burst_len+1)*4) {
                	uart_buffer[i] = rx_data.read();
                } else break;
            }
            for(ap_uint<9> j=0; j<256; j++) {
#pragma HLS PIPELINE II=1 style=flp
                if(j<burst_len+1) {
                	axi_temp[j] = ((ap_uint<32>)uart_buffer[j*4+0] << 24)
                	            + ((ap_uint<32>)uart_buffer[j*4+1] << 16)
                	            + ((ap_uint<32>)uart_buffer[j*4+2] << 8 )
                	            + ((ap_uint<32>)uart_buffer[j*4+3] << 0 );
                } else break;
            }
            for(ap_uint<9> j=0; j<256; j++) {
#pragma HLS PIPELINE II=1 style=flp
                if(j<burst_len+1) {
                    axi[addr+j] = axi_temp[j];
                } else break;
            }
            for(ap_uint<11> i=0; i<1024; i++) {
#pragma HLS PIPELINE II=1 style=flp
                if(i<(burst_len+1)*4) {
                	tx_data.write(uart_buffer[i]);
                } else break;
            }
    	}
    } else {}
}
