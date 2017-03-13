clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away

Fs = 10^6;
Tm = 10^-3;
c = 3*10^8;  % speed of light
df = 10^6;  % beat (delata freq)
fm = 1/Tm;  % modulation rate (period)
f0 = 80*10^9;  % Starting freqency
% f0 = 3.3*10^9;

fR = R*4*fm*df/c
fd = vr*2*f0/c

% Moving toward
fb_up = abs(fR - fd)
fb_down = abs(fR + fd)

% fb_up should be less than fb_down when moving
% towards radar
if vr > 0
    assert(fb_up < fb_down);
elseif vr < 0
    assert(fb_up > fb_down);
end

% Create signal
delay = Tm/10;
t1 = 0:1/Fs:(Tm-delay);
t2 = (Tm-delay):1/Fs:Tm;

signal1 = sin(2*pi*fb_up*t1);
signal2 = sin(2*pi*fb_down*t2);

figure;
plot(t1, signal1, t2, signal2);

% FFT
signal = [signal1 signal2];
L = length(signal);
Y = fft(signal);
f = Fs/L*(0:L-1);

figure;
% semilogx(f, abs(Y));
semilogy(f, abs(Y));
% plot(f, abs(Y));