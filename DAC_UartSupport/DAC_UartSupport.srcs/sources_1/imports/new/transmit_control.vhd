--Used to control all VCOs and the pulse
--Requires an update command and requested LUT address
--Only 1 instance needed

--Created by Patrick Cross
--Last updated: 4/22/2017

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;                         
USE ieee.numeric_std.ALL;

entity transmit_control is
    generic (
        clk_division : integer := 2
    );
    Port (
        clk : in std_logic;                                         --Input clock used for timing
        row_m_req : in integer := 15;                               --Requested row in the LUT (note LUT is of size 32 to make synthesis possible as such take normal address and divide by 4, floor function)
        col_n_req : in integer := 7;                                --Requested collumn in the LUT
        theta_req : in std_logic_vector(7 downto 0);                --Requested theta val. Note it's in std_logic_vector because of how UART returns.
        psi_req : in integer := 1;                                  --Requested psi val.
        
        
        psi0_clk : out std_logic;                                   --Output clk for the psi0 VCO.
        psi_reset : out std_logic;                                  --Output used to reset the psi counters
        psi1_clk : out std_logic;                                   --Output clk for the psi1 VCO.
        psi2_clk : out std_logic;                                   --Output clk for the psi2 VCO.
        psi3_clk : out std_logic;                                   --Output clk for the psi3 VCO.
        psi4_clk : out std_logic;                                   --Output clk for the psi4 VCO.
        psi_update : in std_logic;                                  --Request update for the VCO's
        realRes : out std_logic;
        
        trans_DACarray : out std_logic_vector(7 downto 0);          --Output DAC values for the main pulse
        DAC_clk : out std_logic                                     --Inverted clock signal to update the DAC 180 out of phase from counters
     );
end transmit_control;

architecture Behavioral of transmit_control is
    
    --Clocking wizard output. (Removes a lot of the need for a clock divider, NOT ALL)
    signal highSpeed_clk: std_logic;
    
    --Temporary holding variables between LUT and VCO counters
    signal psi0_tmp_step : integer range 0 to 255;
    signal psi1_tmp_step : integer range 0 to 255;
    signal psi2_tmp_step : integer range 0 to 255;
    signal psi3_tmp_step : integer range 0 to 255;
    signal psi4_tmp_step : integer range 0 to 255;
    signal returnTheta : integer;
    
    --Singals to ID when the VCOs have finished counting
    signal psi0_set : std_logic := '0';
    signal psi1_set : std_logic := '0';
    signal psi2_set : std_logic := '0';
    signal psi3_set : std_logic := '0';
    signal psi4_set : std_logic := '0';
    
    --Pulse temporary signals
    signal trans_complete : std_logic;
    signal trans_send : std_logic := '0';
    signal trans_int : integer range 0 to (2**8)-1 := 0;
    
    --Needed to create 180 phase shift clock
    signal DAC_dummy_clk : std_logic := '0';
        
        
    --Declare all the necessary components
    component DAC_Counter_Support is
    generic(
        clk_division : integer := 2;
        max_count : integer := 256
    );
    Port ( 
        in_clk : in std_logic;
        out_count_clk : out std_logic;         --(CLK)
        --reset : out std_logic := '0';          --(MR)
        count_to : in integer range 0 to 255;       --Number that the counter should go to. based on LUT
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
            clk_division : integer := 2;    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
            max_count : integer := 8    --Base 2 power
        );
      Port ( 
        clk : in std_logic;
        send_pulse : in std_logic;
        pulse_sent : out std_logic := '0';
        --out_pulse : out std_logic_vector(max_count-1 to 0)
        out_int : out integer range 0 to (2**max_count)-1 := 0
      );
    end component DAC_Pulse;

begin

    --Clocking wizard generator.
    --WARNING ALERT READ READ
    --I have not as of yet determined the cause of this but I know it to be true.
    --If I try to place the VCO psi0 generators on the same clk as the pulse it causes massive pain and suffering.
    --As such I advise using the built in clock dividers to create any delays and setting the generator to 100MHz.
    --I'm guessing it creates some minute delay that I am accidentally abusing but idk.
    clk_generator : clk_wiz_0
    port map (
        clk_out1 => highSpeed_clk,
        locked => open,
        reset => open,
        clk_in1 => clk
    );

    --LUT instance
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

    --VCO instances Note they map to the highSpeed_clk for later convenience
    psi0_control : DAC_Counter_Support
    generic map (
        clk_division => clk_division,
        max_count => 256
    )
    port map    (  
        in_clk => highSpeed_clk,
        out_count_clk => psi0_clk,
        count_to => psi0_tmp_step,
        position_set => psi0_set,
        update => psi_update
    );
    
    psi1_control : DAC_Counter_Support
    generic map (
        clk_division => clk_division,
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
        clk_division => clk_division,
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
        clk_division => clk_division,
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
        clk_division => clk_division,
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
    
    --Pulse instance
    main_pulse : DAC_Pulse
        generic map(
            clk_division => clk_division,    -- This is calculated by taking Val = ceil(base_clk_speed/2^num_bits) where ceil goes only to power of 2 numbers 450/2^8=2
            max_count => 8    --Base 2 power
        )
      port map ( 
        clk => clk,
        send_pulse => trans_send,
        pulse_sent => trans_complete,
        --out_pulse => trans_DACarray
        out_int => trans_int
      );
    
    --Used to reset the VCO's. Reset is done when we have completed both the VCO set and the pulse transmit. 
    --Because VCO set goes high when pulse_complete goes low there is a <1 clock cycle race condition where the reset tries to go high.
    --As long as the number stays low this shouldn't be a problem. However for safety sake I wrapped it in a clock trigger. Slight delay to VCO reset is not an issue.
    
    
    ps_res : process(clk) begin
        if rising_edge(clk) then
            --psi_reset <= (trans_send and trans_complete); 
            psi_reset <= (trans_send);
            realRes <= (trans_send and trans_complete);
        end if;
    end process;
    
    
    
    --Convert the DAC pulse from an integer to a vector to plot
    trans_DACarray <= std_logic_vector(to_unsigned(trans_int, 8));
    
    --Used to ID when all VCO's are set. 
    trans_send <= (psi0_set and psi1_set and psi2_set and psi3_set and psi4_set);
    
    --For now since the clock division is just hard set I'm not going to universalize this. Basically DAC_clk needs to be 180 out of phase with the other clocks
    --I accomplish this via falling_edge instead of rising. Will need to update later.
    myDiv: process(clk) begin
        if falling_edge(clk) then
            DAC_dummy_clk <= not(DAC_dummy_clk);
        end if;
    end process;
    --Output the pulse for the DAC clock.
    DAC_clk <= DAC_dummy_clk;

end Behavioral;
