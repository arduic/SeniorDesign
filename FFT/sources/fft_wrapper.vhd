library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.config.all;
use work.utils.all;


entity fft_wrapper is
    Port (
        aclk : IN STD_LOGIC;
--        s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--        s_axis_config_tvalid : IN STD_LOGIC;
--        s_axis_config_tready : OUT STD_LOGIC;
        s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        s_axis_data_tvalid : IN STD_LOGIC;
        s_axis_data_tready : OUT STD_LOGIC;
        s_axis_data_tlast : IN STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        m_axis_data_tuser : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tready : IN STD_LOGIC;
        m_axis_data_tlast : OUT STD_LOGIC;
        event_frame_started : OUT STD_LOGIC;
        event_tlast_unexpected : OUT STD_LOGIC;
        event_tlast_missing : OUT STD_LOGIC;
        event_status_channel_halt : OUT STD_LOGIC;
        event_data_in_channel_halt : OUT STD_LOGIC;
        event_data_out_channel_halt : OUT STD_LOGIC
    );
end fft_wrapper;

architecture Behavioral of fft_wrapper is

  -----------------------------------------------------------------------
  -- Timing constants
  -----------------------------------------------------------------------
  constant CLOCK_PERIOD : time := 100 ns;
  constant T_HOLD       : time := 10 ns;
  constant T_STROBE     : time := CLOCK_PERIOD - (1 ns);

    
    signal s_axis_config_tready: std_logic := '1';  -- slave is ready
    signal s_axis_config_tvalid: std_logic := '0';  -- payload is valid
    signal s_axis_config_tdata: std_logic_vector(15 downto 0) := (others => '0');  -- data payload
    

component xfft_8bit_256L IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tuser : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_status_channel_halt : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC;
    event_data_out_channel_halt : OUT STD_LOGIC
  );
END component;


begin

  dut : xfft_8bit_256L
    port map (
          aclk                        => aclk,
          s_axis_config_tvalid        => s_axis_config_tvalid,
          s_axis_config_tready        => s_axis_config_tready,
          s_axis_config_tdata         => s_axis_config_tdata,
          s_axis_data_tvalid          => s_axis_data_tvalid,
          s_axis_data_tready          => s_axis_data_tready,
          s_axis_data_tdata           => s_axis_data_tdata,
          s_axis_data_tlast           => s_axis_data_tlast,
          m_axis_data_tvalid          => m_axis_data_tvalid,
          m_axis_data_tready          => m_axis_data_tready,
          m_axis_data_tdata           => m_axis_data_tdata,
          m_axis_data_tuser           => m_axis_data_tuser,
          m_axis_data_tlast           => m_axis_data_tlast,
          event_frame_started         => event_frame_started,
          event_tlast_unexpected      => event_tlast_unexpected,
          event_tlast_missing         => event_tlast_missing,
          event_status_channel_halt   => event_status_channel_halt,
          event_data_in_channel_halt  => event_data_in_channel_halt,
          event_data_out_channel_halt => event_data_out_channel_halt
      );
      
      -----------------------------------------------------------------------
      -- Generate config slave channel inputs
      -----------------------------------------------------------------------
          
      s_axis_config_tdata(0) <= '1';  -- FWD
      s_axis_config_tdata(2 downto 1) <= "11";  -- largest scaling at 1st stage
      s_axis_config_tdata(8 downto 3) <= "101010";
    
      process(s_axis_config_tready)
      begin
        if s_axis_config_tready = '1' then
            s_axis_config_tvalid <= '0';
        end if;
      end process;

end Behavioral;
