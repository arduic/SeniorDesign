library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config.all;
use work.utils.all;


entity fft_wrapper is
    Port (
        aclk : IN STD_LOGIC;
--        s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--        s_axis_config_tvalid : IN STD_LOGIC;
--        s_axis_config_tready : OUT STD_LOGIC;
        s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);  -- The actual input data
        s_axis_data_tvalid : IN STD_LOGIC;  -- Heep high when inputting tdata, then low when not
        s_axis_data_tready : OUT STD_LOGIC;  -- Indicates when the ip core can accept data; must hold the tdata and tvalid constant when this is low while attempting to inpput valid data
--        s_axis_data_tlast : IN STD_LOGIC;  -- Keep low when inputting tdata, high otherwise
--        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);  -- The actual output data
--        m_axis_data_tuser : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--        m_axis_data_tvalid : OUT STD_LOGIC;
--        m_axis_data_tready : IN STD_LOGIC;
--        m_axis_data_tlast : OUT STD_LOGIC;

        r_out: out unsigned(31 downto 0);
        vr_out: out unsigned(31 downto 0);
        reset_buff: out std_logic;
        valid_output: out std_logic;

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
    
    signal s_axis_data_tlast: std_logic;
    
    -- Data master channel signals
    signal m_axis_data_tvalid          : std_logic := '0';  -- payload is valid
    signal m_axis_data_tready          : std_logic := '1';  -- slave is ready
    signal m_axis_data_tdata           : std_logic_vector(2*input_width-1 downto 0) := (others => '0');  -- data payload
    signal m_axis_data_tuser           : std_logic_vector(7 downto 0) := (others => '0');  -- user-defined payload
    signal m_axis_data_tlast           : std_logic := '0';  -- indicates end of packet
    signal m_axis_data_tuser_xk_index: std_logic_vector(7 downto 0) := (others => '0');  -- sample index
    

  signal MAG_DATA: T_MAG_TABLE := MAG_TABLE_CLEAR;
  signal max_mag: integer := 0;
  signal max_mag_i: integer := 0;
  signal max_freq: integer := 0;
  signal reset_buffer: std_logic := '0';
  signal valid_out_tmp: std_logic := '0';
  
  signal freq_buff: freq_buff_t := (others => 0);
  signal window_count: integer := 0;
  signal fb_up, fb_down, fr, fd: integer := 0;
  signal r, vr: integer := 0;


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
      
      s_axis_data_tlast <= not s_axis_data_tvalid;  -- The last input will be indicated when the input is no longer valid
      m_axis_data_tuser_xk_index <= m_axis_data_tuser(7 downto 0);
      
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
      
      
      max_freq <= FREQ_SPEC(max_mag_i);
      fb_up <= freq_buff(0);
      fb_down <= freq_buff(windows-1);
      fr <= (fb_up+fb_down)/2;
      fd <= (fb_down-fb_up)/2;
      r <= fr/KR;
      vr <= fd/KD;
      r_out <= to_unsigned(r, r_out'length);
      vr_out <= to_unsigned(vr, vr_out'length);
      
      reset_buff <= reset_buffer;
      valid_output <= valid_out_tmp;
      
      
  record_outputs : process (aclk)
        variable index : integer := 0;
        variable re_v, im_v: std_logic_vector(input_width-1 downto 0);
        variable re_i, im_i, mag: integer;
        variable wc: integer;
      begin
        if rising_edge(aclk) then
          if m_axis_data_tvalid = '1' and m_axis_data_tready = '1' then
            -- Record output data such that it can be used as input data
            -- Output sample index is given by xk_index field of m_axis_data_tuser
            index := to_integer(unsigned(m_axis_data_tuser_xk_index));
            valid_out_tmp <= '0';
            
            re_v := m_axis_data_tdata(7 downto 0);
            im_v := m_axis_data_tdata(15 downto 8);
            re_i := to_integer(signed(re_v));
            im_i := to_integer(signed(im_v));
            
            mag := re_i*re_i + im_i*im_i;
            mag_data(index) <= mag;
            if mag > max_mag and index < fftlen_cutoff then
                max_mag <= mag;
                max_mag_i <= index;
            end if;
            
            -- Track the number of output frames
            if m_axis_data_tlast = '1' then  -- end of output frame: increment frame counter
              freq_buff(window_count) <= max_freq;
              wc := window_count + 1;
              window_count <= wc mod windows;
              reset_buffer <= '1';
              if wc = 4 then
                valid_out_tmp <= '1';
              end if;
            end if;
          elsif reset_buffer = '1' then
            mag_data <= mag_table_clear;
            max_mag <= 0;
            max_mag_i <= 0;
            reset_buffer <= '0';
          end if;
        end if;
      end process record_outputs;
      

end Behavioral;
