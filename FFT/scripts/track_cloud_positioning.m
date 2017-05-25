clear;
close all;
clc;

run('config.m');

% vr = 5.6793;  % avg fwd speed of hurricane
vr = convvel(100, 'mph', 'm/s');

ranges = 3000:-1:500;
vels = repmat(vr, 1, length(ranges));

t_end = abs((ranges(end)-ranges(1))/vr);
t = linspace(0, t_end, length(ranges));
dt = mean(t(2:end)-t(1:end-1));

ranges_actual = zeros(1, length(ranges));

% SMA
windowSize = 5;
ranges_sma = zeros(1, length(ranges));
sma_sum = 0;
ranges_max = zeros(1, floor(length(ranges)/windowSize));
t_max = linspace(t(1), t(end), length(ranges_max));
dt_max = mean(t_max(2:end)-t_max(1:end-1));

vels_actual = zeros(1, length(ranges));
vels_max = zeros(1, length(ranges_max));
vels_sma = zeros(1, length(ranges));

for i=1:length(ranges)
    R = ranges(i);
    signal = generate_beat_signal(L, df, c, f0, Tm, R, vr);
    [r_actual, ~] = range_vel_from_beat(L, df, Tm, f0, c, windows, signal);
    
    ranges_actual(i) = r_actual;
    
    % SMA
    sma_sum = sma_sum + ranges_actual(i);
    if i > windowSize
        sma_sum = sma_sum - ranges_actual(i-windowSize);
    end
    ranges_sma(i) = sma_sum / windowSize;
    
    if ~mod(i, windowSize)
        ranges_max(i/windowSize) = max(ranges_actual((i-windowSize)+1:i));
        if i/windowSize >= 2
            vels_max(i/windowSize) = (ranges_max(i/windowSize) - ranges_max(i/windowSize - 1))/dt_max;
        end
    end
    
    % Velocity
    if i > 1
        vels_actual(i) = (ranges_actual(i)-ranges_actual(i-1))/dt;
    end
    if i > windowSize
        vels_sma(i) = (ranges_sma(i)-ranges_sma(i-1))/dt;
    end
end

% Peaks
[ranges_hi, ranges_lo] = envelope(ranges_actual, 1000, 'peak');
ranges_avg = (ranges_hi + ranges_lo) / 2;
vels_avg = -(ranges_avg(2:end)-ranges_avg(1:end-1))/dt;  % Multiple by -1 b/c moving towards the radar represents positive velocity


% %Error
ranges_err = abs(ranges_actual - ranges)./ranges*100;
vels_err = abs(vels_actual - vels)./vels*100;
ranges_sma_err = abs(ranges_sma - ranges)./ranges*100;
ranges_hi_err = abs(ranges_hi - ranges)./ranges*100;
ranges_lo_err = abs(ranges_lo - ranges)./ranges*100;
ranges_avg_err = abs(ranges_avg - ranges)./ranges*100;
ranges_max_err = abs(ranges_max - ranges(1:windowSize:end-1))./ranges(1:windowSize:end-1)*100;

vel_avg_err = abs(vels_avg - vels(2:end))./vels(2:end)*100;

figure;
% plot(t, ranges, t, ranges_actual, t(windowSize:end), ranges_sma(windowSize:end),...
%      t, ranges_hi, t, ranges_lo, t, ranges_avg);
plot(t, ranges, t, ranges_actual);
title(sprintf('Hurrican distance @ %.2f m/s', vr));
% legend('Expected', 'Measured', 'SMA', 'High', 'Low', 'Avg');
legend('Expected', 'Measured');
xlabel('Time (s)');
ylabel('Range (m)');

figure;
[pks, locs] = findpeaks(ranges_err, 'MinPeakDistance', 5/dt);
locs_t = t(locs);
% plot(t, ranges_err, t(windowSize:end), ranges_sma_err(windowSize:end),...
%      t, ranges_hi_err, t, ranges_lo_err, t, ranges_avg_err,...
%      locs_t, pks, 'o',...
%      t_max, ranges_max_err);
% legend('Measured', 'SMA', 'High', 'Low', 'Avg', 'Peaks', 'Max Period');
% plot(t, ranges_err,...
%      t, ranges_hi_err, t, ranges_lo_err, t, ranges_avg_err,...
%      locs_t, pks, 'o');
% legend('Measured', 'High', 'Low', 'Avg', 'Peaks');
plot(ranges, ranges_err);
hold on;
plot(ranges, ranges_avg_err', 'LineWidth', 2);
legend('Measured', 'Envelope Average');
title('Hurrican distance % Error');
% xlabel('Time (s)');
xlabel('Range (m)');
ylabel('% Error');


figure;
% plot(t, vels, t, vels_actual, t(windowSize:end), vels_sma(windowSize:end));
% legend('Expected', 'Measured', 'SMA');
plot(t, vels, t, vels_actual);
legend('Expected', 'Measured');
title('Hurrican velocity');
xlabel('Travel Time (s)');
ylabel('Velocity (m/s)');

figure;
plot(t, vels_err);
title('Hurrican velocity % Error');
xlabel('Travel Time (s)');
ylabel('% Error');

figure;

plot(t(2:end), vel_avg_err);
legend('Measured', 'Avg');
title('Hurrican velocity % Error Zoomed in');
