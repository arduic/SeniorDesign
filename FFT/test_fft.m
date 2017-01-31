clear;
close all;
clc;

% Modify the length of the FFT in the line below
log2fftlen = 10;

% Increase this to support signals with larger amplitudes
% When changing though, be sure to restart the whole simulation
% Since this value is written to and hardcoded in a vhdl
% script that already exists at runtime.
% TODO: Have this read from a file instead.
icpx_width = 32;

% Write the package defining length of the FFT
fo = fopen('fft_len.vhd','w');
fprintf(fo,'package fft_len is\n');
fprintf(fo,'constant LOG2_FFT_LEN: integer := %d;\n',log2fftlen);
fprintf(fo,'constant FFT_LEN: integer := 2 ** LOG2_FFT_LEN;\n');
fprintf(fo,'constant ICPX_WIDTH: integer := %d;\n',icpx_width);
fprintf(fo,'end fft_len;\n');
fclose(fo);

fftlen=2^log2fftlen;  % Transform length/point size

%Generate the data. Now it is only a noise, but you
%can generate something with periodic components
%It is important, that values fit in range of representation
%(-2,2) for standard implementation.
%May be changed if you redefine our icpx_number format
%To check that calculation of spectrum for overlapping windows 
%works correctly, we generate a longer data stream...
start_time = 0;
len_of_data=fftlen;  % Number of samples in input signal

Fs=10*10^9;
T = 1/Fs;

t = time_from_sample_length(Fs, len_of_data);

% Maximum frequency the signal can be since
% Nyquist limit is 2*sampling freqiencu
maxFreq = Fs / 2;
freq=maxFreq/3
freq2=freq/4

%mag = 1.5;
signal = exp(1i*2*pi*freq*t) * 1.5;
signal2 = exp(1i*(2*pi*freq2*t+pi/2))*3;
signal = signal + signal2;

re=real(signal);
im=imag(signal);

mag_re = max(abs(re));
mag_im = max(abs(im));
mag_dest = 255;
re = floor((re + mag_re)*mag_dest/(2*mag_re));
im = floor((im + mag_im)*mag_dest/(2*mag_im));

fo=fopen('data_in2.txt','w');
for i=1:len_of_data
   fprintf(fo,'%g %g\r\n',re(i),im(i)); %Because windows doesn't add \r
end
fclose(fo);

% Expected fft output
L = len_of_data;
Y = fft(signal);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

[pks, locs] = findpeaks(P1);
disp('Expected Peaks at');
disp(f(locs));

figure;
plot(f, P1, f(locs), pks, 'o');
title('Expected Single-Sided Amplitude Spectrum of X(t)');
xlabel('f (Hz)');
ylabel('|Y(f)|');


%% This does not interact with the vhdl program
% %Create the Hann window.
% %Remember, that you must use the same window function
% %in your VHDL code!
% x=0:(fftlen-1);
% hann=0.5*(1-cos(2*pi*x/(fftlen-1)));
% %Now we calculate the FFT in octave
% scale = 2^(icpx_width-2);
% fo=fopen('data_out.txt','w');
% for i=1:(fftlen/2):(len_of_data-fftlen)
%    x=i:(i+fftlen-1);
%    di = (re(x)+1i*im(x))*scale/fftlen;
%    fr = fft(di.*hann);
% %   fr = fft(di);
%    fprintf(fo,'FFT RESULT BEGIN\n');
%    for k=1:fftlen
%      fprintf(fo,'%d %d\r\n',floor(real(fr(k))),floor(imag(fr(k))));
%    end
%    fprintf(fo,'FFT RESULT END\n');
% end
% fclose(fo);

%% Linux stuff that won't work on windows since it makes system calls

%Run the simulation
%system("make clean; make")
%Compare results calculated in octave and in our IP core
%system("vim -d data_oct.txt data_out.txt")
 
