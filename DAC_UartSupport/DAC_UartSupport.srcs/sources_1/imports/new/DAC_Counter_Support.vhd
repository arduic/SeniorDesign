--The VCO counter based controller that is connected to a DAC.
--Heavily dependent on the LUT passing valid information.
--1 Instance per VCO controller.

--Created by Patrick Cross
--Last updated: 4/22/2017

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DAC_Counter_Support is
    generic(
    clk_division : integer := 2;    --Used to slow down the clock for testing. Base = 100MHz. Operating freq = 100/clk_division
    max_count : integer := 256      --Bit range of the DAC/Counter. (2^N)
);
Port ( 
    in_clk : in std_logic;                      --Source clk used to operate everything
    out_count_clk : out std_logic;              --Output clock generated to control the counter
    count_to : in integer range 0 to 255 :=255; --Number that the counter should go to. based on LUT
    position_set : out std_logic := '0';        --Identifies to upper lvels when this counter has finished counting. 
    update : in std_logic                       --Signal provided to the counter for when to update
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

begin

--clk division. Not the actual output clock.
clk_divide: process(in_clk) begin
    --All processes need a sensitivity variable so the clk forces a natural division of 2 here.
    if rising_edge(in_clk) then
        --Check if we have counted to the division number.
        if (counter_clock_divide = clk_division-2) then --To account for the above mentioned division issue I must reduce this by 2. Once for starting at 0 and once for the if rising
            tmp_clk_val <= (not(tmp_clk_val) and enable_clk_divider);   --While the clock division is going on we must check if we should output the division
            counter_clock_divide <= 0;                                  --Reset the clock division count
        else
            counter_clock_divide <= counter_clock_divide + 1;           --Increment clock division count
        end if;
    end if;
end process;

--Keeps track of all things that need updating
updater: process(tmp_clk_val, update, count_flag, current_val, count_to) begin
    --Increment when the count goes up (not when division occurs)
    if rising_edge(tmp_clk_val) then
        current_val <= current_val+1;
    end if;
            
    --Check if an update has been requested
    if rising_edge(update) then
        count_flag <= '1';
    end if;
    
    --Check when we have reached the count and stop.
    --NOTE: do NOT put >= while it mathematically should work it causes behaviour of only checking the MSB of count_to.
    if (current_val = count_to) then --While this is prone to possible error it does know how to count
        current_val <= 0;
        count_flag <= '0';
    end if;
    
    enable_clk_divider <= count_flag;   --The flag is used like this so the enable doesn't yell about race conditions that don't actually exsist.    
    position_set <= not(count_flag);    --We are set whenver we are not counting.

 end process; 

out_count_clk <= tmp_clk_val;   --Output the clock division after it's enable check.

end Behavioral;
