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

    --clk division process
    clk_divide: process(in_clk) begin
        --check if the clock is going up and not down
        if rising_edge(in_clk) then
            --Check if we have counted to the division number
            if (counter_clock_divide = clk_division-1) then
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
    
    
--    start_stop_loop: process(send_pulse,current_val,tmp_clk_val) begin
--        --start signal
--        if rising_edge(send_pulse) then
--            reset <= '0';
--            enable_clk_divider := '1';
--        end if;
        
--        --stop signal, Loop for counting
--        --while (current_val<count_to-1) loop
--        if (current_val>=count_to-1) then
        
--        --wait until (current_val>=count_to-1);
--            --wait until rising_edge(tmp_clk_val);
--            --current_val <= current_val+1;
--        --end loop;
--            current_val := 0;
--            enable_clk_divider := '0';
--            reset <= '1';
--        end if;
--    end process;
    
    --Counter for the Timer
--    increment_counter: process begin
--        --if rising_edge(tmp_clk_val) then
--        wait until rising_edge(tmp_clk_val);
--        current_val <= current_val+1;
--        if (current_val>=count_to-1) then
----            wait until falling_edge(tmp_clk_val);
----            wait until rising_edge(tmp_clk_val);   
--            current_val <= 0;     
--        end if;       
--    end process; 
    
    --trigger for send_pulse to ID when the clock division should start (because triggers are not a thing)
--    send_trigger: process(send_pulse) begin
--        if rising_edge(send_pulse) then
--            --reset <= '0';
--            enable_clk_divider <= '1';
--        end if;
--    end process;
    
    --shutoff for the ramping counter to the counter/DAC (This will need to be modified if we want start stop points for future designs)
    --This is better in the long term then using a wait until inside the clock delay
    --This is where the halt count comes into play
--    shutoff: process begin
--        wait until rising_edge(tmp_clk_val);
--        if (current_val>=count_to-1) then
--            enable_clk_divider <= '0';
--            reset <= '1';   --I feel like there should be a delay before this occurs but I can't figure out how to do that.
--            wait until falling_edge(tmp_clk_val);
--            wait until rising_edge(tmp_clk_val);
--            reset <= '0';
--        end if;
--    end process;
    
    --clk division hard connection
    out_count_clk <= tmp_clk_val;
      

end Behavioral;
