----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/31/2017 03:07:35 PM
-- Design Name: 
-- Module Name: fft_engine_int_input - Behavioral
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


entity fft_engine_int_input is
    port (
      rst_n     : in  std_logic;
      clk       : in  std_logic;
      din       : in  icpx_number;
      
      --re_in: in unsigned(icpx_width-1 downto 0);
      --im_in: in unsigned(icpx_width-1 downto 0);
      
      valid     : out std_logic;
      saddr     : out unsigned(LOG2_FFT_LEN-2 downto 0);
      saddr_rev : out unsigned(LOG2_FFT_LEN-2 downto 0);
      sout0     : out icpx_number;
      sout1     : out icpx_number
      );
end fft_engine_int_input;

architecture Behavioral of fft_engine_int_input is

  constant base_mag: real := 255.0;
  constant dest_mag: real := 1.5;
  signal icpx_result: icpx_number;
  
  function ints_to_icpx(constant re_in: unsigned(icpx_width-1 downto 0);
                        constant im_in: unsigned(icpx_width-1 downto 0))
                        return icpx_number is
    variable re_real, im_real: real;
    variable vres: icpx_number;
  begin
    re_real := real(to_integer(re_in));
    im_real := real(to_integer(im_in));
    vres := cplx2icpx(complex'(
        (re_real * 2.0 * dest_mag / base_mag) - dest_mag,
        (im_real * 2.0 * dest_mag / base_mag) - dest_mag
    ));
    return vres;
  end function ints_to_icpx;

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

begin

--  icpx_result <= ints_to_icpx(re_in, im_in);

  -- component instantiation
  fft_engine_1 : entity work.fft_engine
    generic map (
      LOG2_FFT_LEN => LOG2_FFT_LEN)
    port map (
      rst_n     => rst_n,
      clk       => clk,
      din       => din,
      
--      din => icpx_result,
      
      saddr     => saddr,
      saddr_rev => saddr_rev,
      sout0     => sout0,
      sout1     => sout1);

end Behavioral;
