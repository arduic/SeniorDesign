library std;
use std.textio.all;

library work;
use work.config.all;

package utils is

file DATA_IN: text open read_mode is INPUT_FILE;
constant FFTLEN_CUTOFF: integer := FFTLEN/2;

type T_MAG_TABLE is array (0 to FFTLEN-1) of integer;
constant mag_table_clear: T_MAG_TABLE := (others => 0);

impure function clear_output_file(dest_file: string) return integer;	

end package;

package body utils is

impure function clear_output_file(dest_file: string) return integer is		
    file data_out: text open write_mode is dest_file;		
begin		
    return 0;		
end function;

end utils;