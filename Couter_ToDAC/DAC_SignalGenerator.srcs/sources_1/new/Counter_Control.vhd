----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2017 11:17:11 AM
-- Design Name: 
-- Module Name: Counter_Control - Behavioral
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

-- Hardware I am working with http://www.digikey.com/product-detail/en/on-semiconductor/MC100EP016AFAG/MC100EP016AFAGOS-ND/920658
--P0-P7 ECL Parallel Data (Preset) Inputs       Tie all to GND but it can honestly just be floating as we will never use the load operation (It'd be nice to have for advanced chirps but is way to many pins).
--Q0-Q7 ECL Data Outputs                        Outputs will be connected to the DAC
--CE* ECL Count Enable Control Input            Connect this. It allows us to halt the count without needing an if statment in the clk signal which would delay it.
--PE* ECL Parallel Load Enable Control Input    Since we can't use load this is just tied to GND
--MR* ECL Master Reset                          Definitely need this connected
--CLK*, CLK* ECL Differential Clock             This is going to be the generated clock for output and such
--TC ECL Terminal Count Output                  Represents when at 255. May want to use but since we are counting at 225 it's probably useless
--TCLD* ECL TC-Load Control Input               When the counter reaches 255 it will load P0-P7 no use I can think of here
--COUT, COUT ECL Differential Output            It seems the same as Tc, supposedly they are for different carry operations but it doesn't matter, we don't need either.
--VCC Positive Supply                           Connect to VCC  (These will be for reference for the DAC not the final signal)
--VEE Negative Supply                           Connect to GND
--VBB Reference Voltage Output                  Probably VCC
--EP The exposed pad (EP) on the QFN-32 package bottom is thermally connected to the die for improved
--heat-sinking conduit. The pad is electrically connected to VEE


--For now I am working on just making it send a full chirp, nothing special later we work on special.
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

entity Counter_Control is
    generic(
        clk_division : integer := 2;    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
        count_to : integer := 225       --Number that the counter should go to. calculate by base_clk_speed/clk_division
    );
    Port ( 
        in_clk : in std_logic;
        out_count_clk : out std_logic := '0';  --(CLK)
        send_pulse : in std_logic;    
        reset : out std_logic := '0'          --(MR)
        --halt_count : out std_logic      --(CE)
    );
end Counter_Control;

architecture Behavioral of Counter_Control is
    --clk division variables
    signal tmp_clk_val : std_logic;
    signal counter_clock_divide : integer range 0 to clk_division-1 :=0; --for clock divison
    signal current_val : integer range 0 to count_to-1 :=0; --for incrementation of the counter
    
    --pulse enabling variables
    signal enable_clk_divider : std_logic := '0';
begin

    --Note to self. This check for only rising edge causes a 2x clock division. need to check for both rise and fall.
    --Also I am unsure if this clock division is going fast enough. When I set clock speed to 100MHz and do just 2x clock I get 50.
    --However running this at 450 I get only slightly above 50.... seems strange.
    --clk division process
    clk_divide: process(in_clk) begin
        --So because VHDL is a STUPID language. You can not check for both rising and falling edges. Or just events. You must specifically look for only one of them.
        --As such the clock is already divided here and I can not change this fact.
        if rising_edge(in_clk) then
            --Check if we have counted to the division number.
            if (counter_clock_divide = clk_division-2) then --To account for the above mentioned division issue I must reduce this by 2. Once for starting at 0 and once for the if rising
                tmp_clk_val <= (not(tmp_clk_val) and enable_clk_divider);    --A single clock pulse          --Instead I could have the enable work by taking a bitwise && with the enable and the clock
                --tmp_clk_val <= not(tmp_clk_val);
                counter_clock_divide <= 0;
            else
                counter_clock_divide <= counter_clock_divide + 1;
            end if;
        end if;
    end process;
    
    enable_divider: process(send_pulse,tmp_clk_val) begin
        if rising_edge(tmp_clk_val) then
            current_val <= current_val+1;
        end if;
                
        if (current_val>=count_to-1) then
            current_val <= 0;
            enable_clk_divider <= '0';
            reset <= '1';
        elsif (rising_edge(send_pulse) and (current_val=0)) then
            enable_clk_divider <= '1';
            reset <= '0';
        end if;
     end process; 
     
    --Simple 2X clock division for testing
--    clk_div: process(in_clk) begin
--        if rising_edge(in_clk) then
--            tmp_clk_val <= not(tmp_clk_val);
--        end if;
--    end process;
    
    
    
    --clk division hard connection
    out_count_clk <= tmp_clk_val;
      

end Behavioral;
