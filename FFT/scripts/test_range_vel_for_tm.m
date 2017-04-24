clear;
close all;
clc;

ranges = 500:3000;

vel_steps = 100;
vel_start = 0;
vel_end = convvel(100, 'mph', 'm/s');
vel_step_size = (vel_end-vel_start)/vel_steps;
vels = vel_start:vel_step_size:vel_end;

run('config.m');

ranges_actual = zeros(1, length(ranges));
vels_actual = zeros(1, length(ranges));
% vr = 0;
vr = convvel(100, 'mph', 'm/s');
L = 1024;
for i=1:length(ranges)
    R = ranges(i);
    signal = generate_beat_signal(L, df, c, f0, Tm, R, vr);
    [r_actual, vel_actual] = range_vel_from_beat(L, df, Tm, f0, c, windows, signal);
    
    ranges_actual(i) = r_actual;
    vels_actual(i) = vel_actual;
end

figure;

subplot(2,2,1);
plot(ranges, ranges_actual, ranges, ranges);
title('Range');
legend('Actual', 'Expected');

subplot(2,2,2);
plot(ranges, vels_actual);
line = refline(0, vr);
line.Color = 'r';
title('Velocity');
legend('Actual', sprintf('Expected (%f)', vr));
xlim([ranges(1) ranges(end)]);

subplot(2,2,3);
plot(ranges, abs((ranges_actual - ranges)./ranges*100));
title('Range % error');

subplot(2,2,4);
plot(ranges, abs((vels_actual - vr)/vr*100));
title('Vel % error');