clear;
close all;
clc;

Fs = 10^6;
Tm = 10^-3;
c = 3*10^8;  % speed of light
df = 10^6;  % beat (delata freq)
fm = 1/Tm;  % modulation rate (period)
f0 = 80*10^9;  % Starting freqency

R = 10;
vr = convvel(1, 'km/h', 'm/s');

dfR = R*4*fm*df/c
dfd = vr*2*f0/c

R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards

fR = R*4*fm*df/c
fd = vr*2*f0/c

fb_up = abs(fR - fd)
fb_down = abs(fR + fd)

fb_min = 2*min(fb_up, fb_down)
df_min = min(dfR, dfd)

min_points = ceil(fb_min/df_min)
log2_min_points = 2^ceil(log2(min_points))