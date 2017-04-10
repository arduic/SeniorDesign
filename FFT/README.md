# FFT on FPGA
1. create_fft_ip_input.m
2. Create the fft ip block from the catalog using natural order and xk_index turned on. Make sure the name is xfft_0.
   Also make sure the ip width and phase width are 8 bits.
3. Run simulation for 1024 fft size (the default size).
4. Run process_fft_ip_out.m