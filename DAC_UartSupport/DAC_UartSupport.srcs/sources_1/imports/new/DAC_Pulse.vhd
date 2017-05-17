--The chirp based controller for the DAC
--Seperate from the Counter because it's behaviour is much simpler and requires less functionality.
--Heavily dependent on the LUT passing valid information.

--Created by Patrick Cross
--Last updated: 4/22/2017

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity DAC_Pulse is
    generic(
        clk_division : integer := 2;    --Used to slow down the clock for testing. Base = 100MHz. Operating freq = 100/clk_division
        max_count : integer := 8        --Base 2 resolution of DAC.
    );
  Port ( 
    clk : in std_logic;                                         --Source clk used to operate everything
    send_pulse : in std_logic;                                  --Used to tell pulse to start.
    pulse_sent : out std_logic := '0';                          --Used to signify when pulse is complete
    out_int : out integer range 0 to (2**max_count)-1 := 0      --Output INTEGER for the pulse value. Do not return std_logic_vector it does not behave correctly.
  );
end DAC_Pulse;

architecture Behavioral of DAC_Pulse is

--Used for counting
signal currentCount : integer range 0 to (2**max_count)-1 := 0;
signal countUp : std_logic := '1';  --1 for up 0 for down

--Used for clock division
signal counter_clock_divide : integer range 0 to clk_division-1 :=0; --for clock divison

--Used for signaling
signal count_flag : std_logic := '0';

begin

--clk division process
clk_divide: process(clk) begin
    --All processes need a sensitivity variable so the clk forces a natural division of 2 here.
    if rising_edge(clk) then
        --Check if we have counted to the division number.
        if (counter_clock_divide = clk_division-2) then --To account for the above mentioned division issue I must reduce this by 2. Once for starting at 0 and once for the if rising
            if(count_flag = '1') then                   --Check if we should be counting
                if(countUp = '1') then                  --Check the direction to be counting
                    currentCount <= currentCount + 1;   --Count
                else
                    currentCount <= currentCount - 1;
                end if;
            else
                currentCount <= 0;      --There is this weird issue where when it finishes counting it resets to 15 instead of 0. This fixes that
            end if;
            counter_clock_divide <= 0;  --Reset the division counter (not DAC counter)
        else
            counter_clock_divide <= counter_clock_divide + 1;   --Increment division counter
        end if;
    end if;
end process;

--Process to handle start and stop of the pulse
start_stop : process(currentCount, send_pulse, countUp) begin
    --Check when to start counting update accordingly
    if rising_edge(send_pulse) then
        count_flag <= '1';
        pulse_sent <= '0';
    end if;
    
    --Check when to stop counting
    if ((currentCount = 0) and (countUp = '0')) then
        countUp <= '1';
        count_flag <= '0';
        pulse_sent <= '1';
    end if;
    
    --Check when to start ramping down and react
    if (currentCount = (2**max_count)-1) then
        countUp <= '0';
    end if;
end process;

out_int <= currentCount;    --Output the count value. 

end Behavioral;
