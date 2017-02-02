----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/31/2017 01:34:00 PM
-- Design Name: 
-- Module Name: fft_tb_int_to_real - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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


entity fft_tb_int_to_real is
end fft_tb_int_to_real;

architecture Behavioral of fft_tb_int_to_real is

  type T_OUT_DATA is array (0 to FFT_LEN-1) of icpx_number;

  signal din, sout0, sout1    : icpx_number;
  signal saddr, saddr_rev     : unsigned(LOG2_FFT_LEN-2 downto 0);
  signal end_of_data, end_sim : boolean := false;
  signal icpx_width: integer := icpx_width;
  signal valid: std_logic := '0';

  component fft_engine is
    generic (
      LOG2_FFT_LEN : integer);
    port (
      rst_n     : in  std_logic;
      clk       : in  std_logic;
      din       : in  icpx_number;
      valid     : out std_logic;
      saddr     : out unsigned(LOG2_FFT_LEN-2 downto 0);
      saddr_rev : out unsigned(LOG2_FFT_LEN-2 downto 0);
      sout0     : out icpx_number;
      sout1     : out icpx_number
      );
  end component fft_engine;

  -- component ports
  signal rst_n : std_logic := '0';

  -- clock
  signal Clk : std_logic := '1';
  
  signal combined: std_logic_vector(2*icpx_width-1 downto 0) := (others => '0');

begin

  -- component instantiation
  fft_engine_1 : entity work.fft_engine
    generic map (
      LOG2_FFT_LEN => LOG2_FFT_LEN)
    port map (
      rst_n     => rst_n,
      clk       => clk,
      din       => din,
      valid => valid,
      saddr     => saddr,
      saddr_rev => saddr_rev,
      sout0     => sout0,
      sout1     => sout1);
      
  -- clock generation
  Clk <= not Clk after 10 ns when end_sim = false else '0';

 --waveform generation
  WaveGen_Proc : process
    file data_in         : text open read_mode is input_file;
    variable input_line  : line;
    file data_out        : text open write_mode is output_file;
    variable output_line : line;
    variable tre, tim    : integer;
    constant sep         : string := " ";
    variable vout        : T_OUT_DATA;
    
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for 15 ns;
    wait until clk = '0';
    wait until clk = '1';
    rst_n <= '1';
    
    l1 : 
    while not end_sim loop
      --  Get real and imaginary parts
      if not endfile(data_in) then
        readline(data_in, input_line);
        read(input_line, tre);
        read(input_line, tim);
      else
        end_of_data <= true;
      end if;
      
      -- Latency of 1 clk cycle
      combined(2*icpx_width-1 downto icpx_width) <= std_logic_vector(to_unsigned(tre, icpx_width));
      combined(icpx_width-1 downto 0) <= std_logic_vector(to_unsigned(tim, icpx_width));
      din <= stlv2icpx(combined);
      
          -- Copy the data produced by the core to the output buffer
      vout(to_integer(saddr_rev))       := sout0;
      vout(to_integer('1' & saddr_rev)) := sout1;
      
      -- If the full set of data is calculated, write the output buffer
      if saddr = FFT_LEN/2-1 then
        writeline(data_out, output_line);
        for i in 0 to FFT_LEN-1 loop
          write(output_line, integer'image(to_integer(vout(i).re)));
          write(output_line, sep);
          write(output_line, integer'image(to_integer(vout(i).im)));
          writeline(data_out, output_line);
        end loop;  -- i
        writeline(data_out, output_line);
        exit l1 when end_of_data;
      end if;
      
      wait until clk = '0';
      wait until clk = '1';
    end loop l1;
    end_sim <= true;
    
  end process WaveGen_Proc;

end Behavioral;
