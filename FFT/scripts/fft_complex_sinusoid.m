clear;
close all;
clc;

L = 2^10;
Fs = 1000;

t = time_from_sample_length(Fs, L);
% x = exp(1i*2*pi*10*t) + exp(1i*2*pi*30*t)/4;
x = sin(2*pi*10*t) + sin(2*pi*30*t)/4;

f = Fs/L*(0:(L-1));
Y = fft(x);

figure;
plot(f, Y);

p2 = abs(Y/L);
p1 = p2(1:(L/2)+1);

f2 = Fs/L*(0:(L/2));

figure;
plot(f2, p1);