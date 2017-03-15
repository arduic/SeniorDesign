clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away
% R = 3000; vr = convvel(-100, 'mph', 'm/s');


Tm = 10^-3;
c = 3*10^8;  % speed of light
df = 10^6;  % beat (delata freq)
fm = 1/Tm;  % modulation rate (period)
f0 = 80*10^9;  % Starting freqency
L = 1024;  % FFT length
Fs = 1/(Tm/L);  % L points from 0 to Tm

fR = R*4*fm*df/c
fd = vr*2*f0/c

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
