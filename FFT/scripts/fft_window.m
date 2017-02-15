function [outputs]=fft_window(samples, fft_size, f)
    assert(length(samples) >= fft_size);

    outputs = [];
    start = 1;
    while start <= length(samples)
        window = samples(start:min(end, start+fft_size));
        
        figure;
        plot(1:length(window), window);
        
        Y = fft(window);
        if length(Y) < fft_size
            % Pad results
            Y = [Y zeros(1, fft_size-length(Y))];
        end
        
        % Process fft output
        L = length(Y);
        p2 = abs(Y/L);
        p1 = p2(1:L/2+1);
        p1(2:end-1) = 2*p1(2:end-1);
        
        figure;
        plot(f(1:fft_size), p1);
        
        outputs(end+1, :) = p1;
        
        % Shift window
        start = start + length(Y);
    end
end