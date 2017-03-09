clear;
close all;
clc;

run('config.m');
run('create_config.m');

L = fftlen;
Fs = 1000;

t = time_from_sample_length(Fs, fftlen);

% signal = exp(1i*2*pi*10*t) + exp(1i*2*pi*30*t)/4;  % good
% signal = sin(2*pi*20*t) + sin(2*pi*60*t)/4;  % good
% signal = chirp(t, 10, t(end), 100);  % good
signal = single_pulse(t, 1/1000);  % bad
% signal = single_pulse(t, 1/10);  % good
% signal = fft_modulated_pulse(t, 1/1000, 100);  % bad
% signal = fft_modulated_pulse(t, 1/10, 100);  % good

f = Fs/L*(0:(L-1));
Y = fft(signal);
figure;
plot(f, abs(Y));
title('Expected FFT output');

figure;
plot(t, abs(signal));
title('Magnitude of input signal');
figure;
plot(t, real(signal));
title('Real part of input signal');
figure;
plot(t, imag(signal));
title('Imaginary part of input signal');

% Scale input to IP_WIDTH
[re, im] = signal_normalize(signal, 2^(ip_width-1)-1);
re = floor(re);
im = floor(im);

assert(max(re) < 2^(ip_width-1));
assert(min(re) >= -2^(ip_width-1));
assert(max(im) < 2^(ip_width-1));
assert(min(im) >= -2^(ip_width-1));

figure;
plot(t, sqrt(re.^2 + im.^2));
title('Magnitude of normalized input signal');
figure;
plot(t, re);
title('Real part of normalized input signal');
figure;
plot(t, im);
title('Imaginary part of normalized input signal');

% Write to file
data = [re' im'];
dlmwrite(input_data_path, data, 'delimiter', ' ');