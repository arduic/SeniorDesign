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
% ABSOLUTE path to fft_len.vhd in the vivado project
fft_config_path = 'C:\Users\lc599\FFT_impl\FFT_impl.srcs\sources_1\imports\sources\fft_len.vhd';


%% FFT Settings
% Modify the length of the FFT in the line below
log2fftlen = 10;
fftlen = 2^log2fftlen;  % Transform length/point size

% Increase this to support signals with larger amplitudes
% When changing though, be sure to restart the whole simulation
% Since this value is written to and hardcoded in a vhdl
% script that already exists at runtime.
icpx_width = 32;


%% Signal settings
Fs=100*10^9;  % Sample rate
T = 1/Fs;  % Sample period
