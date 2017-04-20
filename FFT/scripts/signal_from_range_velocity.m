clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away
% R = 3000; vr = convvel(-100, 'mph', 'm/s');


% Tm = 100*10^-6;
Tm = 10^-4;
c = 3*10^8;  % speed of light
df = 10^6;  % beat (delata freq)
fm = 1/Tm;  % modulation rate (period)
f0 = 80*10^9;  % Starting freqency
L = 1024;  % FFT length
Fs = 1/(Tm/L);  % L points from 0 to Tm

fR = R*4*fm*df/c
fd = vr*2*f0/c

assert(fR > fd);

% Moving toward
% fb_up = abs(fR - fd)
% fb_down = abs(fR + fd)
fb_up = fR-fd
fb_down = fR+fd

% fb_up should be less than fb_down when moving
% towards radar
if vr > 0
    assert(fb_up < fb_down);
elseif vr < 0
    assert(fb_up > fb_down);
end

% Create signal
t = (0:(L-1))/L*Tm;
delay_ratio = 1/5;
cutoff = floor(L*(1-delay_ratio));
t1 = t(1:cutoff);
t2 = t(cutoff+1:end);
signal1 = sin(2*pi*fb_up*t1);
signal2 = sin(2*pi*fb_down*t2);
signal = [signal1 signal2];

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

figure;
semilogy(f, abs(Y));

figure;
plot(f, abs(Y), f(locs), pks, 'o');
refline(0, mean(abs(Y)));

fprintf('Pk @ %g Hz\n', f(locs));

%% FFT windowing
partitions = 4;
fft_size = L/partitions;
fft_results = fft_window2(signal, fft_size);
dominant_freqs = zeros(1, partitions);
f2 = (0:(fft_size/2)-1)*Fs/fft_size;
for i=1:size(fft_results, 1)
    % Keep only first half of data where f < fs/2
    data = fft_results(i, 1:(fft_size/2));
    mag = abs(data);
    
    figure;
    plot(f2, mag);
    title(sprintf('FFT for Partition %d', i));
    xlabel('Frequency');
    
    [Y,I] = max(mag);
    max_freq = f2(I);
    dominant_freqs(i) = max_freq;
end

dominant_freqs
save('close_fast_towards.mat', 'signal');

fb_up_actual = dominant_freqs(1)
fb_down_actual = dominant_freqs(end)
fr_actual = (fb_up_actual + fb_down_actual)/2
fd_actual = (fb_down_actual - fb_up_actual)/2
k1 = c/(4*fm*df);
k2 = c/(2*f0);
r = k1*fr_actual
vel = k2*fd_actual