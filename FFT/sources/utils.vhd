library std;
use std.textio.all;

library work;
use work.config.all;

package utils is

file DATA_IN: text open read_mode is INPUT_FILE;
constant FFTLEN_CUTOFF: integer := FFTLEN/2;

ebd package;