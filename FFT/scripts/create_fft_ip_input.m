clear;
close all;
clc;

fft_len = 2^10;
Fs = 1000;
ip_width = 8;

t = time_from_sample_length(Fs, fft_len);

signal = exp(1i*2*pi*10*t) + exp(1i*2*pi*30*t)/4;
% signal = sin(2*pi*20*t) + sin(2*pi*60*t)/4;
% signal = chirp(t, 10, t(end), 100);

figure;
plot(t, real(signal));
title('Real part of input signal');
figure;
plot(t, imag(signal));
title('Imaginary part of input signal');

% Scale input to IP_WIDTH
re = real(signal);
im = imag(signal);

% Normalize the parts to fit the whole ip_width
re = floor(re*(2^ip_width-1) - 2^(ip_width-1));
im = floor(im*(2^ip_width-1) - 2^(ip_width-1));
% re = floor(normalize(re, -128, 127));
% im = floor(normalize(im, -128, 127));

re(isnan(re)) = 0;
im(isnan(im)) = 0;

figure;
plot(t, re);
title('Real part of normalized input signal');
figure;
plot(t, im);
title('Imaginary part of normalized input signal');

% Write to file
input_file = 'C:\Users\lc599.DREXEL\Desktop\data_in.txt';

data = [re' im'];
dlmwrite(input_file, data, 'delimiter', ' ');