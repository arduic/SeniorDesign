clear;
close all;
clc;

Fs = 1000;

cutoff = floor(Fs/6);
t = linspace(0, 1.2, Fs);
x = sawtooth(2*pi*t) + 1;

t2 = linspace(0, 1.2, Fs+cutoff);
y = sawtooth(2*pi*t2 - 1) + 1.2;

figure;
plot(t, x, t2, y);

figure;
plot(