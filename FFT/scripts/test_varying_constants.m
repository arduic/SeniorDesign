clear;
close all;
clc;

% R = 3000; vr = 0;  % far, stationary
% R = 500; vr = convvel(100, 'mph', 'm/s');  % close, fast towards
% R = 500; vr = convvel(-100, 'mph', 'm/s');  % close, fast away
R = 3000; vr = convvel(100, 'mph', 'm/s');
% R = 3000; vr = 5.6793;  % avg hurrican fwd speed in m/s

run('config.m');

steps = 1000;

TM = 1;
DF = 2;
F0 = 3;
TL = 4;
var = F0;

if var == TM
    x_start = 2*R/c;
    x_end = 10^-3;
    constant = 'Modulation Period';
elseif var == DF
    x_start = 10^5;
    x_end = 2*10^7;
    constant = 'Delta Freq';
elseif var == F0
    x_start = 10^3;
    x_end = 10^12;
    constant = 'f0';
elseif var == TL
    % Try to keep each step a multiple of 4 to avoid rounding problems
    steps = 16;
    x_start = 256;
    x_end = steps*x_start;
    constant = 'Transform Length';
end

ranges = zeros(1, steps);
vels = zeros(1, steps);

assert(x_start < x_end);
x_range = linspace(x_start, x_end, steps);

L = 1024;  % FFT length

for j=1:steps
    if var == TM
        Tm = x_range(j);
    elseif var == DF
        df = x_range(j);
    elseif var == F0
        f0 = x_range(j);
    elseif var == TL
        L = x_range(j);
    end

    fm = 1/Tm;  % modulation rate (period)
    Fs = 1/(Tm/L);  % L points from 0 to Tm

    signal = generate_beat_signal(L, df, c, f0, Tm, R, vr);
    
    %% FFT windowing
    [r, vel] = range_vel_from_beat(L, df, Tm, f0, c, windows, signal);
    
    ranges(j) = r;
    vels(j) = vel;

end

figure;

if var == DF
    x_range = x_range / 10^6;
elseif var == TM
    x_range = x_range * 10^6;
end

subplot(2,2,1);
plot(x_range, ranges);
line = refline(0, R);
line.Color = 'r';
title(sprintf('Range vs %s', constant));
legend('Actual', sprintf('Expected (%d)', R));
ylabel('Range (m)');
if var == DF
    xlabel('Frequency (MHz)');
elseif var == TM
    xlabel('Period (us)');
end

subplot(2,2,2);
plot(x_range, vels);
line = refline(0, vr);
line.Color = 'r';
title(sprintf('Velocity vs %s', constant));
legend('Actual', sprintf('Expected (%f)', vr));
ylabel('Velocity (m/s)');
if var == DF
    xlabel('Frequency (MHz)');
elseif var == TM
    xlabel('Period (us)');
end

subplot(2,2,3);
plot(x_range, abs((ranges - R)/R*100));
title('Range % error');
ylabel('Range (m)');
if var == DF
    xlabel('Frequency (MHz)');
elseif var == TM
    xlabel('Period (us)');
end

subplot(2,2,4);
plot(x_range, abs((vels - vr)/vr*100));
title('Vel % error');
ylabel('Velocity (m/s)');
if var == DF
    xlabel('Frequency (MHz)');
elseif var == TM
    xlabel('Period (us)');
end