%{
Args:
    signal: Vector of signal

Returns:
    2D plot of the fft spectrum where the rows are the
    spectrum every fft_size
%}
function [result]=fft_window2(signal, fft_size)
    start = 1;
    signal_len = length(signal);
    result = zeros(ceil(signal_len/fft_size), fft_size);
    i = 1;
    while start <= signal_len
        end_ = min(signal_len, start+fft_size);
        chunk_size = end_ - start;
        
        % Window to take the fft for
        fft_chunk = zeros(1, fft_size);
        fft_chunk(1:chunk_size) = signal(start:end_-1);  % I really don't like the index from 1
        Y = fft(fft_chunk);
        result(i, :) = Y;
        
        start = start + fft_size;
        i = i + 1;
    end
end