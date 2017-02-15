clear;
close all;
clc;

Fs = 10^3;
T = 1/Fs;
t = 0:T:1;
f0 = 1;
f1 = 100;
% t1 = t(floor(length(t)/2));
t1 = 1;
x = chirp(t, f0, t1, f1);

% t2 = (1+T):T:2;
% x2 = chirp(t2, f1, 2, 1);
% t = [t t2];
% x = [x x2];

L = length(t);

figure;
plot(t, x);

Y = fft(x);
p2 = abs(Y/L);
p1 = p2(1:L/2+1);
p1(2:end-1) = 2*p1(2:end-1);

f = Fs*(0:(L/2))/L;
figure;
plot(f, p1);


outputs = fft_window(t, x, 128, Fs);

% Find dominant frequencies
f = Fs*(0:(L/2))/L;
max_freqs = [];
for output=outputs
    [~, I] = max(output);
    max_freqs(end+1) = f(I);
end


