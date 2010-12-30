----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     MailBox
--
-- Description:        
--
-- 
-- Create Date:     19/07/2009
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library MailBox_Lib;
use MailBox_Lib.MailBox_Pack.all;

entity MailBox is
    generic
    (
        GlobalClockFrequency    : integer := 50000000;    -- Fréquence de l'horloge globale
        RTCClockFrequency       : integer := 1000;      -- Fréquence de l'horloge de datation
        WB_Addr_Width           : integer := 4;
        WB_Data_Width           : integer := 32;
        RTC_time_Width          : integer := 16
    );
    port
    (
        wb_clk_i        : in std_logic;
        wb_rst_i        : in std_logic;
        
    -- Settings and Data Read Interface
        wb_we_i_Slave   : in std_logic;
        wb_adr_i_Slave  : in std_logic_vector(WB_Addr_Width + 2 downto 0);
        wb_dat_i_Slave  : in std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_dat_o_Slave  : out std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_cyc_i_Slave  : in std_logic;
        wb_stb_i_Slave  : in std_logic;
        wb_ack_o_Slave  : out std_logic;
        wb_dtr_o_Slave  : out std_logic;    -- Data is available to be read
        wb_atr_o_Slave  : out std_logic_vector(WB_Addr_Width downto 0); -- Address at which Data should be read
        
    -- External Master Interface
        wb_we_o_Master  : out std_logic;
        wb_adr_o_Master : out std_logic_vector(WB_Addr_Width - 1 downto 0);
        wb_dat_o_Master : out std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_dat_i_Master : in std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_cyc_o_Master : out std_logic;
        wb_stb_o_Master : out std_logic;
        wb_ack_i_Master : in std_logic;
        
        RTC_time        : out std_logic_vector(RTC_time_Width - 1 downto 0)
    );
end MailBox;

architecture Behavioral of MailBox is

    signal BlockAddr            : std_logic_vector(1 downto 0);
    
    signal wb_we_Slave_to_Recurrence        : std_logic;
    signal wb_adr_Slave_to_Recurrence       : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Slave_to_Recurrence       : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_dat_Recurrence_to_Slave       : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_cyc_Slave_to_Recurrence       : std_logic;
    signal wb_stb_Slave_to_Recurrence       : std_logic;
    signal wb_ack_Recurrence_to_Slave       : std_logic;
    signal wb_adr_Sequencer_to_Recurrence   : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Recurrence_to_Sequencer   : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_cyc_Sequencer_to_Recurrence   : std_logic;
    signal wb_stb_Sequencer_to_Recurrence   : std_logic;
    signal wb_ack_Recurrence_to_Sequencer   : std_logic;
    signal wb_vld_Recurrence_to_Sequencer   : std_logic;
    
    signal wb_we_Slave_to_Timetable         : std_logic;
    signal wb_adr_Slave_to_Timetable        : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Slave_to_Timetable        : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_dat_Timetable_to_Slave        : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_cyc_Slave_to_Timetable        : std_logic;
    signal wb_stb_Slave_to_Timetable        : std_logic;
    signal wb_ack_Timetable_to_Slave        : std_logic;
    signal wb_we_Sequencer_to_Timetable     : std_logic;
    signal wb_adr_Sequencer_to_Timetable    : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Sequencer_to_Timetable    : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_dat_Timetable_to_Sequencer    : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_cyc_Sequencer_to_Timetable    : std_logic;
    signal wb_stb_Sequencer_to_Timetable    : std_logic;
    signal wb_ack_Timetable_to_Sequencer    : std_logic;
    signal wb_vld_Sequencer_to_Timetable    : std_logic;
    signal wb_vld_Timetable_to_Sequencer    : std_logic;
    
    signal wb_we_Slave_to_DatingTable       : std_logic;
    signal wb_adr_Slave_to_DatingTable      : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Slave_to_DatingTable      : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_dat_DatingTable_to_Slave      : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_cyc_Slave_to_DatingTable      : std_logic;
    signal wb_stb_Slave_to_DatingTable      : std_logic;
    signal wb_ack_DatingTable_to_Slave      : std_logic;
    signal wb_we_Sequencer_to_DatingTable   : std_logic;
    signal wb_adr_Sequencer_to_DatingTable  : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Sequencer_to_DatingTable  : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_cyc_Sequencer_to_DatingTable  : std_logic;
    signal wb_stb_Sequencer_to_DatingTable  : std_logic;
    signal wb_ack_DatingTable_to_Sequencer  : std_logic;
    
    signal wb_we_Slave_to_DataTable         : std_logic;
    signal wb_adr_Slave_to_DataTable        : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Slave_to_DataTable        : std_logic_vector(WB_Data_Width - 1 downto 0);
    signal wb_dat_DataTable_to_Slave        : std_logic_vector(WB_Data_Width - 1 downto 0);
    signal wb_cyc_Slave_to_DataTable        : std_logic;
    signal wb_stb_Slave_to_DataTable        : std_logic;
    signal wb_ack_DataTable_to_Slave        : std_logic;
    signal wb_we_Sequencer_to_DataTable     : std_logic;
    signal wb_adr_Sequencer_to_DataTable    : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_Sequencer_to_DataTable    : std_logic_vector(WB_Data_Width - 1 downto 0);
    signal wb_dat_DataTable_to_Sequencer    : std_logic_vector(WB_Data_Width - 1 downto 0);
    signal wb_cyc_Sequencer_to_DataTable    : std_logic;
    signal wb_stb_Sequencer_to_DataTable    : std_logic;
    signal wb_ack_DataTable_to_Sequencer    : std_logic;
    
    signal wb_we_Sequencer_to_AddrToRead    : std_logic;
    signal wb_dat_Sequencer_to_AddrToRead   : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_cyc_Sequencer_to_AddrToRead   : std_logic;
    signal wb_stb_Sequencer_to_AddrToRead   : std_logic;
    signal wb_ack_AddrToRead_to_Sequencer   : std_logic;
    signal AddrRead                         : std_logic;
    signal AddrToRead                       : std_logic_vector(WB_Addr_Width downto 0);
    signal AddrAvailable                    : std_logic;
    
    signal RTC_time_int : std_logic_vector(RTC_time_Width - 1 downto 0);

