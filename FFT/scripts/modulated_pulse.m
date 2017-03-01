clear;
close all;
clc;

% 1 ns pulse over 1 us period

Fs = 100*10^9;
Ts = 1/Fs;
duration = 10^-6;
pulse_duration = 10^-9;
signal_length = Fs * duration;
pulse_length = Fs * pulse_duration;
t = (0:(signal_length-1))*Ts;
signal = zeros(1, signal_length);

% modulated 1 ns pulse
% signal(1:pulse_length) = 1;
Fs_m = 10*10^9;
Ts_m = 1/Fs_m;
t_m = t(1:pulse_length);
signal(1:pulse_length) = sin(2*pi*Fs_m*t_m);

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