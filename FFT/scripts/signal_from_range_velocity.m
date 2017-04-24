clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away
% R = 3000; vr = convvel(100, 'mph', 'm/s');

run('config.m');

min_time = 2*500/c;  % shortest time for the signal to travel to cloud and back

Tm_start = 2*R/c;
Tm_end = 10^-4;
assert(Tm_start < Tm_end);

steps = 100;
step_size = (Tm_end-Tm_start)/steps;
Tms = Tm_start:step_size:Tm_end;
ranges = zeros(1, length(Tms));
vels = zeros(1, length(Tms));

L = 1024;  % FFT length

for j=1:length(Tms)
    Tm = Tms(j);

    fm = 1/Tm;  % modulation rate (period)
    Fs = 1/(Tm/L);  % L points from 0 to Tm

    signal = generate_beat_signal(L, df, c, f0, Tm, R, vr);

    %% FFT windowing
    [r, vel] = range_vel_from_beat(L, df, Tm, f0, c, windows, signal);
    
    ranges(j) = r;
    vels(j) = vel;

end

figure;

subplot(2,2,1);
plot(Tms, ranges);
line = refline(0, R);
line.Color = 'r';
title('Range');
legend('Actual', sprintf('Expected (%d)', R));
xlim([Tm_start Tm_end]);

subplot(2,2,2);
plot(Tms, vels);
line = refline(0, vr);
line.Color = 'r';
title('Velocity');
legend('Actual', sprintf('Expected (%f)', vr));
xlim([Tm_start Tm_end]);

subplot(2,2,3);
plot(Tms, abs((ranges - R)/R*100));
title('Range % error');
xlim([Tm_start Tm_end]);

subplot(2,2,4);
plot(Tms, abs((vels - vr)/vr*100));
title('Vel % error');
xlim([Tm_start Tm_end]);