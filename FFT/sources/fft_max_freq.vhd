----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2017 01:54:55 PM
-- Design Name: 
-- Module Name: fft_out_buffer - Behavioral
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


entity fft_max_freq is
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
end fft_max_freq;

architecture Behavioral of fft_max_freq is

  type T_OUT_DATA is array (0 to FFT_LEN-1) of std_logic_vector(2*icpx_width-1 downto 0);
  signal vout: T_OUT_DATA;

  signal re_out0, im_out0, re_out1, im_out1: std_logic_vector(icpx_width-1 downto 0) := (others => '0');
  signal saddr_tmp, saddr_rev: unsigned(LOG2_FFT_LEN-2 downto 0);
  signal valid_tmp: std_logic := '0';

  component fft_engine_wrapper is
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

  valid <= valid_tmp;
  saddr <= saddr_tmp;

  fft_engine_1: fft_engine_wrapper
    port map (
      rst_n     => rst_n,
      clk       => clk,
      
      re_in => re_in,
      im_in => im_in,
      
      valid     => open,
      saddr     => saddr_tmp,
      saddr_rev => saddr_rev,
      
      re_out0 => re_out0,
      im_out0 => im_out0,
      re_out1 => re_out1,
      im_out1 => im_out1
      );
      
  vout(to_integer(saddr_rev)) <= (re_out0 & im_out0);
  vout(to_integer('1' & saddr_rev)) <= (re_out1 & im_out1);
      
  process(clk, saddr_tmp)
    variable max_freq: integer;
    variable max_freq_idx: integer;
    variable freq_int_re, freq_int_im, mag, i: integer;
  begin
    if saddr_tmp = fft_len/2-1 then
        -- Find max
        i := 0;
        max_freq := 0;
        max_freq_idx := 0;
--        for i in 0 to fft_len-1 loop
        while i < fft_len loop
            freq_int_re := to_integer(signed(vout(i)(2*icpx_width-1 downto icpx_width)));
            freq_int_im := to_integer(signed(vout(i)(icpx_width-1 downto 0)));
            
            -- 2 clk cycles
            mag := freq_int_re**2 + freq_int_im**2;
            if mag > max_freq then
                max_freq := mag;
--                max_freq_idx := i;  -- I think this line causes it to take forever to synthesize
            end if;
            i := i + 1;
        end loop;
        valid_tmp <= '1';
        re_out <= vout(max_freq_idx)(2*icpx_width-1 downto icpx_width);
        im_out <= vout(max_freq_idx)(icpx_width-1 downto 0);
        idx <= to_unsigned(max_freq_idx, log2_fft_len);
    else
        valid_tmp <= '0';
    end if;
  end process;

end Behavioral;
