library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

library work;
use work.config.all;
use work.utils.all;

entity tb_xfft_8bit_256L is
end tb_xfft_8bit_256L;

architecture tb of tb_xfft_8bit_256L is

  -----------------------------------------------------------------------
  -- Timing constants
  -----------------------------------------------------------------------
  constant CLOCK_PERIOD : time := 100 ns;
  constant T_HOLD       : time := 10 ns;
  constant T_STROBE     : time := CLOCK_PERIOD - (1 ns);

  -----------------------------------------------------------------------
  -- DUT signals
  -----------------------------------------------------------------------

  -- General signals
  signal aclk                        : std_logic := '0';  -- the master clock

  -- Data slave channel signals
  signal s_axis_data_tvalid          : std_logic := '0';  -- payload is valid
  signal s_axis_data_tready          : std_logic := '1';  -- slave is ready
  signal s_axis_data_tdata           : std_logic_vector(15 downto 0) := (others => '0');  -- data payload

  -- Data master channel signals
  signal m_axis_data_tlast           : std_logic := '0';  -- indicates end of packet

  -- Event signals
  signal event_frame_started         : std_logic := '0';
  signal event_tlast_unexpected      : std_logic := '0';
  signal event_tlast_missing         : std_logic := '0';
  signal event_status_channel_halt   : std_logic := '0';
  signal event_data_in_channel_halt  : std_logic := '0';
  signal event_data_out_channel_halt : std_logic := '0';

  -----------------------------------------------------------------------
  -- Aliases for AXI channel TDATA and TUSER fields
  -- These are a convenience for viewing data in a simulator waveform viewer.
  -- If using ModelSim or Questa, add "-voptargs=+acc=n" to the vsim command
  -- to prevent the simulator optimizing away these signals.
  -----------------------------------------------------------------------

  -- Data slave channel alias signals
  signal s_axis_data_tdata_re             : std_logic_vector(7 downto 0) := (others => '0');  -- real data
  signal s_axis_data_tdata_im             : std_logic_vector(7 downto 0) := (others => '0');  -- imaginary data

  -----------------------------------------------------------------------
  -- Constants, types and functions to create input data
  -----------------------------------------------------------------------

  constant IP_WIDTH    : integer := 8;
  constant MAX_SAMPLES : integer := 2**8;  -- maximum number of samples in a frame
  type T_IP_SAMPLE is record
    re : std_logic_vector(IP_WIDTH-1 downto 0);
    im : std_logic_vector(IP_WIDTH-1 downto 0);
  end record;
  type T_IP_TABLE is array (0 to MAX_SAMPLES-1) of T_IP_SAMPLE;

  -- Zeroed input data table, for reset and initialization
  constant IP_TABLE_CLEAR : T_IP_TABLE := (others => (re => (others => '0'),
                                                      im => (others => '0')));
                                                      
                                                      
    -- Function to read in an input signal from a text file specified in config.vhd
  impure function create_ip_table_from_file return T_IP_TABLE is
      variable input_line: line;
      variable tre, tim: integer;
      
      variable result: T_IP_TABLE;
  begin
      for i in 0 to MAX_SAMPLES-1 loop
          readline(data_in, input_line);
          read(input_line, tre);
          read(input_line, tim);
          
          result(i).re := std_logic_vector(to_signed(tre, IP_WIDTH));
          result(i).im := std_logic_vector(to_signed(tim, IP_WIDTH));
      end loop;
      return result;
  end function;

  -- Call the function to create the input data
  signal IP_DATA : T_IP_TABLE := IP_TABLE_CLEAR;
  signal valid_output, reset_buffer: std_logic := '0';
  
  signal r_out, vr_out: unsigned(31 downto 0);
    
