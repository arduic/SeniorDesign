----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2017 04:17:56 PM
-- Design Name: 
-- Module Name: mux_sel - Behavioral
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


--1   CHANNEL I/O A4    --Input selection options
--2   CHANNEL I/O A6
--3   COM OUT/IN A      --Output from options
--4   CHANNEL I/O A7
--5   CHANNEL I/O A5
--6   E
--7   VEE
--8   GND
--16   VCC
--15  CHANNEL I/O A2
--14  CHANNEL I/O A1
--13  CHANNEL I/O A0
--12  CHANNEL I/O A3
--11  ADDRESS SEL S0    --Input selection Thing
--10  ADDRESS SEL S1
--9   ADDRESS SEL S2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--WARNING: The width and height must be powers of 2. If you don't need it just round up. Also Note the comment on requested_width it describes how to pass this data.
entity mux_sel is
    Generic (
        array_width : integer := 8;     --Width/Height of the array (after any hardware meshing of data) in base 2
        array_height : integer := 8;    
        mux_size : integer := 3         --binary size of mux used
    );
    Port ( 
        requested_width : in std_logic_vector(array_width-1 downto 0);  --0 indexed, How to create this vector for calling assuming you start with an integer. std_logic_vector(unsigned(integerVal,arrayWidth)) YOU MUST PAD THE 0'S AS THIS DOES. Always do max size
        requested_height : in std_logic_vector(array_height-1 downto 0);
        selection : out std_logic_vector(array_width+array_height-1 downto 0)
    );
end mux_sel;

architecture Behavioral of mux_sel is
   signal tmp_sel : std_logic_vector(array_width+array_height-1 downto 0);
begin
    tmp_sel <= requested_height & requested_width;
    
    selection <= tmp_sel;

end Behavioral;