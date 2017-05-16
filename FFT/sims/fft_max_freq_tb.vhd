library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;
library std;
use std.textio.all;
library work;
use work.fft_len.all;
use work.icpx.all;
use work.fft_support_pkg.all;

entity fft_max_freq_tb is
end fft_max_freq_tb;

architecture Behavioral of fft_max_freq_tb is

    signal clk: std_logic := '1';
    signal rst_n: std_logic := '0';
    signal saddr: unsigned(LOG2_FFT_LEN-2 downto 0);
    signal re_in, im_in, re_out, im_out: std_logic_vector(icpx_width-1 downto 0);
    signal idx: unsigned(log2_fft_len-1 downto 0);
    signal valid: std_logic := '0';
    signal end_of_data, end_sim: boolean := false;

    component fft_max_freq is
        generic(
            buffer_size: integer := fft_len
        );
        port(
            rst_n: in std_logic;  -- Reset (toggle 0 to reset)
            clk: in std_logic;  -- Clock
            
            -- Real/imaginary input
            re_in: in std_logic_vector(icpx_width-1 downto 0);
            im_in: in std_logic_vector(icpx_width-1 downto 0);
            
            -- Ouput stream of indeces of highest frequencies
            re_out: out std_logic_vector(icpx_width-1 downto 0);
            im_out: out std_logic_vector(icpx_width-1 downto 0);
            idx: out unsigned(LOG2_FFT_LEN-1 downto 0);
            valid: out std_logic;  -- Output is valid
            
            saddr: out unsigned(log2_fft_len-2 downto 0)
        );
    end component;

begin


  fft_max_freq_1: fft_max_freq
    port map (
        rst_n => rst_n,
        clk => clk,
        re_in => re_in,
        im_in => im_in,
        re_out => re_out,
        im_out => im_out,
        idx => idx,
        valid => valid,
        saddr => saddr
    );
    
    Clk <= not Clk after 10 ns when end_sim = false else '0';
    
    process
        file data_in: text open read_mode is input_file;
        variable input_line: line;
        variable tre, tim: integer;
        constant sep: string := " ";
    begin
        wait until clk = '1';
        wait for 15 ns;
        wait until clk = '0';
        wait until clk = '1';
        rst_n <= '1';
        
        l1:
        while not end_sim loop
            if not endfile(data_in) then
                readline(data_in, input_line);
                read(input_line, tre);
                read(input_line, tim);
            else
                end_of_data <= true;
            end if;
            
            re_in <= std_logic_vector(to_unsigned(tre, icpx_width)); 
            im_in <= std_logic_vector(to_unsigned(tim, icpx_width));
            
            if valid = '1' then
                exit l1 when end_of_data;
            end if;
        end loop l1;
        end_sim  <= true;
    end process;

end Behavioral;
