#ifndef _SPI_H_
#define _SPI_H_

void print_vector(const char *title, complex *x, int n);
void fft(complex *v, int n, complex *tmp);
void ifft(complex *v, int n, complex *tmp);
int max_index(complex *a, int n);

#endif //_SPI_H_