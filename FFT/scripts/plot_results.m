%% Plot results
% This is meant to be run after running the modelsim simulation,
% which is meant to be run after the test_fft.m program.
close all;

M = dlmread(output_data_path);
mag = zeros(len_of_data, 1);
for i=1:size(M,1)
    mag(i)=sqrt(M(i,1)^2+M(i,2)^2);
end

L = length(M);
f = Fs/L*(0:(len_of_data-1));

% If data is noisy, this will find noisy peaks
[pks, locs] = findpeaks(mag);
% disp('Found Peaks at');
% disp(f(locs));

figure;
plot(f, mag, f(locs), pks, 'o');
title('Single Sided FFT Spectrum');