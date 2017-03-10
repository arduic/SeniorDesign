fo = fopen(fft_config_path,'w');
fprintf(fo,'package config is\n');
fprintf(fo,'constant INPUT_FILE: string := "%s";\n', input_data_path);
fprintf(fo,'constant OUTPUT_FILE: string := "%s";\n', output_data_path);
fprintf(fo,'end config;\n');
fclose(fo);