component fft_wrapper is
        Port (
            aclk : IN STD_LOGIC;
            s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_data_tvalid : IN STD_LOGIC;
            s_axis_data_tready : OUT STD_LOGIC;

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
    end component;
    

begin

  -----------------------------------------------------------------------
  -- Instantiate the DUT
  -----------------------------------------------------------------------
  dut : fft_wrapper
  port map (
    aclk                        => aclk,
    s_axis_data_tvalid          => s_axis_data_tvalid,
    s_axis_data_tready          => s_axis_data_tready,
    s_axis_data_tdata           => s_axis_data_tdata,

    r_out => r_out,
    vr_out => vr_out,
    reset_buff => m_axis_data_tlast,
    valid_output => valid_output,

    event_frame_started         => event_frame_started,
    event_tlast_unexpected      => event_tlast_unexpected,
    event_tlast_missing         => event_tlast_missing,
    event_status_channel_halt   => event_status_channel_halt,
    event_data_in_channel_halt  => event_data_in_channel_halt,
    event_data_out_channel_halt => event_data_out_channel_halt
    );

  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------

  clock_gen : process
  begin
    aclk <= '0';
    wait for CLOCK_PERIOD;
    loop
      aclk <= '0';
      wait for CLOCK_PERIOD/2;
      aclk <= '1';
      wait for CLOCK_PERIOD/2;
    end loop;
  end process clock_gen;

  -----------------------------------------------------------------------
  -- Generate data slave channel inputs
  -----------------------------------------------------------------------

  data_stimuli : process

    -- Variables for random number generation
    variable seed1, seed2 : positive;
    variable rand         : real;

    -- Procedure to drive an input sample with specific data
    -- data is the data value to drive on the tdata signal
    -- last is the bit value to drive on the tlast signal
    -- valid_mode defines how to drive TVALID: 0 = TVALID always high, 1 = TVALID low occasionally
    procedure drive_sample ( data       : std_logic_vector(15 downto 0);
                             last       : std_logic;
                             valid_mode : integer := 0 ) is
    begin
      s_axis_data_tdata  <= data;
      s_axis_data_tvalid <= '1';
      loop
        wait until rising_edge(aclk);
        exit when s_axis_data_tready = '1';
      end loop;
      wait for T_HOLD;
      s_axis_data_tvalid <= '0';
    end procedure drive_sample;

    -- Procedure to drive an input frame with a table of data
    -- data is the data table containing input data
    -- valid_mode defines how to drive TVALID: 0 = TVALID always high, 1 = TVALID low occasionally
    procedure drive_frame ( data         : T_IP_TABLE;
                            valid_mode   : integer := 0 ) is
      variable samples : integer;
      variable index   : integer;
      variable sample_data : std_logic_vector(15 downto 0);
      variable sample_last : std_logic;
    begin
      samples := data'length;
      index  := 0;
      while index < data'length loop
        -- Look up sample data in data table, construct TDATA value
        sample_data(7 downto 0)  := data(index).re;                  -- real data
        sample_data(15 downto 8) := data(index).im;                  -- imaginary data
        -- Construct TLAST's value
        index := index + 1;
        if index >= data'length then
          sample_last := '1';
        else
          sample_last := '0';
        end if;
        -- Drive the sample
        drive_sample(sample_data, sample_last, valid_mode);
      end loop;
    end procedure drive_frame;

    variable dummy: integer;

  begin
      dummy := clear_output_file(output_file);
  
      while not endfile(data_in) loop
          -- Drive inputs T_HOLD time after rising edge of clock
          IP_DATA <= create_ip_table_from_file;
          
          wait until rising_edge(aclk);
          wait for T_HOLD;
      
          -- Drive a frame of input data
          drive_frame(IP_DATA);
      
          -- Allow the result to emerge
          wait until m_axis_data_tlast = '1';
          wait until rising_edge(aclk);
          wait for T_HOLD;
      end loop;
    
      -- End of test
      report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
      wait;
  end process data_stimuli;

  -----------------------------------------------------------------------
  -- Assign TDATA / TUSER fields to aliases, for easy simulator waveform viewing
  -----------------------------------------------------------------------
  -- Data slave channel alias signals
  s_axis_data_tdata_re           <= s_axis_data_tdata(7 downto 0);
  s_axis_data_tdata_im           <= s_axis_data_tdata(15 downto 8);

end tb;

