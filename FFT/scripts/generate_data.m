% Generate sample simulation data to test with the
% FFT fpga implementation.

clear;
close all;
clc;

run('config.m');

% Write the package defining length of the FFT
fo = fopen(fft_config_path,'w');
fprintf(fo,'package fft_len is\n');
fprintf(fo,'constant LOG2_FFT_LEN: integer := %d;\n',log2fftlen);
fprintf(fo,'constant FFT_LEN: integer := %d;\n', fftlen);
fprintf(fo,'constant ICPX_WIDTH: integer := %d;\n',icpx_width);
fprintf(fo,'constant INPUT_FILE: string := "%s";\n', input_data_path);
fprintf(fo,'constant OUTPUT_FILE: string := "%s";\n', output_data_path);
fprintf(fo,'end fft_len;\n');
fclose(fo);

% Generate the data.
% This example is the sum of 2 sinusoidal waves with different 
% frequencies and amplitudes
len_of_data = fftlen;  % Number of samples in input signal. This can be longer than the fftlen.

% Time vector
t = time_from_sample_length(Fs, len_of_data);

%signal = sum_of_sins(Fs, t);
%signal = single_pulse(t, 1/100);
%signal = fft_modulated_pulse(t, 1/100, 20*10^9);
signal = chirp_signal(t, 10^9, 2*10^10);

re = real(signal);
im = imag(signal);
re_i = re;
im_i = im;

% The FFT implementation takes std_logic_vectors that
% represent integer values. This is for scaling and 
% shifting the values of the signal to range from 0 to 255.
mag_re = max(abs(re));
mag_im = max(abs(im));
mag_dest = 255;

% re = floor(normalize(re, 0, mag_dest));
% im = floor(normalize(im, 0, mag_dest));
re = floor((re + mag_re)*mag_dest/(2*mag_re));
im = floor((im + mag_im)*mag_dest/(2*mag_im));

% Check for NaNs which result from 0s in original vector
re(isnan(re)) = 0;
im(isnan(im)) = 0;

% Check signal
figure;
plot(t, sqrt(re.^2+im.^2));
title('Normalized signal');
figure;
plot(t, sqrt(re_i.^2+im_i.^2));
title('Original signal');

% Write to the sample data input file
fo=fopen(input_data_path,'wt');
for i=1:len_of_data
   fprintf(fo,'%d %d\n',re(i),im(i));
end
fclose(fo);

% Expected fft output
L = len_of_data;
Y = fft(signal);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

[pks, locs] = findpeaks(P1);
disp('Expected Peaks at');
disp(f(locs));

figure;
plot(f, P1, f(locs), pks, 'o');
title('Expected Single-Sided Amplitude Spectrum of X(t)');
xlabel('f (Hz)');
ylabel('|Y(f)|');
 
