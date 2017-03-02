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
    --For the full system these should be 8,8,3 but for testing I am making them 3,3,3
  Generic (
    --Generics for the mux
    array_width_parent : integer :=3;
    array_height_parent : integer :=3;
    mux_size_parent : integer :=3
  );
  Port (
    --Ports for the Mux
    mux_selection_pins : out std_logic_vector(array_width_parent+array_height_parent-1);
    
    --Ports necessary for clock
    clk_in : in std_logic;  --Base clock from the Basys (assumed 100MHz)
    clk_out_ADC : out std_logic; --Generated clock for the ADC (@10MHz)
    
    
    --Ports necessary for FIFO
    buffer_reset : in std_logic;
    clk_in_Buffer : in std_logic    --External source to signal when FFT wants to read next data point 
    
   );
end mux_buffer_connect;

architecture Behavioral of mux_buffer_connect is

    --Component necessary for the mux
    component mux_sel is
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
    end component mux_sel;
    --Signals necessary for the mux
    signal internal_width_incrementer : std_logic_vector(array_width_parent-1 downto 0);
    signal internal_height_incrementer : std_logic_vector(array_width_parent-1 downto 0);
    
    
    --Component necessary for Clock
    --Used to trigger samples from the ADC and cycle the mux's
    --Runs at 10MHz (same speed as ADC). The signal is 100KHz. So advisable to get 1.5 full sign waves, this is 150 clock cycles.
    component clk_wiz_0 is
        PORT(
          clk_in1 : IN std_logic;
          clk_out1 : OUT std_logic;
          reset : IN std_logic := '0';
          locked : OUT std_logic
         );
     end component clk_wiz_0;
    --Signals necessary for clock
     
     
    --Used to store data from the ADC
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

begin

    --Mux mapping
    mux_sel_inst : mux_sel
    generic map (
        array_width => array_width_parent,
        array_height => array_height_parent,
        mux_size => mux_size_parent
    )
    port map ( 
        requested_width => internal_width_incrementer,
        requested_height => internal_height_incrementer,
        selection => mux_selection_pins
    );
    --processes for mux
    
    --Clock mapping
    clk_adc_10 : clk_wiz_0
    port map(
          clk_in1 => clk_in,
          clk_out1 => clk_out_ADC,
          reset => open,    --I don't want to ever reset or check if this clock is locked. To much work for to little benefit
          locked => open
         );
    --Clock processes
    
    
    --Fifo mapping
    fifo_ADC_8x1024 : fifo_generator_0
      port map (
          rst => buffer_reset,
          wr_clk => clk_out_ADC,    --I don't want to write at the exact same time as the mux, I want to be offset by say 1 real clock pulse (settle time of ADC specifically)... can I do that
          rd_clk => clk_in_Buffer,
          din =>
          wr_en =>
          rd_en =>
          dout =>
          full =>
          empty =>
        );
    

end Behavioral;
