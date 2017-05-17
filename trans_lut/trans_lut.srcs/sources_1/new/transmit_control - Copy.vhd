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
        
        psi0_clk : out std_logic;
        psi0_reset : out std_logic;
        psi1_clk : out std_logic;
        psi1_reset : out std_logic;
        psi2_clk : out std_logic;
        psi2_reset : out std_logic;
        psi3_clk : out std_logic;
        psi3_reset : out std_logic;
        psi4_clk : out std_logic;
        psi4_reset : out std_logic;
        psi_update : in std_logic
        
     );
end transmit_control;

architecture Behavioral of transmit_control is
    
    signal highSpeed_clk: std_logic;
    signal highSpeed_locked: std_logic;
    signal highSped_reset: std_logic;
    
    signal psi0_tmp_step : integer;
    signal psi1_tmp_step : integer;
    signal psi2_tmp_step : integer;
    signal psi3_tmp_step : integer;
    signal psi4_tmp_step : integer;
    signal returnTheta : integer;
    
    signal psi0_dummy_clk : std_logic;
        
    component DAC_Counter_Support is
    generic(
        clk_division : integer := 2;
        max_count : integer := 256
    );
    Port ( 
        in_clk : in std_logic;
        out_count_clk : out std_logic;         --(CLK)
        reset : out std_logic := '0';          --(MR)
        count_to : in integer;       --Number that the counter should go to. based on LUT
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
        necessary_voltage_psi0 : out integer;
        necessary_voltage_psi1 : out integer;
        necessary_voltage_psi2 : out integer;
        necessary_voltage_psi3 : out integer;
        necessary_voltage_psi4 : out integer;
        returned_theta_ang : out integer
      );
    end component lut_core;

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
        requested_row=>60,
        requested_col=>30,
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
        clk_division => 2,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi0_dummy_clk,
        reset => psi0_reset,
        count_to => psi0_tmp_step,
        update => psi_update
    );
    
    psi1_control : DAC_Counter_Support
    generic map (
        clk_division => 2,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi1_clk,
        reset => psi1_reset,
        count_to => psi1_tmp_step,
        update => psi_update
    );

    psi2_control : DAC_Counter_Support
    generic map (
        clk_division => 2,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi2_clk,
        reset => psi2_reset,
        count_to => psi2_tmp_step,
        update => psi_update
    );

    psi3_control : DAC_Counter_Support
    generic map (
        clk_division => 2,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi3_clk,
        reset => psi3_reset,
        count_to => psi3_tmp_step,
        update => psi_update
    );

    psi4_control : DAC_Counter_Support
    generic map (
        clk_division => 2,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi4_clk,
        reset => psi4_reset,
        count_to => psi4_tmp_step,
        update => psi_update
    );

    dummy_out <= clk;
    dummy2 <= theta_req(0);
    dummy3 <= psi0_dummy_clk;
    psi0_clk <= psi0_dummy_clk;

end Behavioral;
