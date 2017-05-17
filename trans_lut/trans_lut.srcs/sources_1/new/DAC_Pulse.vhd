----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2017 01:57:53 PM
-- Design Name: 
-- Module Name: DAC_Pulse - Behavioral
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

entity DAC_Pulse is
    generic(
        clk_division : integer := 2;    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
        max_count : integer := 8    --Base 2 power
    );
  Port ( 
    clk : in std_logic;
    send_pulse : in std_logic;
    VCO_start : in std_logic;
    pulse_sent : out std_logic := '0';
    --out_pulse : out std_logic_vector(max_count-1 downto 0)
    out_int : out integer range 0 to (2**max_count)-1 := 0
  );
end DAC_Pulse;

architecture Behavioral of DAC_Pulse is

signal currentCount : integer range 0 to (2**max_count)-1 := 0;
signal countUp : std_logic := '1';  --1 for up 0 for down

signal counter_clock_divide : integer range 0 to clk_division-1 :=0; --for clock divison

signal count_flag : std_logic := '0';
--signal pulse_flag : std_logic := '0';

begin

--clk division process
clk_divide: process(clk) begin
    --So because VHDL is a STUPID language. You can not check for both rising and falling edges. Or just events. You must specifically look for only one of them.
    --As such the clock is already divided here and I can not change this fact.
    if rising_edge(clk) then
        --currentCount <= currentCount + 1;
        --Check if we have counted to the division number.
        if (counter_clock_divide = clk_division-2) then --To account for the above mentioned division issue I must reduce this by 2. Once for starting at 0 and once for the if rising
            if(count_flag = '1') then
                if(countUp = '1') then
                    currentCount <= currentCount + 1;
                else
                    currentCount <= currentCount - 1;
                end if;
            else
                currentCount <= 0;      --There is this weird issue where when it finishes counting it resets to 15 instead of 0. This fixes that
            end if;
            counter_clock_divide <= 0;
        else
            counter_clock_divide <= counter_clock_divide + 1;
        end if;
    end if;
end process;


start_stop : process(currentCount, send_pulse, countUp) begin
    if rising_edge(send_pulse) then
        count_flag <= '1';
        --pulse_flag <= '0';
        pulse_sent <= '0';
    end if;
    
    if ((currentCount = 0) and (countUp = '0')) then
        countUp <= '1';
        count_flag <= '0';
        pulse_sent <= '1';
        --pulse_flag <= '1';
    end if;
    
    if (currentCount = (2**max_count)-1) then
        countUp <= '0';
    end if;
    --pulse_sent <= not(count_flag);
    --pulse_sent <= pulse_flag;
end process;

out_int <= currentCount;

end Behavioral;
