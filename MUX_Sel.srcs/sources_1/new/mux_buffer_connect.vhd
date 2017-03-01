----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2017 09:16:28 PM
-- Design Name: 
-- Module Name: mux_buffer_connect - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux_buffer_connect is
  Port (
    buffer_reset : in std_logic;
    
   );
end mux_buffer_connect;

architecture Behavioral of mux_buffer_connect is

    component mux_sel is
    Generic (
        array_width : integer := 8;     --Width/Height of the array (after any hardware meshing of data) in base 2
        array_height : integer := 8;    
        mux_size : integer := 3         --binary size of mux used
    );
    Port ( 
        requested_width : in std_logic_vector(array_width-1 downto 0);  --0 indexed, How to create this vector for calling assuming you start with an integer. std_logic_vector(unsigned(integerVal,arrayWidth)) YOU MUST PAD THE 0'S AS THIS DOES. Always do max size
        requested_height : in std_logic_vector(array_height-1 downto 0);
        selection: out std_logic_vector(array_width+array_height-1 downto 0)
    );
    end component mux_sel;
    
    component fifo_generator_0 is
      PORT (
          rst : IN STD_LOGIC;
          wr_clk : IN STD_LOGIC;
          rd_clk : IN STD_LOGIC;
          din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
          wr_en : IN STD_LOGIC;
          rd_en : IN STD_LOGIC;
          dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
          full : OUT STD_LOGIC;
          empty : OUT STD_LOGIC
        );
    end component fifo_generator_0;
    
    --Also a clk_wiz

begin


end Behavioral;
