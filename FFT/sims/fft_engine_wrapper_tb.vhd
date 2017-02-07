----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/31/2017 01:34:00 PM
-- Design Name: 
-- Module Name: fft_engine_wrapper_tb - Behavioral
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


entity fft_engine_wrapper_tb is
end fft_engine_wrapper_tb;

architecture Behavioral of fft_engine_wrapper_tb is

  type T_OUT_DATA is array (0 to FFT_LEN-1) of std_logic_vector(2*icpx_width-1 downto 0);
    
  signal re_in, im_in, re_out0, im_out0, re_out1, im_out1: std_logic_vector(icpx_width-1 downto 0) := (others => '0');
  signal saddr, saddr_rev: unsigned(LOG2_FFT_LEN-2 downto 0);
  signal end_of_data, end_sim: boolean := false;
  signal valid: std_logic := '0';
  signal rst_n : std_logic := '0';
  signal Clk : std_logic := '1';

  component fft_dummy_entity is
    port (
        rst_n: in std_logic;  -- Reset (toggle 0 to reset)
        clk: in std_logic;  -- Clock
        
        -- Real/imaginary input
        re_in: in std_logic_vector(icpx_width-1 downto 0);
        im_in: in std_logic_vector(icpx_width-1 downto 0);
        
        valid: out std_logic;  -- Output is valid
        saddr: out unsigned(LOG2_FFT_LEN-2 downto 0);  -- Output counter; starts when valid is high then resets to 0
        saddr_rev: out unsigned(LOG2_FFT_LEN-2 downto 0);  -- Bit reverse order of saddr
        
        -- Output 1
        re_out0: out std_logic_vector(icpx_width-1 downto 0);
        im_out0: out std_logic_vector(icpx_width-1 downto 0);
        
        -- Output 2
        re_out1: out std_logic_vector(icpx_width-1 downto 0);
        im_out1: out std_logic_vector(icpx_width-1 downto 0)
      );
  end component;

begin
  
  fft_engine_1: fft_dummy_entity
    port map (
      rst_n     => rst_n,
      clk       => clk,
      
      re_in => re_in,
      im_in => im_in,
      
      valid     => valid,
      saddr     => saddr,
      saddr_rev => saddr_rev,
      
      re_out0 => re_out0,
      im_out0 => im_out0,
      re_out1 => re_out1,
      im_out1 => im_out1
      );
      
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
      -- Get real and imaginary parts
      -- Read in as unsigned integers
      if not endfile(data_in) then
        readline(data_in, input_line);
        read(input_line, tre);
        read(input_line, tim);
      else
        end_of_data <= true;
      end if;
      
      re_in <= std_logic_vector(to_unsigned(tre, icpx_width));
      im_in <= std_logic_vector(to_unsigned(tim, icpx_width));
      
      -- Store in buffer
      vout(to_integer(saddr_rev))       := (re_out0 & im_out0);
      vout(to_integer('1' & saddr_rev)) := (re_out1 & im_out1);
      
      -- If the full set of data is calculated
      -- write signed integers to the output
      if saddr = FFT_LEN/2-1 then
        for i in 0 to FFT_LEN-1 loop
          write(output_line, integer'image(to_integer(signed(vout(i)(2*icpx_width-1 downto icpx_width)))));
          write(output_line, sep);
          write(output_line, integer'image(to_integer(signed(vout(i)(icpx_width-1 downto 0)))));
          writeline(data_out, output_line);
        end loop;
        exit l1 when end_of_data;
      end if;
      
      wait until clk = '0';
      wait until clk = '1';
    end loop l1;
    end_sim <= true;
    
  end process WaveGen_Proc;

end Behavioral;
