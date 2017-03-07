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
use ieee.numeric_std.all;

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
    mux_selection_pins : out std_logic_vector(array_width_parent+array_height_parent-1 downto 0);
    
    --Ports necessary for clock
    clk_in : in std_logic;  --Base clock from the Basys (assumed 100MHz)
    clk_out_ADC : out std_logic; --Generated clock for the ADC (@10MHz)
    
    
    --Ports necessary for FIFO
    buffer_reset : in std_logic;
    buffer_adc_in : in std_logic_vector(2**mux_size_parent-1 downto 0);
    buffer_write_enable : in std_logic; --This allows the transmitter to tell the buffer when new data is incoming, only record during those times
    buffer_read_enable : in std_logic;  --This basically makes it so that the FFT can clock source the read seperate but still have an enable line to use
    buffer_adc_out : out std_logic_vector(2**mux_size_parent-1 downto 0);
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
    signal internal_height_incrementer : std_logic_vector(array_height_parent-1 downto 0);
    constant all_ones_w : std_logic_vector (array_width_parent-1 downto 0) := (others => '1');
    constant all_ones_h : std_logic_vector (array_height_parent-1 downto 0) := (others => '1');
    
    
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
     signal temp_adc_clk : std_logic;
     
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
    --Signals necessary for FIFO
    signal buffer_write_clock : std_logic;

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
    --Moves the mux index around. 
    wh_inc : process(temp_adc_clk) begin
        if rising_edge(temp_adc_clk) then
            if internal_width_incrementer = all_ones_w then
                if internal_height_incrementer = all_ones_h then
                    internal_height_incrementer <= (others => '0');
                else
                    internal_height_incrementer <= std_logic_vector(to_unsigned(to_integer(unsigned(internal_height_incrementer)) + 1, array_height_parent));
                end if;
                internal_width_incrementer <= (others => '0');
            else
                internal_width_incrementer <= std_logic_vector(to_unsigned(to_integer(unsigned(internal_width_incrementer)) + 1, array_width_parent));
            end if;
        end if;
    end process;
    
    --Clock mapping
    clk_adc_10 : clk_wiz_0
    port map(
          clk_in1 => clk_in,
          clk_out1 => temp_adc_clk,
          reset => open,    --I don't want to ever reset or check if this clock is locked. To much work for to little benefit
          locked => open
         );
    --Clock processes
    clk_out_ADC <= temp_adc_clk;
    
    --Fifo mapping
    fifo_ADC_8x1024 : fifo_generator_0
      port map (
          rst => buffer_reset,
          wr_clk => buffer_write_clock,    --This will be delayed from the output to ADC clock, depends on the enable to time things correctly. The first reading might be 0 but eh no biggy
          rd_clk => clk_in_Buffer,
          din => buffer_adc_in,
          wr_en => buffer_write_enable,
          rd_en => buffer_read_enable,
          dout => buffer_adc_out,
          full => open, --For now I am not going to connect these. Eventually I should probably connect full but empty is a moot point
          empty => open
        );
     --Fifo processes
     buffer_write_clock <= not(temp_adc_clk);   --1/2 clock cycle success
    

end Behavioral;
