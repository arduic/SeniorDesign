clear;
close all
clc;

%% FFT equal size signals
fft_size = 1024;
repeats = 4;
Fs = 1000;
Ts = 1/Fs;
L = fft_size*repeats;
t = (0:(L-1))*Ts;
signal = zeros(1, L);
f0 = 100;
freqs = zeros(1,repeats);

% Make different chunks
for i=0:(repeats-1)
    start = i*fft_size+1;
    end_ = (i+1)*fft_size;
    f_i = f0*(i+1);
    freqs(i+1) = f_i;
    signal(start:end_) = sin(2*pi*f_i*t(start:end_));
end

fft_results = fft_window2(signal, fft_size);
f = (0:(fft_size/2)-1)*Fs/fft_size;
dominant_freqs = zeros(1, repeats);
for i=1:size(fft_results, 1)
    % Keep only first half of data where f < fs/2
    data = fft_results(i, 1:(fft_size/2));
    mag = abs(data);
    
    [Y,I] = max(mag);
    max_freq = f(I);
    dominant_freqs(i) = max_freq;
end

freqs
dominant_freqs

%% FFT signals are slightly shifted
signal = circshift(signal, [ceil(length(signal)/10), 0]);
fft_results = fft_window2(signal, fft_size);
f = (0:(fft_size/2)-1)*Fs/fft_size;
dominant_freqs = zeros(1, repeats);
for i=1:size(fft_results, 1)
    % Keep only first half of data where f < fs/2
    data = fft_results(i, 1:(fft_size/2));
    mag = abs(data);
    
    [Y,I] = max(mag);
    max_freq = f(I);
    dominant_freqs(i) = max_freq;
end

freqs
dominant_freqs