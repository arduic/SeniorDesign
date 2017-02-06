% Create a time vector given a sampling frequency
% and start and end time for the signal.
function t=time_from_start_end(sample_freq, start_time, end_time)
    T = 1/sample_freq;
    t = start_time:T:end_time;
end