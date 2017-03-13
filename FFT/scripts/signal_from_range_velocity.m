clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away
% R = 3000; vr = convvel(-100, 'mph', 'm/s');

<<<<<<< HEAD
Fs = 10^6;
Tm = 10^-3;
c = 3*10^8;  % speed of light
df = 10^6;  % beat (delata freq)
fm = 1/Tm;  % modulation rate (period)
=======
c = 2*10^8;  % speed of light
Tm = 10^-6;
df = 10^6;  % beat (delata freq)
% fm = 1/Tm;  % modulation rate (period)
fm = 1000;
>>>>>>> 80b476235d74b8b5a1b48e6ef9445fc3e6de4734
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
<<<<<<< HEAD
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
=======
Fs = 10^7;
delay = Tm/6;
t1 = 0:1/Fs:(Tm-delay);
t2 = (Tm-delay):1/Fs:Tm;
signal1 = sin(2*pi*fb_up*t1);
signal2 = sin(2*pi*fb_down*t2);
signal = [signal1 signal2];
t = [t1 t2];
L = length(t);

figure;
plot(t, signal);

% FFT
Y = fft(signal);
f = Fs/L*(0:(L-1));

figure;
% semilogx(f, abs(Y));
plot(f, abs(Y));
>>>>>>> 80b476235d74b8b5a1b48e6ef9445fc3e6de4734
