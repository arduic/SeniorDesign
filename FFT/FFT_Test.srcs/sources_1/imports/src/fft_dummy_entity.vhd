----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/31/2017 03:58:58 PM
-- Design Name: 
-- Module Name: fft_dummy_entity - Behavioral
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
library work;
use work.fft_len.all;
use work.icpx.all;
use work.fft_support_pkg.all;

entity fft_dummy_entity is
Port (
    rst_n: in std_logic;
    clk: in std_logic;
    valid: out std_logic;
    re_in: in std_logic_vector(icpx_width-1 downto 0);
    im_in: in std_logic_vector(icpx_width-1 downto 0);
    
    icpx_re_vec_out: out std_logic_vector(icpx_width-1 downto 0);
    icpx_im_vec_out: out std_logic_vector(icpx_width-1 downto 0)
);
end fft_dummy_entity;

architecture Behavioral of fft_dummy_entity is

    signal icpx_in, icpx_out: icpx_number := icpx_zero;

component fft_engine
  generic (
    LOG2_FFT_LEN : integer := log2_fft_len);       -- Defines order of FFT
  port (
    -- System interface
    rst_n     : in  std_logic;
    clk       : in  std_logic;
    -- Input memory interface
    din       : in  icpx_number;        -- data input
    valid     : out std_logic;
    saddr     : out unsigned(LOG2_FFT_LEN-2 downto 0);  -- An incrementor counting the number of samples
    saddr_rev : out unsigned(LOG2_FFT_LEN-2 downto 0);  -- The reverse bits of saddr; according to the tb, the integer representation of this is the nth output
    sout0     : out icpx_number;        -- spectrum output
    sout1     : out icpx_number         -- spectrum output (I think this is the end/second half of the output???)
    );

end component;

begin

    icpx_in.Re <= signed(re_in);
    icpx_in.Im <= signed(im_in);
    
    icpx_re_vec_out <= std_logic_vector(icpx_out.Re);
    icpx_im_vec_out <= std_logic_vector(icpx_out.Im);

    U1: fft_engine 
        port map(
            rst_n, 
            clk, 
            icpx_in, 
            valid, 
            open, 
            open, 
            icpx_out, 
            open
        );

end Behavioral;
