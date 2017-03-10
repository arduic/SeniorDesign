clear;
close all;
clc;

run('config.m');

data_out_dir = [getenv('HOMEDRIVE') getenv('HOMEPATH') '\Desktop'];
data = dlmread(output_data_path);

L = size(data, 1);
f = Fs/L*(0:(L-1));
f2 = Fs/L*(0:(L/2));

% Expected
expected = dlmread(input_data_path);
signal = complex(expected(:, 1), expected(:, 2));
Y = fft(signal);
figure;
plot(f, abs(Y));
title('Expected FFT output');

mag = sqrt(data(:, 1).^2 + data(:, 2).^2);
p1 = mag(1:(L/2)+1);
p1(2:end-1) = 2*p1(2:end-1);

[pks, locs] = findpeaks(mag);
[pks2, locs2] = findpeaks(p1);

figure;
plot(f, mag, f(locs), pks, 'o');
% semilogx(f, mag, f(locs), pks, 'o');
ylabel('Magnitude');
xlabel('Frequency (Hz)');