fo = fopen(fft_config_path,'w');
fprintf(fo,'package config is\n');
fprintf(fo,'constant INPUT_FILE: string := "%s";\n', input_data_path);
fprintf(fo,'constant OUTPUT_FILE: string := "%s";\n', output_data_path);
fprintf(fo,'constant FS: integer := %d;\n', Fs);
fprintf(fo,'constant FFTLEN: integer := %d;\n', fftlen);
fprintf(fo,'constant FFTLEN_CUTOFF: integer := FFTLEN/2;\n');
fprintf(fo,'constant WINDOWS: integer := %d;\n', windows);
fprintf(fo,'constant c: integer := 3*(10**8);\n');
fprintf(fo,'constant df: integer := 10**6;\n');
fprintf(fo,'constant fm: integer := 10**3;\n');
% fprintf(fo,'constant f0: integer := 80*(10**9);\n');

% Types
fprintf(fo,'type FREQ_SPEC_T is array(0 to FFTLEN-1) of integer;\n');
fprintf(fo,'type FREQ_BUFF_T is array(0 to WINDOWS-1) of integer;\n');

fprintf(fo,'constant FREQ_SPEC: FREQ_SPEC_T := %s;\n', vhdl_int_arr(ceil(Fs/fftlen*(0:(fftlen-1)))));

fprintf(fo,'end config;\n');
fclose(fo);