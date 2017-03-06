clear;
close all;
clc;

data_out = 'C:\\Users\\lc599.DREXEL\\Desktop\\data_out%d.txt';
data = zeros(0,0,0);

Fs = 1000;

for i=0:5
    filename = sprintf(data_out, i);
    if exist(filename, 'file') == 2
        fprintf('Checking file "%s"\n', filename);
        data(:,:,end+1) = dlmread(filename);
    end
end

L = size(data, 1);
f = Fs/L*(0:(L-1));
f2 = Fs/L*(0:(L/2));

for i=1:size(data, 3)
    output = data(:,:,i);
    output = flipud(output);
    
    mag = sqrt(output(:, 1).^2 + output(:, 2).^2);
    p1 = mag(1:(L/2)+1);
    p1(2:end-1) = 2*p1(2:end-1);
    
    [pks, locs] = findpeaks(mag);
    [pks2, locs2] = findpeaks(p1);
    
    figure;
    plot(f, mag, f(locs), pks, 'o');
%     plot(f2, p1, f2(locs2), pks2, 'o');
    title(sprintf('Magnitude of output for data %d', i));
end