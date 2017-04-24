function [signal]=generate_beat_signal(L, Tm, R, vr)
    run('config.m');

    fR = R*4*fm*df/c;
    fd = vr*2*f0/c;

    assert(fR > fd);

    % Moving toward
    fb_up = fR-fd;
    fb_down = fR+fd;

    % fb_up should be less than fb_down when moving
    % towards radar
    if vr > 0
        assert(fb_up < fb_down);
    elseif vr < 0
        assert(fb_up > fb_down);
    end

    % Create signal
    t = (0:(L-1))/L*Tm;
    delay_ratio = 1/5;
    cutoff = floor(L*(1-delay_ratio));
    t1 = t(1:cutoff);
    t2 = t(cutoff+1:end);
    signal1 = sin(2*pi*fb_up*t1);
    signal2 = sin(2*pi*fb_down*t2);
    signal = [signal1 signal2];
end