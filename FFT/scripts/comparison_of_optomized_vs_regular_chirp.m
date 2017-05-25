clear;
close all;
clc;

load('ranges_actual_optomized.mat');
optomized_ranges = ranges_actual;

load('ranges_actual_regular.mat');
regular_ranges = ranges_actual;

vr = convvel(100, 'mph', 'm/s');

ranges = 3000:-1:500;
vels = repmat(vr, 1, length(ranges));

t_end = abs((ranges(end)-ranges(1))/vr);
t = linspace(0, t_end, length(ranges));
dt = mean(t(2:end)-t(1:end-1));

figure;
plot(t, ranges, t, regular_ranges, t, optomized_ranges);
legend('Expected', '1 MHz/us', '199 kHz/us');
xlabel('Travel Time (s)');
ylabel('Range (m)');
title(sprintf('Hurrican Distance @ %.2f m/s', vr));

figure;
plot(t, ranges, t, regular_ranges);
legend('Expected', 'Measured');
xlabel('Travel Time (s)');
ylabel('Range (m)');
title(sprintf('Hurrican Distance @ %.2f m/s', vr));

figure;
plot(ranges, abs(regular_ranges - ranges) ./ ranges * 100);
xlabel('Range (m)');
ylabel('% Error');
title('Hurrican Distance % Error');

figure;
plot(ranges, abs(optomized_ranges - ranges) ./ ranges * 100);
xlabel('Range (m)');
ylabel('% Error');
title('Hurrican Distance % Error with Optimized Chirp');