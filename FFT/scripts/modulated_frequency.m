clear;
close all;
clc;

% chirp sweep from 1 GHz to 10 GHz

Fs = 100*10^9;
Ts = 1/Fs;
duration = 10^-6;
signal_length = Fs * duration;
t = (0:(signal_length-1))*Ts;
signal = chirp(t, 10^9, t(end), 10*10^9);


figure;
plot(t, signal);


% FFT
f = Fs*(0:(signal_length/2))/signal_length;
Y = fft(signal);
p2 = abs(Y/signal_length);
p1 = p2(1:(signal_length/2)+1);
p1(2:end-1) = 2*p1(2:end-1);

figure;
plot(f, p1);