function [signal]=fft_modulated_pulse(t, pulse_ratio, Fs_m)
    L = length(t);
    L_p = pulse_ratio * L;
    signal = zeros(1, L);
    
    t_m = t(1:L_p);
    signal(1:L_p) = sin(2*pi*Fs_m*t_m);
end