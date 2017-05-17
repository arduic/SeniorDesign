----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2017 05:52:57 PM
-- Design Name: 
-- Module Name: trans_uart_sync - Behavioral
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

entity trans_uart_sync is
    generic (
        baud            : positive := 9600;
        clock_frequency : positive := 100000000
    );
    Port (
        --DAC Stuff
        clk : in std_logic;
        row_m_req : in integer := 15;
        col_n_req : in integer := 7;
        psi_req : in integer := 1;        
        
        psi0_clk : out std_logic;
        psi_reset : out std_logic;
        psi1_clk : out std_logic;
        psi2_clk : out std_logic;
        psi3_clk : out std_logic;
        psi4_clk : out std_logic;
        realRes : out std_logic;
        
        trans_DACarray : out std_logic_vector(7 downto 0);
        DAC_clk : out std_logic;
        
        --UART stuff
        reset           : in std_logic;    
        rx              : in std_logic;
        tx              : out std_logic
 );
end trans_uart_sync;

architecture Behavioral of trans_uart_sync is

component DAC_UART is
    generic (
        baud            : positive := 9600;
        clock_frequency : positive := 100000000
    );
    port (  
        clk           : in std_logic;
        reset           : in std_logic;    
        rx              : in std_logic;
        recv_val        : out std_logic_vector(7 downto 0);
        recv_trig       : out std_logic;
        tx              : out std_logic
    );
end component DAC_UART;

component transmit_control is
    generic(
        clk_division : integer := 2
    );
    Port (
        clk : in std_logic;
        row_m_req : in integer := 15;
        col_n_req : in integer := 7;
        theta_req : in std_logic_vector(7 downto 0);
        psi_req : in integer := 1;
        
        psi0_clk : out std_logic;
        psi_reset : out std_logic;
        psi1_clk : out std_logic;
        psi2_clk : out std_logic;
        psi3_clk : out std_logic;
        psi4_clk : out std_logic;
        psi_update : in std_logic;
        realRes : out std_logic;
        
        trans_DACarray : out std_logic_vector(7 downto 0);
        DAC_clk : out std_logic
     );
end component transmit_control;

    signal uart_recv_val : std_logic_vector(7 downto 0);
    signal uart_recv_trig : std_logic;

begin

    uart_loop : DAC_UART
    generic map (
        baud => baud,
        clock_frequency => clock_frequency
    )
    port map(  
        clk => clk,
        reset => reset,  
        rx => rx,
        recv_val => uart_recv_val,
        recv_trig => uart_recv_trig,
        tx => tx
    );
    
    transmitter : transmit_control
        generic map(
            clk_division => 1000
        )
        port map (
            clk => clk,
            row_m_req  => 15,
            col_n_req => 7,
            theta_req => uart_recv_val,
            psi_req => 1,
            
            psi0_clk => psi0_clk,
            psi_reset => psi_reset,
            psi1_clk => psi1_clk,
            psi2_clk => psi2_clk,
            psi3_clk => psi3_clk,
            psi4_clk => psi4_clk,
            psi_update => uart_recv_trig,
            realRes => realRes,
            
            trans_DACarray => trans_DACarray,
            DAC_clk => DAC_clk
         );


end Behavioral;
