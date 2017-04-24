% Configurations/settings


%% Data Files
% File to hold sample signal input
input_data_file = 'data_in.txt';

% File to store the fft output
output_data_file = 'data_out.txt';

% CHANGE THIS WHEN STARTING A NEW PROJECT
% Directory containing intermediate data files
% This must be an ABSOLUTE path
data_dir = pwd();

% Absolute paths of the data files
input_data_path = fullfile(data_dir, input_data_file);
output_data_path = fullfile(data_dir, output_data_file);

% CHANGE THIS WHEN STARTING A NEW PROJECT
% ABSOLUTE path to config.vhd in the vivado project
project_name = 'FFT_ip_test';
fft_config_path = [getenv('HOMEDRIVE') getenv('HOMEPATH') '\' project_name '\' ...
    project_name '.srcs\sources_1\imports\sources\config.vhd'];

beat_signal_file = 'tb_generated_beat.mat';


%% FFT Settings
Tm = 10^-4;
c = 3*10^8;  % speed of light
df = 10^6;  % beat (delata freq)
fm = 1/Tm;  % modulation rate (period)
f0 = 80*10^9;  % Starting freqency

kr = floor(1/(c/(4*fm*df)));  % r = fr/k1
kd = floor(1/(c/(2*f0)));  % vel = fd/k2
assert(kr > 0);
assert(kd > 0);

% Modify the length of the FFT in the line below
log2fftlen = 8;
fftlen = 2^log2fftlen;  % Transform length/point size

% Increase this to support signals with larger amplitudes
% When changing though, be sure to restart the whole simulation
% Since this value is written to and hardcoded in a vhdl
% script that already exists at runtime.
ip_width = 8;

% Sampling frequency
% Fs = 1000;  % Hz
windows = 4;
Fs = 1/(Tm/(fftlen*windows));  % L points from 0 to Tm
