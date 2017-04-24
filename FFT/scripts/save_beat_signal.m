clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away
% R = 3000; vr = convvel(100, 'mph', 'm/s');

run('config.m');

L = 1024;  % FFT length
Fs = 1/(Tm/L);  % L points from 0 to Tm

[signal, t] = generate_beat_signal(L, df, c, f0, Tm, R, vr);

figure;
plot(t, signal);
title('Input Signal');
xlabel('Time (s)');

% FFT
Y = fft(signal);
f = Fs/L*(0:(L-1));
mag = abs(Y);
lim = mean(mag);

[pks, locs] = findpeaks(mag, 'MinPeakHeight', lim, 'NPeaks', 4, 'SortStr', 'descend');

%     figure;
%     semilogy(f, abs(Y));
% 
%     figure;
%     plot(f, abs(Y), f(locs), pks, 'o');
%     refline(0, mean(abs(Y)));

%     fprintf('Pk @ %g Hz\n', f(locs));

%% FFT windowing
fft_size = L/windows;
fft_results = fft_window2(signal, fft_size);
dominant_freqs = zeros(1, windows);
f2 = (0:(fft_size/2)-1)*Fs/fft_size;
for i=1:size(fft_results, 1)
    % Keep only first half of data where f < fs/2
    data = fft_results(i, 1:(fft_size/2));
    mag = abs(data);

%         figure;
%         plot(f2, mag);
%         title(sprintf('FFT for Partition %d', i));
%         xlabel('Frequency');

    [Y,I] = max(mag);
    max_freq = f2(I);
    dominant_freqs(i) = max_freq;
end

dominant_freqs;
save(beat_signal_file, 'signal');

fb_up_actual = dominant_freqs(1)
fb_down_actual = dominant_freqs(end)
fr_actual = (fb_up_actual + fb_down_actual)/2
fd_actual = (fb_down_actual - fb_up_actual)/2
k1 = c/(4*fm*df);
k2 = c/(2*f0);
r = k1*fr_actual
vel = k2*fd_actual