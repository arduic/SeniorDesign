----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2017 03:21:29 PM
-- Design Name: 
-- Module Name: transmit_control - Behavioral
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

entity transmit_control is
    Port (
        clk : in std_logic;
        row_m_req : in integer := 60;
        col_n_req : in integer := 30;
        theta_req : in std_logic_vector(7 downto 0);
        psi_req : in integer := 1;
        
        dummy_out : out std_logic;
        dummy2 : out std_logic;
        dummy3 : out std_logic;
        dummy4 : out std_logic;
        dum5 : out std_logic;
        debug_array : out std_logic_vector(7 downto 0);
        
        psi0_clk : out std_logic;
        psi0_reset : out std_logic;
        psi1_clk : out std_logic;
        --psi1_reset : out std_logic;
        psi2_clk : out std_logic;
        --psi2_reset : out std_logic;
        psi3_clk : out std_logic;
        --psi3_reset : out std_logic;
        psi4_clk : out std_logic;
        --psi4_reset : out std_logic;
        psi_update : in std_logic;
        
        trans_DACarray : out std_logic_vector(7 downto 0)
        
     );
end transmit_control;

architecture Behavioral of transmit_control is
    
    signal highSpeed_clk: std_logic;
    signal highSpeed_locked: std_logic;
    signal highSped_reset: std_logic;
    
    signal psi0_tmp_step : integer range 0 to 255;
    signal psi1_tmp_step : integer range 0 to 255;
    signal psi2_tmp_step : integer range 0 to 255;
    signal psi3_tmp_step : integer range 0 to 255;
    signal psi4_tmp_step : integer range 0 to 255;
    signal returnTheta : integer;
    
    signal psi0_set : std_logic;
    signal psi1_set : std_logic;
    signal psi2_set : std_logic;
    signal psi3_set : std_logic;
    signal psi4_set : std_logic;
    
    signal trans_complete : std_logic;
    signal trans_send : std_logic;
    signal trans_int : integer range 0 to 255;
    
    signal psi0_dummy_clk : std_logic;
    
    --signal dumdumBuf : std_logic;
        
    component DAC_Counter_Support is
    generic(
        clk_division : integer := 1000;
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
    end component DAC_Counter_Support;

    component clk_wiz_0 is
        Port (
            clk_out1: out std_logic;
            locked: out std_logic;
            
            reset: in std_logic := '0';
            clk_in1: in std_logic
    );
    end component clk_wiz_0;    
    
    component lut_core is
        Generic (
            num_rows : integer :=128;
            num_cols : integer :=128;
            num_theta_angles : integer := 216;
            num_phi_angles : integer :=3
        );
      Port ( 
        clk : in std_logic;
        requested_row : in integer;
        requested_col : in integer;
        requested_theta : in integer;
        requested_phi : in integer;
        necessary_voltage_psi0 : out integer range 0 to 255;
        necessary_voltage_psi1 : out integer range 0 to 255;
        necessary_voltage_psi2 : out integer range 0 to 255;
        necessary_voltage_psi3 : out integer range 0 to 255;
        necessary_voltage_psi4 : out integer range 0 to 255;
        returned_theta_ang : out integer
      );
    end component lut_core;
    
    component DAC_Pulse is
        generic(
            clk_division : integer := 1000;    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
            max_count : integer := 8    --Base 2 power
        );
      Port ( 
        clk : in std_logic;
        send_pulse : in std_logic;
        VCO_start : in std_logic;
        pulse_sent : out std_logic := '0';
        --out_pulse : out std_logic_vector(max_count-1 to 0)
        out_int : out integer range 0 to (2**max_count)-1 := 0
      );
    end component DAC_Pulse;

begin

    clk_450_generator : clk_wiz_0
    port map (
        clk_out1 => highSpeed_clk,
        locked => open,
        reset => open,
        clk_in1 => clk
    );

    psi_LUT_inst : lut_core
    generic map(
            num_rows => 32,
            num_cols => 32,
            num_theta_angles => 216,
            num_phi_angles => 3
        )
    port map( 
        clk=>clk,
        requested_row=>15,
        requested_col=>7,
        requested_theta => to_integer(unsigned(theta_req)),
        requested_phi=>1,
        necessary_voltage_psi0 => psi0_tmp_step,
        necessary_voltage_psi1 => psi1_tmp_step,
        necessary_voltage_psi2 => psi2_tmp_step,
        necessary_voltage_psi3 => psi3_tmp_step,
        necessary_voltage_psi4 => psi4_tmp_step,
        returned_theta_ang => returnTheta
      );

    psi0_control : DAC_Counter_Support
    generic map (
        clk_division => 1000,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi0_dummy_clk,
        --reset => psi0_reset,
        count_to => psi0_tmp_step,
        position_set => psi0_set,
        update => psi_update
    );
    
    psi1_control : DAC_Counter_Support
    generic map (
        clk_division => 1000,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi1_clk,
        --reset => psi1_reset,
        count_to => psi1_tmp_step,
        position_set => psi1_set,
        update => psi_update
    );

    psi2_control : DAC_Counter_Support
    generic map (
        clk_division => 1000,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi2_clk,
        --reset => psi2_reset,
        count_to => psi2_tmp_step,
        position_set => psi2_set,
        update => psi_update
    );

    psi3_control : DAC_Counter_Support
    generic map (
        clk_division => 1000,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi3_clk,
        --reset => psi3_reset,
        count_to => psi3_tmp_step,
        position_set => psi3_set,
        update => psi_update
    );

    psi4_control : DAC_Counter_Support
    generic map (
        clk_division => 1000,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi4_clk,
        --reset => psi4_reset,
        count_to => psi4_tmp_step,
        position_set => psi4_set,
        update => psi_update
    );
    
    main_pulse : DAC_Pulse
        generic map(
            clk_division => 1000,    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
            max_count => 8    --Base 2 power
        )
      port map ( 
        clk => clk,
        send_pulse => trans_send,
        VCO_start => psi_update,
        pulse_sent => trans_complete,
        --out_pulse => trans_DACarray
        out_int => trans_int
      );
    
    stuff : process(clk) begin
        if rising_edge(clk) then
            debug_array <= std_logic_vector(to_unsigned(psi0_tmp_step, 8));
        end if;
    end process;
    
    --psi0_reset <= (trans_send and trans_complete);  --Only need 1 reset for all of them since they are all reset at the same time. This method does create a ~1V peak for a very short amount of time.
    psi0_reset <= (trans_send);
    
    --psi0_reset <= dumdumBuf;
    --This is because there is a very short (less then 1 clock cycle) delay between trans_send going high and trans_complete going low. This is because 1 triggers the other.
    
    --dumdumBuf <= trans_send and trans_complete;
    
    trans_DACarray <= std_logic_vector(to_unsigned(trans_int, 8));
    
    trans_send <= (psi0_set and psi1_set and psi2_set and psi3_set and psi4_set);
    dummy4 <= trans_send;

    dummy_out <= clk;
    dummy2 <= theta_req(0);
    dummy3 <= psi0_dummy_clk;
    dum5 <= (trans_send and trans_complete);
    psi0_clk <= psi0_dummy_clk;

end Behavioral;
