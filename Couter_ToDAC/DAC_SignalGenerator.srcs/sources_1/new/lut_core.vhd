----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2017 03:20:00 PM
-- Design Name: 
-- Module Name: lut_core - Behavioral
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

entity lut_core is
    Generic (
        num_rows : integer :=128;
        num_cols : integer :=128;
        num_theta_angles : integer := 256;   --Note since the angles are obviously decimilar but floating point is unneeded due to our low percision (8 bit). I suggest multiply angles by 10 for the LUT
        num_phi_angles : integer :=3    --I was told 3 is a normal number so f it
    );
  Port ( 
    requested_row : in integer;
    requested_col : in integer;
    requested_theta : in integer;
    requested_phi : in integer;
    necessary_voltage : out integer --Again since voltages are going to be decimial but our percision is low, just multiply the voltage by 100
  );
end lut_core;

architecture Behavioral of lut_core is

type voltage_LUT is array (num_rows-1 downto 0, num_cols-1 downto 0, num_theta_angles-1 downto 0, num_phi_angles-1 downto 0) of integer;
signal psi_volt_LUT : voltage_LUT;

--Define the lookup values. Probably need a script to populate this. For now just syntax.
psi_volt_LUT(row,col,theta,angle) <= 4;

begin


end Behavioral;
