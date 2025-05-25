#include "uart2axi.h"

int main(void){
	hls::stream<ap_uint<8>> rx_data;
	hls::stream<ap_uint<8>> tx_data;
	ap_uint<32>* axi;
	axi = (ap_uint<32>*)malloc(4294967296*4);

	printf("\r\n-----------------------------\r\n");
	printf("WRITE TEST\r\n");
	rx_data.write(0x01);
	rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA);
	rx_data.write(3);
	rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA);
	rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA);
	rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA);
	rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA);

	uart2axi(rx_data, tx_data, axi);

	printf("send_data:");
	for(int i=0; i<16; i++) {
		printf(" %x", tx_data.read());
	}
	printf("\r\n-----------------------------\r\n");

	printf("\r\n-----------------------------\r\n");
	printf("READ TEST\r\n");
	rx_data.write(0x00);
	rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA); rx_data.write(0xAA);
	rx_data.write(3);

	uart2axi(rx_data, tx_data, axi);

	printf("receive_data:");
    for(int i=0; i<16; i++) {
		printf(" %x", tx_data.read());
	}
	printf("\r\n-----------------------------\r\n");

	return 0;
}
