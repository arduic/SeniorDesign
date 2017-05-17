----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2017 03:22:04 PM
-- Design Name: 
-- Module Name: DAC_Counter_Support - Behavioral
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
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DAC_Counter_Support is
    generic(
    clk_division : integer := 2;    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
    max_count : integer := 256
);
Port ( 
    in_clk : in std_logic;
    out_count_clk : out std_logic;         --(CLK)
    --reset : out std_logic := '0';          --(MR)
    count_to : in integer range 0 to 255 :=255;       --Number that the counter should go to. based on LUT
    position_set : out std_logic := '0';
    update : in std_logic      --Tells the counter when to count again
    --halt_count : out std_logic      --(CE)
);
end DAC_Counter_Support;

architecture Behavioral of DAC_Counter_Support is
    --clk division variables
signal tmp_clk_val : std_logic := '0';
signal counter_clock_divide : integer range 0 to clk_division-1 :=0; --for clock divison
signal current_val : integer range 0 to max_count-1 :=0; --for incrementation of the counter

--pulse enabling variables
signal enable_clk_divider : std_logic := '0';
signal count_flag : std_logic := '0';

--Used for reset signal
signal reset_buffer : std_logic;

begin

--Note to self. This check for only rising edge causes a 2x clock division. need to check for both rise and fall.

--clk division process
clk_divide: process(in_clk) begin
    --So because VHDL is a STUPID language. You can not check for both rising and falling edges. Or just events. You must specifically look for only one of them.
    --As such the clock is already divided here and I can not change this fact.
    if rising_edge(in_clk) then
        --Check if we have counted to the division number.
        if (counter_clock_divide >= clk_division-2) then --To account for the above mentioned division issue I must reduce this by 2. Once for starting at 0 and once for the if rising
            --tmp_clk_val <= (not(tmp_clk_val) and enable_clk_divider and not(reset_buffer));    --A single clock pulse          --Instead I could have the enable work by taking a bitwise && with the enable and the clock
            tmp_clk_val <= (not(tmp_clk_val) and enable_clk_divider);
            --tmp_clk_val <= not(tmp_clk_val);
            counter_clock_divide <= 0;
            --reset_buffer <= '0';
        else
            counter_clock_divide <= counter_clock_divide + 1;
        end if;
    end if;
end process;

count_divider: process(tmp_clk_val, update, count_flag, current_val, count_to) begin
    if rising_edge(tmp_clk_val) then
        current_val <= current_val+1;
    end if;
            
            
    if rising_edge(update) then
        count_flag <= '1';
    end if;
    --if (current_val >= count_to) then --This is bad it causes 8 to = 10 for no reason and 15 and 16 =31 and such.
    if (current_val = count_to) then    --While this is prone to possible error it does know how to count
    --if (std_logic_vector(to_unsigned(current_val,8)) >= std_logic_vector(to_unsigned(count_to,8))) then
        current_val <= 0;
        count_flag <= '0';
    end if;
    
    enable_clk_divider <= count_flag;
    position_set <= not(count_flag);

 end process; 

--clk division hard connection
out_count_clk <= tmp_clk_val;
--reset <= reset_buffer;

end Behavioral;
