----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2017 03:03:10 PM
-- Design Name: 
-- Module Name: count_control_hdM - Behavioral
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

entity count_control_hdM is
    generic(
        clk_division : integer := 2;    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
        count_to : integer := 225       --Number that the counter should go to. calculate by base_clk_speed/clk_division
    );
  Port (
    clk : in std_logic;
    
        --Counter stuff
    counter_clk : out std_logic;
    counter_pulse : in std_logic;
    counter_reset : out std_logic
    --counter_halt : out std_logic
   );
end count_control_hdM;

architecture Behavioral of count_control_hdM is

    component Counter_Control is
        generic(
            clk_division : integer := 2;    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
            count_to : integer := 225       --Number that the counter should go to. calculate by base_clk_speed/clk_division
        );
        Port ( 
            in_clk : in std_logic;
            out_count_clk : out std_logic := '0';  --(CLK)
            send_pulse : in std_logic;      --Currently there is an over ride in the XDC to let this work. It's not really a problem because in the final design this will not be a hardware pin
            reset : out std_logic := '0'          --(MR)
            --halt_count : out std_logic      --(CE)
        );
    end component Counter_Control;

begin

    Counter_Control_inst : Counter_Control
    generic map (
        clk_division                => clk_division,
        count_to     => count_to
    )
    port map    (  
        -- general
        in_clk               => clk,
        out_count_clk               => counter_clk,
        send_pulse      => counter_pulse,
        reset  => counter_reset
        --halt_count  => counter_halt
    );

    

end Behavioral;
