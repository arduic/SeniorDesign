% Generate a time vector given the sampling frequency
% and the total sample size wanted.
% Time starts from 0 by default.
function t=time_from_sample_length(sample_freq, sample_len)
    sample_per = 1 / sample_freq;
    end_time = sample_per * (sample_len - 1);
    t = 0:sample_per:end_time;
end