begin

--===========================================================================
--         Décodage d'adresses
--===========================================================================

    BlockAddr <= wb_adr_i_Slave(WB_Addr_Width + 2 downto WB_Addr_Width + 1);
     
    -- wb_we_i_Slave
    wb_we_Slave_to_Recurrence   <= wb_we_i_Slave    when BlockAddr = Recurrence_Addr else '0';
    wb_we_Slave_to_Timetable    <= wb_we_i_Slave    when BlockAddr = Timetable_Addr else '0';
    wb_we_Slave_to_DatingTable  <= wb_we_i_Slave    when BlockAddr = DatingTable_Addr else '0';
    wb_we_Slave_to_DataTable    <= wb_we_i_Slave    when BlockAddr = DataTable_Addr else '0';

    -- wb_adr_i_Slave
    wb_adr_Slave_to_Recurrence  <= wb_adr_i_Slave(WB_Addr_Width downto 0);
    wb_adr_Slave_to_Timetable   <= wb_adr_i_Slave(WB_Addr_Width downto 0);
    wb_adr_Slave_to_DatingTable <= wb_adr_i_Slave(WB_Addr_Width downto 0);
    wb_adr_Slave_to_DataTable   <= wb_adr_i_Slave(WB_Addr_Width downto 0);
    
    -- wb_dat_i_Slave
    wb_dat_Slave_to_Recurrence  <= wb_dat_i_Slave(RTC_time_Width - 1 downto 0);
    wb_dat_Slave_to_Timetable   <= wb_dat_i_Slave(RTC_time_Width - 1 downto 0);
    wb_dat_Slave_to_DatingTable <= wb_dat_i_Slave(RTC_time_Width - 1 downto 0);
    wb_dat_Slave_to_DataTable   <= wb_dat_i_Slave;
    
    -- wb_dat_o_Slave
    wb_dat_o_Slave_generate : for i in 0 to WB_Data_Width-1 generate
        wb_dat_o_Slave_if1 : if i < RTC_time_Width generate
            wb_dat_o_Slave(i) <= wb_dat_Recurrence_to_Slave(i)  when BlockAddr = Recurrence_Addr else
                                 wb_dat_Timetable_to_Slave(i)   when BlockAddr = Timetable_Addr else
                                 wb_dat_DatingTable_to_Slave(i) when BlockAddr = DatingTable_Addr else
                                 wb_dat_DataTable_to_Slave(i)   when BlockAddr = DataTable_Addr else
                                 '0';
        end generate;
        wb_dat_o_Slave_if2 : if i >= RTC_time_Width generate
            wb_dat_o_Slave(i) <= '0'                            when BlockAddr = Recurrence_Addr else
                                 '0'                            when BlockAddr = Timetable_Addr else
                                 '0'                            when BlockAddr = DatingTable_Addr else
                                 wb_dat_DataTable_to_Slave(i)   when BlockAddr = DataTable_Addr else
                                 '0';
        end generate;
    end generate wb_dat_o_Slave_generate;
    
    -- wb_cyc_i_Slave
    wb_cyc_Slave_to_Recurrence  <= wb_cyc_i_Slave   when BlockAddr = Recurrence_Addr else '0';
    wb_cyc_Slave_to_Timetable   <= wb_cyc_i_Slave   when BlockAddr = Timetable_Addr else '0';
    wb_cyc_Slave_to_DatingTable <= wb_cyc_i_Slave   when BlockAddr = DatingTable_Addr else '0';
    wb_cyc_Slave_to_DataTable   <= wb_cyc_i_Slave   when BlockAddr = DataTable_Addr else '0';
    
    -- wb_stb_i_Slave
    wb_stb_Slave_to_Recurrence  <= wb_stb_i_Slave   when BlockAddr = Recurrence_Addr else '0';
    wb_stb_Slave_to_Timetable   <= wb_stb_i_Slave   when BlockAddr = Timetable_Addr else '0';
    wb_stb_Slave_to_DatingTable <= wb_stb_i_Slave   when BlockAddr = DatingTable_Addr else '0';
    wb_stb_Slave_to_DataTable   <= wb_stb_i_Slave   when BlockAddr = DataTable_Addr else '0';
    
    -- wb_ack_o_Slave
    wb_ack_o_Slave <= wb_ack_Recurrence_to_Slave    when BlockAddr = Recurrence_Addr else
                      wb_ack_Timetable_to_Slave     when BlockAddr = Timetable_Addr else
                      wb_ack_DatingTable_to_Slave   when BlockAddr = DatingTable_Addr else
                      wb_ack_DataTable_to_Slave     when BlockAddr = DataTable_Addr else
                      '0';

