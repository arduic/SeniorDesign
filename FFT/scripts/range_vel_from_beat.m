function [R, vel]=range_vel_from_beat(L, df, Tm, f0, c, windows, signal)
    fm = 1/Tm;
    Fs = 1/(Tm/L);
    fft_size = L/windows;
    fft_results = fft_window2(signal, fft_size);
    dominant_freqs = zeros(1, windows);
    f2 = (0:(fft_size/2)-1)*Fs/fft_size;
    for i=1:size(fft_results, 1)
        % Keep only first half of data where f < fs/2
        data = fft_results(i, 1:(fft_size/2));
        mag = abs(data);

        [~,I] = max(mag);
        max_freq = f2(I);
        dominant_freqs(i) = max_freq;
    end

    fb_up_actual = dominant_freqs(1);
    fb_down_actual = dominant_freqs(end);
    fr_actual = (fb_up_actual + fb_down_actual)/2;
    fd_actual = (fb_down_actual - fb_up_actual)/2;
    k1 = c/(4*fm*df);
    k2 = c/(2*f0);
    R = k1*fr_actual;
    vel = k2*fd_actual;
end