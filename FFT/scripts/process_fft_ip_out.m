clear;
close all;
clc;

% name = 'FFT Output for Sum of Real Sinusoids @ 20 Hz and 60 Hz';
% name = 'FFT Output for Pulse with 10% Pulse Width';
% name = 'FFT Output for Modulated Pulse with 10% Pulse Width @ 100 Hz';
name = 'FFT Output for Chirp Signal from 10 Hz to 100 Hz';

run('config.m');

% output_data_path = 'C:\Users\lc599.DREXEL.000\SeniorDesign\FFT\scripts\sample_results\1024 fft\sim of 20 Hz and 60 Hz sine waves.txt';
data = dlmread(output_data_path);

L = size(data, 1);
f = Fs/L*(0:(L-1));
f2 = Fs/L*(0:(L/2));

% Expected
expected = dlmread(input_data_path);
signal = complex(expected(:, 1), expected(:, 2));
Y = fft(signal);
figure;
% semilogx(f, abs(Y));
plot(f, abs(Y));
title(['Expected ' name]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');

mag = sqrt(data(:, 1).^2 + data(:, 2).^2);
p1 = mag(1:(L/2)+1);
p1(2:end-1) = 2*p1(2:end-1);

figure;
plot(f, mag);
% semilogx(f, mag);
ylabel('Magnitude');
xlabel('Frequency (Hz)');
title(name);