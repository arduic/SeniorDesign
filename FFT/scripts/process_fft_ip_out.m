clear;
close all;
clc;

% name = 'FFT Output for Sum of Real Sinusoids @ 20 Hz and 60 Hz';
% name = 'FFT Output for Pulse with 10% Pulse Width';
% name = 'FFT Output for Modulated Pulse with 10% Pulse Width @ 100 Hz';
name = 'FFT Output for Chirp Signal from 10 Hz to 100 Hz';

run('config.m');

actual = dlmread(output_data_path);
expected = dlmread(input_data_path);

for i=1:windows
    start = (i-1)*fftlen + 1;
    end_ = i*fftlen;
    
    L = fftlen;
    f = Fs/L*(0:(L-1));

    % Expected
    signal = complex(expected(start:end_, 1), expected(start:end_, 2));
    Y = fft(signal);
    figure;
    % semilogx(f, abs(Y));
    plot(f, abs(Y));
    title(sprintf('Expected %s pt. %d', name, i));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');

    mag = sqrt(actual(start:end_, 1).^2 + actual(start:end_, 2).^2);
    p1 = mag(1:(L/2)+1);
    p1(2:end-1) = 2*p1(2:end-1);

    figure;
    plot(f, mag);
    % semilogx(f, mag);
    ylabel('Magnitude');
    xlabel('Frequency (Hz)');
    title(sprintf('Actual %s pt. %d', name, i));
end