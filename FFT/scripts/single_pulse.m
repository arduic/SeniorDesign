function [signal]=single_pulse(t, pulse_ratio)
    L = length(t);
    L_p = pulse_ratio * L;
    signal = zeros(1, L);
    signal(1:L_p) = 1;
end