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


%% FFT Settings
% Modify the length of the FFT in the line below
log2fftlen = 10;
fftlen = 2^log2fftlen;  % Transform length/point size

% Increase this to support signals with larger amplitudes
% When changing though, be sure to restart the whole simulation
% Since this value is written to and hardcoded in a vhdl
% script that already exists at runtime.
ip_width = 8;

% Sampling frequency
Fs = 1000;  % Hz
windows = 2;
