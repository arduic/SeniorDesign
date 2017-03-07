% Maximum frequency the signal can be since
% Nyquist limit is 2*sampling freqiency
function [signal]=sum_of_sins(Fs, t)
    maxFreq = Fs / 2;
    freq = maxFreq/3
    freq2 = freq/4

    signal = exp(1i*2*pi*freq*t) * 1.5;
    signal2 = exp(1i*(2*pi*freq2*t+pi/2))*3;
    signal = signal + signal2;
%     signal = sin(2*pi*freq*t)*1.5 + sin(2*pi*freq2*t)*3;
end