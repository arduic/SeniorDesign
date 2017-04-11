fo = fopen(fft_config_path,'w');
fprintf(fo,'package config is\n');
fprintf(fo,'constant INPUT_FILE: string := "%s";\n', input_data_path);
fprintf(fo,'constant OUTPUT_FILE: string := "%s";\n', output_data_path);
fprintf(fo,'constant FS: integer := %d;\n', Fs);
fprintf(fo,'constant FFTLEN: integer := %d;\n', fftlen);

% Types
fprintf(fo,'type FREQ_SPEC_T is array(FFTLEN-1 downto 0) of integer;\n');
fprintf(fo,'constant FREQ_SPEC: FREQ_SPEC_T := %s;\n', vhdl_int_arr(ceil(Fs/fftlen*(0:(fftlen-1)))));

fprintf(fo,'end config;\n');
fclose(fo);