--===========================================================================
--         Instanciation des composants
--===========================================================================

    Recurrence_Table_inst : MailBox_Recurrence
    generic map
    (
        WB_Addr_Width => WB_Addr_Width + 1,
        WB_Data_Width => RTC_time_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_we_i_A => wb_we_Slave_to_Recurrence,
        wb_adr_i_A => wb_adr_Slave_to_Recurrence,
        wb_dat_i_A => wb_dat_Slave_to_Recurrence,
        wb_dat_o_A => wb_dat_Recurrence_to_Slave,
        wb_cyc_i_A => wb_cyc_Slave_to_Recurrence,
        wb_stb_i_A => wb_stb_Slave_to_Recurrence,
        wb_ack_o_A => wb_ack_Recurrence_to_Slave,
        wb_adr_i_B => wb_adr_Sequencer_to_Recurrence,
        wb_dat_o_B => wb_dat_Recurrence_to_Sequencer,
        wb_cyc_i_B => wb_cyc_Sequencer_to_Recurrence,
        wb_stb_i_B => wb_stb_Sequencer_to_Recurrence,
        wb_ack_o_B => wb_ack_Recurrence_to_Sequencer,
        wb_vld_o_B => wb_vld_Recurrence_to_Sequencer
    );

    Timetable_inst : MailBox_Timetable
    generic map
    (
        WB_Addr_Width => WB_Addr_Width + 1,
        WB_Data_Width => RTC_time_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_we_i_A => wb_we_Slave_to_Timetable,
        wb_adr_i_A => wb_adr_Slave_to_Timetable,
        wb_dat_i_A => wb_dat_Slave_to_Timetable,
        wb_dat_o_A => wb_dat_Timetable_to_Slave,
        wb_cyc_i_A => wb_cyc_Slave_to_Timetable,
        wb_stb_i_A => wb_stb_Slave_to_Timetable,
        wb_ack_o_A => wb_ack_Timetable_to_Slave,
        wb_we_i_B => wb_we_Sequencer_to_Timetable,
        wb_adr_i_B => wb_adr_Sequencer_to_Timetable,
        wb_dat_i_B => wb_dat_Sequencer_to_Timetable,
        wb_dat_o_B => wb_dat_Timetable_to_Sequencer,
        wb_cyc_i_B => wb_cyc_Sequencer_to_Timetable,
        wb_stb_i_B => wb_stb_Sequencer_to_Timetable,
        wb_ack_o_B => wb_ack_Timetable_to_Sequencer,
        wb_vld_i_B => wb_vld_Sequencer_to_Timetable,
        wb_vld_o_B => wb_vld_Timetable_to_Sequencer
    );

    DatingTable_inst : MailBox_DualPortRAM
    generic map
    (
        WB_Addr_Width => WB_Addr_Width + 1,
        WB_Data_Width => RTC_time_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_we_i_A => wb_we_Slave_to_DatingTable,
        wb_adr_i_A => wb_adr_Slave_to_DatingTable,
        wb_dat_i_A => wb_dat_Slave_to_DatingTable,
        wb_dat_o_A => wb_dat_DatingTable_to_Slave,
        wb_cyc_i_A => wb_cyc_Slave_to_DatingTable,
        wb_stb_i_A => wb_stb_Slave_to_DatingTable,
        wb_ack_o_A => wb_ack_DatingTable_to_Slave,
        wb_we_i_B => wb_we_Sequencer_to_DatingTable,
        wb_adr_i_B => wb_adr_Sequencer_to_DatingTable,
        wb_dat_i_B => wb_dat_Sequencer_to_DatingTable,
        wb_dat_o_B => open,
        wb_cyc_i_B => wb_cyc_Sequencer_to_DatingTable,
        wb_stb_i_B => wb_stb_Sequencer_to_DatingTable,
        wb_ack_o_B => wb_ack_DatingTable_to_Sequencer
    );

    DataTable_inst : MailBox_DualPortRAM
    generic map
    (
        WB_Addr_Width => WB_Addr_Width + 1,
        WB_Data_Width => WB_Data_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_we_i_A => wb_we_Slave_to_DataTable,
        wb_adr_i_A => wb_adr_Slave_to_DataTable,
        wb_dat_i_A => wb_dat_Slave_to_DataTable,
        wb_dat_o_A => wb_dat_DataTable_to_Slave,
        wb_cyc_i_A => wb_cyc_Slave_to_DataTable,
        wb_stb_i_A => wb_stb_Slave_to_DataTable,
        wb_ack_o_A => wb_ack_DataTable_to_Slave,
        wb_we_i_B => wb_we_Sequencer_to_DataTable,
        wb_adr_i_B => wb_adr_Sequencer_to_DataTable,
        wb_dat_i_B => wb_dat_Sequencer_to_DataTable,
        wb_dat_o_B => wb_dat_DataTable_to_Sequencer,
        wb_cyc_i_B => wb_cyc_Sequencer_to_DataTable,
        wb_stb_i_B => wb_stb_Sequencer_to_DataTable,
        wb_ack_o_B => wb_ack_DataTable_to_Sequencer
    );

    MailBox_AddrToRead_inst : MailBox_AddrToRead
    generic map
    (
        WB_Addr_Width => WB_Addr_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_we_i_Input => wb_we_Sequencer_to_AddrToRead,
        wb_dat_i_Input => wb_dat_Sequencer_to_AddrToRead,
        wb_cyc_i_Input => wb_cyc_Sequencer_to_AddrToRead,
        wb_stb_i_Input => wb_stb_Sequencer_to_AddrToRead,
        wb_ack_o_Input => wb_ack_AddrToRead_to_Sequencer,
        AddrRead => AddrRead,
        AddrToRead => AddrToRead,
        AddrAvailable => AddrAvailable
    );
    AddrRead <= wb_ack_DataTable_to_Slave when AddrAvailable = '1' and wb_we_Slave_to_DataTable = '0' and wb_adr_Slave_to_DataTable = AddrToRead else '0';
    wb_atr_o_Slave <= AddrToRead;
    wb_dtr_o_Slave <= AddrAvailable;

    MailBox_Sequencer_inst : MailBox_Sequencer
    generic map
    (
        WB_Addr_Width => WB_Addr_Width,
        WB_Data_Width => WB_Data_Width,
        RTC_time_Width => RTC_time_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_adr_o_Recurrence => wb_adr_Sequencer_to_Recurrence,
        wb_dat_i_Recurrence => wb_dat_Recurrence_to_Sequencer,
        wb_cyc_o_Recurrence => wb_cyc_Sequencer_to_Recurrence,
        wb_stb_o_Recurrence => wb_stb_Sequencer_to_Recurrence,
        wb_ack_i_Recurrence => wb_ack_Recurrence_to_Sequencer,
        wb_vld_i_Recurrence => wb_vld_Recurrence_to_Sequencer,
        wb_we_o_Timetable => wb_we_Sequencer_to_Timetable,
        wb_adr_o_Timetable => wb_adr_Sequencer_to_Timetable,
        wb_dat_o_Timetable => wb_dat_Sequencer_to_Timetable,
        wb_dat_i_Timetable => wb_dat_Timetable_to_Sequencer,
        wb_cyc_o_Timetable => wb_cyc_Sequencer_to_Timetable,
        wb_stb_o_Timetable => wb_stb_Sequencer_to_Timetable,
        wb_ack_i_Timetable => wb_ack_Timetable_to_Sequencer,
        wb_vld_o_Timetable => wb_vld_Sequencer_to_Timetable,
        wb_vld_i_Timetable => wb_vld_Timetable_to_Sequencer,
        wb_we_o_DatingTable => wb_we_Sequencer_to_DatingTable,
        wb_adr_o_DatingTable => wb_adr_Sequencer_to_DatingTable,
        wb_dat_o_DatingTable => wb_dat_Sequencer_to_DatingTable,
        wb_cyc_o_DatingTable => wb_cyc_Sequencer_to_DatingTable,
        wb_stb_o_DatingTable => wb_stb_Sequencer_to_DatingTable,
        wb_ack_i_DatingTable => wb_ack_DatingTable_to_Sequencer,
        wb_we_o_DataTable => wb_we_Sequencer_to_DataTable,
        wb_adr_o_DataTable => wb_adr_Sequencer_to_DataTable,
        wb_dat_o_DataTable => wb_dat_Sequencer_to_DataTable,
        wb_dat_i_DataTable => wb_dat_DataTable_to_Sequencer,
        wb_cyc_o_DataTable => wb_cyc_Sequencer_to_DataTable,
        wb_stb_o_DataTable => wb_stb_Sequencer_to_DataTable,
        wb_ack_i_DataTable => wb_ack_DataTable_to_Sequencer,
        wb_we_o_AddrToRead => wb_we_Sequencer_to_AddrToRead,
        wb_dat_o_AddrToRead => wb_dat_Sequencer_to_AddrToRead,
        wb_cyc_o_AddrToRead => wb_cyc_Sequencer_to_AddrToRead,
        wb_stb_o_AddrToRead => wb_stb_Sequencer_to_AddrToRead,
        wb_ack_i_AddrToRead => wb_ack_AddrToRead_to_Sequencer,
        wb_we_o_Master => wb_we_o_Master,
        wb_adr_o_Master => wb_adr_o_Master,
        wb_dat_o_Master => wb_dat_o_Master,
        wb_dat_i_Master => wb_dat_i_Master,
        wb_cyc_o_Master => wb_cyc_o_Master,
        wb_stb_o_Master => wb_stb_o_Master,
        wb_ack_i_Master => wb_ack_i_Master,
        RTC_time => RTC_time_int
    );
    
    MailBox_RTC_inst : MailBox_RTC
    generic map
    (
        GlobalClockFrequency => GlobalClockFrequency,
        RTCClockFrequency => RTCClockFrequency,
        RTC_time_Width => RTC_time_Width
    )
    port map
    (
        clk => wb_clk_i,
        rst => wb_rst_i,
        RTC_time => RTC_time_int
    );
    RTC_time <= RTC_time_int;

end Behavioral;