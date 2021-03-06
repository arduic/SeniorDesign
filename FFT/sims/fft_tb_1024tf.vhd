library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

library work;
use work.config.all;

entity fft_tb is
end fft_tb;

architecture Behavioral of fft_tb is

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
    
    -- Config slave channel signals
    signal s_axis_config_tvalid        : std_logic := '0';  -- payload is valid
    signal s_axis_config_tready        : std_logic := '1';  -- slave is ready
    signal s_axis_config_tdata         : std_logic_vector(15 downto 0) := (others => '0');  -- data payload
    
    -- Data slave channel signals
    signal s_axis_data_tvalid          : std_logic := '0';  -- payload is valid
    signal s_axis_data_tready          : std_logic := '1';  -- slave is ready
    signal s_axis_data_tdata           : std_logic_vector(15 downto 0) := (others => '0');  -- data payload
    signal s_axis_data_tlast           : std_logic := '0';  -- indicates end of packet
    
    -- Data master channel signals
    signal m_axis_data_tvalid          : std_logic := '0';  -- payload is valid
    signal m_axis_data_tready          : std_logic := '1';  -- slave is ready
    signal m_axis_data_tdata           : std_logic_vector(15 downto 0) := (others => '0');  -- data payload
    signal m_axis_data_tuser           : std_logic_vector(15 downto 0) := (others => '0');  -- user-defined payload
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
    
    -- Config slave channel alias signals
    signal s_axis_config_tdata_fwd_inv      : std_logic                    := '0';              -- forward or inverse
    signal s_axis_config_tdata_scale_sch    : std_logic_vector(9 downto 0) := (others => '0');  -- scaling schedule
    
    -- Data slave channel alias signals
    signal s_axis_data_tdata_re             : std_logic_vector(7 downto 0) := (others => '0');  -- real data
    signal s_axis_data_tdata_im             : std_logic_vector(7 downto 0) := (others => '0');  -- imaginary data
    
    -- Data master channel alias signals
    signal m_axis_data_tdata_re             : std_logic_vector(7 downto 0) := (others => '0');  -- real data
    signal m_axis_data_tdata_im             : std_logic_vector(7 downto 0) := (others => '0');  -- imaginary data
    signal m_axis_data_tuser_xk_index       : std_logic_vector(9 downto 0) := (others => '0');  -- sample index
    
    file data_in: text open read_mode is input_file;

    -----------------------------------------------------------------------
    -- Constants, types and functions to create input data
    -----------------------------------------------------------------------
    
    constant IP_WIDTH    : integer := 8;
    constant MAX_SAMPLES : integer := 2**10;  -- maximum number of samples in a frame
    type T_IP_SAMPLE is record
        re : std_logic_vector(IP_WIDTH-1 downto 0);
        im : std_logic_vector(IP_WIDTH-1 downto 0);
    end record;
    type T_IP_TABLE is array (0 to MAX_SAMPLES-1) of T_IP_SAMPLE;
    
    type T_MAG_TABLE is array (0 to MAX_SAMPLES-1) of integer;
    
    -- Zeroed input data table, for reset and initialization
    constant IP_TABLE_CLEAR : T_IP_TABLE := (others => (re => (others => '0'),
                                                      im => (others => '0')));
    constant MAG_TABLE_CLEAR: T_MAG_TABLE := (others => 0);

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
    
    impure function clear_output_file(dest_file: string) return integer is
        file data_out: text open write_mode is dest_file;
    begin
        return 0;
    end function;

    -- Function to record output to a file
    -- Return type should be void, but I don't know how to make a void function in vhdl
    -- mag = sqrt(actual(start:end_, 1).^2 + actual(start:end_, 2).^2);
    impure function record_master_output(data: T_IP_TABLE; dest_file: string) return integer is
        file data_out: text open append_mode is dest_file;
        constant sep: string := " ";
        variable output_line: line;
        
        variable samples : integer;
        variable index   : integer;
        variable re, im: std_logic_vector(ip_width-1 downto 0);
    begin
        samples := data'length;
        index  := 0;
        while index < data'length loop
            -- Look up sample data in data table, construct TDATA value
            re := data(index).re;
            im := data(index).im;
            
            -- Construct TLAST's value
            index := index + 1;
            
            write(output_line, integer'image(to_integer(signed(re))));
            write(output_line, sep);
            write(output_line, integer'image(to_integer(signed(im))));
            writeline(data_out, output_line);
        end loop;
        return 0;
    end function;
    
    -- Create the input data
--    constant IP_DATA: T_IP_TABLE := create_ip_table_from_file;
    signal IP_DATA: T_IP_TABLE := IP_TABLE_CLEAR;
    signal MAG_DATA: T_MAG_TABLE := MAG_TABLE_CLEAR;
    signal max_mag: integer := 0;
    signal max_mag_i: integer := 0;
    signal max_freq: integer := 0;

    -----------------------------------------------------------------------
    -- Testbench signals
    -----------------------------------------------------------------------
    
    -- Communication between processes regarding DUT configuration
    type T_DO_CONFIG is (NONE, IMMEDIATE, AFTER_START, DONE);
    shared variable do_config : T_DO_CONFIG := NONE;  -- instruction for driving config slave channel
    type T_CFG_FWD_INV is (FWD, INV);
    signal cfg_fwd_inv : T_CFG_FWD_INV := FWD;
    type T_CFG_SCALE_SCH is (ZERO, DEFAULT);
    signal cfg_scale_sch : T_CFG_SCALE_SCH := DEFAULT;
    
    -- Recording output data, for reuse as input data
    signal ip_frame        : integer    := 0;    -- input / configuration frame number
    signal op_data         : T_IP_TABLE := IP_TABLE_CLEAR;  -- recorded output data
    signal op_frame        : integer    := 0;    -- output frame number (incremented at end of frame output)

begin

    max_freq <= FREQ_SPEC(max_mag_i);

    -----------------------------------------------------------------------
    -- Instantiate the DUT
    -----------------------------------------------------------------------
    
    dut : entity work.xfft_0
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
        s_axis_data_tlast  <= last;
  
        if valid_mode = 1 then
          uniform(seed1, seed2, rand);  -- generate random number
          if rand < 0.25 then
            s_axis_data_tvalid <= '0';
            uniform(seed1, seed2, rand);  -- generate another random number
            wait for CLOCK_PERIOD * integer(round(rand * 4.0));  -- hold TVALID low for up to 4 cycles
            s_axis_data_tvalid <= '1';  -- now assert TVALID
          else
            s_axis_data_tvalid <= '1';
          end if;
        else
          s_axis_data_tvalid <= '1';
        end if;
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
  
      variable op_data_saved : T_IP_TABLE;  -- to save a copy of recorded output data
      variable dummy: integer;
  
    begin
      dummy := clear_output_file(output_file);
      
      while not endfile(data_in) loop
          -- Drive inputs T_HOLD time after rising edge of clock
          IP_DATA <= create_ip_table_from_file;
          
          wait until rising_edge(aclk);
          wait for T_HOLD;
      
          -- Drive a frame of input data
          ip_frame <= 1;
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
    -- Generate config slave channel inputs
    -----------------------------------------------------------------------
  
    config_stimuli : process
      variable scale_sch : std_logic_vector(9 downto 0);
    begin
  
      -- Drive a configuration when requested by data_stimuli process
      wait until rising_edge(aclk);
      while do_config = NONE or do_config = DONE loop
        wait until rising_edge(aclk);
      end loop;
  
      -- If the configuration is requested to occur after the next frame starts, wait for that event
      if do_config = AFTER_START then
        wait until event_frame_started = '1';
        wait until rising_edge(aclk);
      end if;
  
      -- Drive inputs T_HOLD time after rising edge of clock
      wait for T_HOLD;
  
      -- Construct the config slave channel TDATA signal
      s_axis_config_tdata <= (others => '0');  -- clear unused bits
      -- Format the transform direction
      if cfg_fwd_inv = FWD then
        s_axis_config_tdata(0) <= '1';  -- forward
      elsif cfg_fwd_inv = INV then
        s_axis_config_tdata(0) <= '0';  -- inverse
      end if;
      -- Format the scaling schedule
      if cfg_scale_sch = ZERO then  -- no scaling
        scale_sch := (others => '0');
      elsif cfg_scale_sch = DEFAULT then  -- default scaling, for largest magnitude output with no overflow guaranteed
        scale_sch(1 downto 0) := "11";  -- largest scaling at first stage
        for s in 2 to 5 loop
          scale_sch(s*2-1 downto s*2-2) := "10";  -- less scaling at later stages
        end loop;
      end if;
      s_axis_config_tdata(10 downto 1) <= scale_sch;
  
      -- Drive the transaction on the config slave channel
      s_axis_config_tvalid <= '1';
      loop
        wait until rising_edge(aclk);
        exit when s_axis_config_tready = '1';
      end loop;
      wait for T_HOLD;
      s_axis_config_tvalid <= '0';
  
      -- Tell the data_stimuli process that the configuration has been done
      do_config := DONE;
  
    end process config_stimuli;

  -----------------------------------------------------------------------
  -- Record outputs, to use later as inputs for another frame
  -----------------------------------------------------------------------

  record_outputs : process (aclk)
    variable index : integer := 0;
    variable re_v, im_v: std_logic_vector(ip_width-1 downto 0);
    variable re_i, im_i, mag: integer;
    variable dummy: integer;
  begin
    if rising_edge(aclk) then
      if m_axis_data_tvalid = '1' and m_axis_data_tready = '1' then
        -- Record output data such that it can be used as input data
        -- Output sample index is given by xk_index field of m_axis_data_tuser
        index := to_integer(unsigned(m_axis_data_tuser(9 downto 0)));
        
        re_v := m_axis_data_tdata(7 downto 0);
        im_v := m_axis_data_tdata(15 downto 8);
        re_i := to_integer(signed(re_v));
        im_i := to_integer(signed(im_v));
        
        mag := re_i*re_i + im_i*im_i;
        mag_data(index) <= mag;
        if mag > max_mag then
            max_mag <= mag;
            max_mag_i <= index;
        end if;
        
        op_data(index).re <= re_v;
        op_data(index).im <= im_v;
        -- Track the number of output frames
        if m_axis_data_tlast = '1' then  -- end of output frame: increment frame counter
          op_frame <= op_frame + 1;
          dummy := record_master_output(op_data, output_file);  -- I do not know how to declare a void func in vhdl
        end if;
      end if;
    end if;
  end process record_outputs;

  -----------------------------------------------------------------------
  -- Check outputs
  -----------------------------------------------------------------------

  check_outputs : process
    variable check_ok : boolean := true;
    -- Previous values of data master channel signals
    variable m_data_tvalid_prev : std_logic := '0';
    variable m_data_tready_prev : std_logic := '0';
    variable m_data_tdata_prev  : std_logic_vector(15 downto 0) := (others => '0');
    variable m_data_tuser_prev  : std_logic_vector(15 downto 0) := (others => '0');
  begin

    -- Check outputs T_STROBE time after rising edge of clock
    wait until rising_edge(aclk);
    wait for T_STROBE;

    -- Do not check the output payload values, as this requires a numerical model
    -- which would make this demonstration testbench unwieldy.
    -- Instead, check the protocol of the data master channel:
    -- check that the payload is valid (not X) when TVALID is high
    -- and check that the payload does not change while TVALID is high until TREADY goes high

    if m_axis_data_tvalid = '1' then
      if is_x(m_axis_data_tdata) then
        report "ERROR: m_axis_data_tdata is invalid when m_axis_data_tvalid is high" severity error;
        check_ok := false;
      end if;
      if is_x(m_axis_data_tuser) then
        report "ERROR: m_axis_data_tuser is invalid when m_axis_data_tvalid is high" severity error;
        check_ok := false;
      end if;

      if m_data_tvalid_prev = '1' and m_data_tready_prev = '0' then  -- payload must be the same as last cycle
        if m_axis_data_tdata /= m_data_tdata_prev then
          report "ERROR: m_axis_data_tdata changed while m_axis_data_tvalid was high and m_axis_data_tready was low" severity error;
          check_ok := false;
        end if;
        if m_axis_data_tuser /= m_data_tuser_prev then
          report "ERROR: m_axis_data_tuser changed while m_axis_data_tvalid was high and m_axis_data_tready was low" severity error;
          check_ok := false;
        end if;
      end if;

    end if;

    assert check_ok
      report "ERROR: terminating test with failures." severity failure;

    -- Record payload values for checking next clock cycle
    if check_ok then
      m_data_tvalid_prev  := m_axis_data_tvalid;
      m_data_tready_prev  := m_axis_data_tready;
      m_data_tdata_prev   := m_axis_data_tdata;
      m_data_tuser_prev   := m_axis_data_tuser;
    end if;

  end process check_outputs;

  -----------------------------------------------------------------------
  -- Assign TDATA / TUSER fields to aliases, for easy simulator waveform viewing
  -----------------------------------------------------------------------

  -- Config slave channel alias signals
  s_axis_config_tdata_fwd_inv    <= s_axis_config_tdata(0);
  s_axis_config_tdata_scale_sch  <= s_axis_config_tdata(10 downto 1);

  -- Data slave channel alias signals
  s_axis_data_tdata_re           <= s_axis_data_tdata(7 downto 0);
  s_axis_data_tdata_im           <= s_axis_data_tdata(15 downto 8);

  -- Data master channel alias signals
  m_axis_data_tdata_re           <= m_axis_data_tdata(7 downto 0);
  m_axis_data_tdata_im           <= m_axis_data_tdata(15 downto 8);
  m_axis_data_tuser_xk_index     <= m_axis_data_tuser(9 downto 0);

end Behavioral;
