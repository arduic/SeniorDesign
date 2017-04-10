function [signal]=chirp_signal(t, f0, f1)
    signal = chirp(t, f0, t(end), f1);
end