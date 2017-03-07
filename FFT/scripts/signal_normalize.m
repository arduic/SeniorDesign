% Normalize a complex sinal to have a magnitude up to
% a specific value
function [re, im]=signal_normalize(signal, dest_mag)
    norm_signal = signal/max(abs(signal)) * dest_mag;
    re = real(norm_signal);
    im = imag(norm_signal);
end