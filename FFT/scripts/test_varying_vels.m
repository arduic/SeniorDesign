clear;
close all;
clc;

run('config.m');

R = 3000;

steps = 1000;
vel_start = 0;
vel_end = convvel(100, 'mph', 'm/s');
vels = linspace(vel_start, vel_end, steps);

ranges_actual = zeros(1, length(vels));
vels_actual = zeros(1, length(vels));

for i=1:length(vels)
    vr = vels(i);
    signal = generate_beat_signal(L, df, c, f0, Tm, R, vr);
    [r_actual, vel_actual] = range_vel_from_beat(L, df, Tm, f0, c, windows, signal);
    
    ranges_actual(i) = r_actual;
    vels_actual(i) = vel_actual;
end

figure;

subplot(2,2,1);
plot(vels, ranges_actual);
line = refline(0, R);
line.Color = 'r';
title('Range');
legend('Actual', sprintf('Expected (%f)', R));
xlim([vels(1) vels(end)]);

subplot(2,2,2);
plot(vels, vels_actual, vels, vels);
title('Range');
legend('Actual', 'Expected');

subplot(2,2,3);
plot(vels, abs((ranges_actual - R)./R*100));
title('Range % error');

subplot(2,2,4);
plot(vels, abs((vels_actual - vels)./vels*100));
title('Vel % error');