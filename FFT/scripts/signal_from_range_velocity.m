clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
%R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away

c = 2*10^8;  % speed of light
df = 10^6;  % beat (delata freq)
fm = 10^6;  % modulation rate (period)
f0 = 80*10^9;  % Starting freqency
% f0 = 3.3*10^9;

fR = R*4*fm*df/c
fd = vr*2*f0/c

% Moving toward
fb_up = fR - fd
fb_down = fR + fd

% fb_up should be less than fb_down when moving
% towards radar
if vr > 0
    assert(fb_up < fb_down);
elseif vr < 0
    assert(fb_up > fb_down);
end

% Generate the signal at this frequency
% Fs = 20*10^6;
% Ts = 1/Fs;
% t = 0:Ts:10^-6;
% L = length(t);
% 
% f_signal = max(fb_up, fb_down)
% signal = sin(2*pi*max(f_signal)*t);
% 
% figure;
% plot(t, signal);
% 
% f = Fs/L*(0:L-1);
% y = fft(signal);
% 
% figure;
% plot(f, abs(y));