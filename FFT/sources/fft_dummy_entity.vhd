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
    rst_n: in std_logic;  -- Reset (toggle 0 to reset)
    clk: in std_logic;  -- Clock
    
    -- Real/imaginary input
    re_in: in std_logic_vector(icpx_width-1 downto 0);
    im_in: in std_logic_vector(icpx_width-1 downto 0);
    
    valid: out std_logic;  -- Output is valid
    saddr: out unsigned(LOG2_FFT_LEN-2 downto 0);  -- Output counter; starts when valid is high then resets to 0
    saddr_rev: out unsigned(LOG2_FFT_LEN-2 downto 0);  -- Bit reverse order of saddr
    
    -- Output 1
    icpx_re_vec_out: out std_logic_vector(icpx_width-1 downto 0);
    icpx_im_vec_out: out std_logic_vector(icpx_width-1 downto 0);
    
    -- Output 2
    icpx_re_vec_out2: out std_logic_vector(icpx_width-1 downto 0);
    icpx_im_vec_out2: out std_logic_vector(icpx_width-1 downto 0);

    sout0: out icpx_number;
    sout1: out icpx_number
);
end fft_dummy_entity;

architecture Behavioral of fft_dummy_entity is

    type T_OUT_DATA is array (0 to FFT_LEN-1) of icpx_number;

    signal re_out, im_out, re_out2, im_out2: std_logic_vector(icpx_width-1 downto 0) := (others => '0');
    signal din, icpx_out, icpx_out2: icpx_number := (re => (others => '0'), im => (others => '0'));
--    signal din, icpx_out, icpx_out2: icpx_number := icpx_zero;
    signal combined: std_logic_vector(2*icpx_width-1 downto 0) := (others => '0');

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

    U1: fft_engine 
        port map(
            rst_n => rst_n, 
            clk => clk, 
            din => din, 
            valid => valid,
            saddr => saddr, 
            saddr_rev => saddr_rev, 
            sout0 => icpx_out, 
            sout1 => icpx_out2
        );

    combined(2*icpx_width-1 downto icpx_width) <= re_in;
    combined(icpx_width-1 downto 0) <= im_in;
    din <= stlv2icpx(combined);
    
    sout0 <= icpx_out;
    sout1 <= icpx_out2;

    
    icpx_re_vec_out <= std_logic_vector(to_signed(to_integer(icpx_out.Re), icpx_width));
    icpx_im_vec_out <= std_logic_vector(to_signed(to_integer(icpx_out.Im), icpx_width));
    
    icpx_re_vec_out2 <= std_logic_vector(to_signed(to_integer(icpx_out2.Re), icpx_width));
    icpx_im_vec_out2 <= std_logic_vector(to_signed(to_integer(icpx_out2.Im), icpx_width));
    
    
--    re_out <= std_logic_vector(to_signed(to_integer(icpx_out.Re), icpx_width));
--    im_out <= std_logic_vector(to_signed(to_integer(icpx_out.Im), icpx_width));
    
--    re_out2 <= std_logic_vector(to_signed(to_integer(icpx_out2.Re), icpx_width));
--    im_out2 <= std_logic_vector(to_signed(to_integer(icpx_out2.Im), icpx_width));
    
--    icpx_re_vec_out <= re_out;
--    icpx_im_vec_out <= im_out;
    
--    icpx_re_vec_out2 <= re_out2;
--    icpx_im_vec_out2 <= im_out2;

end Behavioral;
