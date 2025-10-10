#include <stdio.h>
#include "blake2s.h" 

// input vector size in bytes
#define IN_SIZE (size_t) 3
// output vector size in bytes
#define OUT_SIZE (size_t) 32

int main(){
	size_t i;
	uint8_t d[IN_SIZE], o[OUT_SIZE];
	
	// generate new test vector
	d[0] = 'a';
	d[1] = 'b';
	d[2] = 'c';	

	printf("\"inlen\":%ld,\"in[%ld:0]\":\"", IN_SIZE, IN_SIZE*8-1);
	for(i=IN_SIZE;i>=0;i--){
		printf("%02X",d[i]);
	}
	printf("\"\n");
	
	// uint8_t *out, const void *in, const void *key, size_t outlen, size_t inlen, size_t keylen );	
	blake2s(&o, OUT_SIZE, NULL, 0, &d, IN_SIZE);		
	
	printf("\",\"outlen\":%ld,\"out[%ld:0]\":\"", OUT_SIZE, OUT_SIZE*8-1);
	for( i =OUT_SIZE; i>=0 ;i-- ){
		printf("%02X",o[i]);
	};
	printf("\"\n");
	
	return 0;
}
