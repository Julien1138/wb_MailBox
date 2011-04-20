----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox
--
-- Description:      
--
-- 
-- Create Date:    19/07/2009
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
      g_RTCClockPeriode : std_logic_vector := X"C350" -- Durée d'une période de l'horloge de datation
   );
   port
   (
      wb_clk_i          : in std_logic;
      wb_rst_i          : in std_logic;
      
   -- Settings and Data Read Interface
      wb_we_User_i      : in std_logic;
      wb_adr_User_i     : in std_logic_vector;
      wb_dat_User_i     : in std_logic_vector;
      wb_dat_User_o     : out std_logic_vector;
      wb_cyc_User_i     : in std_logic;
      wb_stb_User_i     : in std_logic;
      wb_ack_User_o     : out std_logic;
   
   -- New Data updated in the MailBox
      DataAvailable_o   : out std_logic;   -- Data is available to be read
      AddrToRead_o      : out std_logic_vector; -- Address at which Data should be read
      
   -- External Master Interface
      wb_we_Master_o    : out std_logic;
      wb_adr_Master_o   : out std_logic_vector;
      wb_dat_Master_i   : in std_logic_vector;
      wb_dat_Master_o   : out std_logic_vector;
      wb_cyc_Master_o   : out std_logic;
      wb_stb_Master_o   : out std_logic;
      wb_ack_Master_i   : in std_logic;
   
   -- External trigger interface
      ExtTrigger_i      : in std_logic_vector;
      
   -- RTC value
      RTCTime_o         : out std_logic_vector
   );
end MailBox;

architecture Behavioral of MailBox is

   signal s_BlockAddr         : std_logic_vector(1 downto 0);
   
   signal s_wb_we_UserToRecurrence      : std_logic;
   signal s_wb_adr_UserToRecurrence      : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_UserToRecurrence      : std_logic_vector(RTCTime_o'range);
   signal s_wb_dat_RecurrenceToUser      : std_logic_vector(RTCTime_o'range);
   signal s_wb_cyc_UserToRecurrence      : std_logic;
   signal s_wb_stb_UserToRecurrence      : std_logic;
   signal s_wb_ack_RecurrenceToUser      : std_logic;
   signal s_wb_adr_SequencerToRecurrence   : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_RecurrenceToSequencer   : std_logic_vector(RTCTime_o'range);
   signal s_wb_cyc_SequencerToRecurrence   : std_logic;
   signal s_wb_stb_SequencerToRecurrence   : std_logic;
   signal s_wb_ack_RecurrenceToSequencer   : std_logic;
   signal s_wb_vld_RecurrenceToSequencer   : std_logic;
   
   signal s_wb_we_UserToTimetable       : std_logic;
   signal s_wb_adr_UserToTimetable      : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_UserToTimetable      : std_logic_vector(RTCTime_o'range);
   signal s_wb_dat_TimetableToUser      : std_logic_vector(RTCTime_o'range);
   signal s_wb_cyc_UserToTimetable      : std_logic;
   signal s_wb_stb_UserToTimetable      : std_logic;
   signal s_wb_ack_TimetableToUser      : std_logic;
   signal s_wb_we_SequencerToTimetable    : std_logic;
   signal s_wb_adr_SequencerToTimetable   : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_SequencerToTimetable   : std_logic_vector(RTCTime_o'range);
   signal s_wb_dat_TimetableToSequencer   : std_logic_vector(RTCTime_o'range);
   signal s_wb_cyc_SequencerToTimetable   : std_logic;
   signal s_wb_stb_SequencerToTimetable   : std_logic;
   signal s_wb_ack_TimetableToSequencer   : std_logic;
   signal s_wb_vld_SequencerToTimetable   : std_logic;
   signal s_wb_vld_TimetableToSequencer   : std_logic;
   
   signal s_wb_we_UserToDatingTable      : std_logic;
   signal s_wb_adr_UserToDatingTable     : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_UserToDatingTable     : std_logic_vector(RTCTime_o'range);
   signal s_wb_dat_DatingTableToUser     : std_logic_vector(RTCTime_o'range);
   signal s_wb_cyc_UserToDatingTable     : std_logic;
   signal s_wb_stb_UserToDatingTable     : std_logic;
   signal s_wb_ack_DatingTableToUser     : std_logic;
   signal s_wb_we_SequencerToDatingTable   : std_logic;
   signal s_wb_adr_SequencerToDatingTable  : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_SequencerToDatingTable  : std_logic_vector(RTCTime_o'range);
   signal s_wb_dat_DatingTableToSequencer  : std_logic_vector(RTCTime_o'range);  -- Dummy vector
   signal s_wb_cyc_SequencerToDatingTable  : std_logic;
   signal s_wb_stb_SequencerToDatingTable  : std_logic;
   signal s_wb_ack_DatingTableToSequencer  : std_logic;
   
   signal s_wb_we_UserToDataTable       : std_logic;
   signal s_wb_adr_UserToDataTable      : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_UserToDataTable      : std_logic_vector(wb_dat_Master_o'range);
   signal s_wb_dat_DataTableToUser      : std_logic_vector(wb_dat_Master_o'range);
   signal s_wb_cyc_UserToDataTable      : std_logic;
   signal s_wb_stb_UserToDataTable      : std_logic;
   signal s_wb_ack_DataTableToUser      : std_logic;
   signal s_wb_we_SequencerToDataTable    : std_logic;
   signal s_wb_adr_SequencerToDataTable   : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_dat_SequencerToDataTable   : std_logic_vector(wb_dat_Master_o'range);
   signal s_wb_dat_DataTableToSequencer   : std_logic_vector(wb_dat_Master_o'range);
   signal s_wb_cyc_SequencerToDataTable   : std_logic;
   signal s_wb_stb_SequencerToDataTable   : std_logic;
   signal s_wb_ack_DataTableToSequencer   : std_logic;
   
   signal s_wb_we_SequencerToAddrToRead   : std_logic;
   signal s_wb_dat_SequencerToAddrToRead   : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_wb_cyc_SequencerToAddrToRead   : std_logic;
   signal s_wb_stb_SequencerToAddrToRead   : std_logic;
   signal s_wb_ack_AddrToReadToSequencer   : std_logic;
   signal s_AddrRead                   : std_logic;
   signal s_AddrToRead                  : std_logic_vector(wb_adr_Master_o'high + 1 downto 0);
   signal s_AddrAvailable               : std_logic;
   
   signal s_RTCTime : std_logic_vector(RTCTime_o'range);

begin

--===========================================================================
--       Assertions
--===========================================================================
   
   assert wb_dat_User_i'length   = wb_dat_User_o'length
      and wb_dat_User_o'length   = wb_dat_Master_o'length
      and wb_dat_Master_o'length = wb_dat_Master_i'length
      report "All Data buses shall have the same size"
      severity failure;
   
   assert RTCTime_o'length <= wb_dat_Master_o'length
      report "RTC bus size shall be smaller or equal to Data bus"
      severity failure;
   
   assert wb_adr_User_i'length = wb_adr_Master_o'length + 3
      report "User Address bus size shall be equal to Master Address bus + 3"
      severity failure;
   
   assert ExtTrigger_i'length = 2**wb_adr_Master_o'length
      report "External trigger bus does not match Address Bus"
      severity failure;
      
--===========================================================================
--       Décodage d'adresses
--===========================================================================

   s_BlockAddr <= wb_adr_User_i(wb_adr_Master_o'high + 3 downto wb_adr_Master_o'high + 2);
    
   -- wb_we_User_i
   s_wb_we_UserToRecurrence  <= wb_we_User_i;
   s_wb_we_UserToTimetable   <= wb_we_User_i;
   s_wb_we_UserToDatingTable <= wb_we_User_i;
   s_wb_we_UserToDataTable   <= wb_we_User_i;

   -- wb_adr_User_i
   s_wb_adr_UserToRecurrence    <= wb_adr_User_i(s_wb_adr_UserToRecurrence'range);
   s_wb_adr_UserToTimetable     <= wb_adr_User_i(s_wb_adr_UserToTimetable'range);
   s_wb_adr_UserToDatingTable   <= wb_adr_User_i(s_wb_adr_UserToDatingTable'range);
   s_wb_adr_UserToDataTable     <= wb_adr_User_i(s_wb_adr_UserToDataTable'range);
   
   -- wb_dat_User_i
   s_wb_dat_UserToRecurrence  <= wb_dat_User_i(s_wb_dat_UserToRecurrence'range);
   s_wb_dat_UserToTimetable   <= wb_dat_User_i(s_wb_dat_UserToTimetable'range);
   s_wb_dat_UserToDatingTable <= wb_dat_User_i(s_wb_dat_UserToDatingTable'range);
   s_wb_dat_UserToDataTable   <= wb_dat_User_i;
   
   -- wb_dat_User_o
   wb_dat_User_o_generate : for i in wb_dat_User_i'range generate
      wb_dat_User_o_if1 : if i < RTCTime_o'high generate
         wb_dat_User_o(i) <= s_wb_dat_RecurrenceToUser(i)   when s_BlockAddr = c_Recurrence_Addr   else
                             s_wb_dat_TimetableToUser(i)    when s_BlockAddr = c_Timetable_Addr    else
                             s_wb_dat_DatingTableToUser(i)  when s_BlockAddr = c_DatingTable_Addr  else
                             s_wb_dat_DataTableToUser(i)    when s_BlockAddr = c_DataTable_Addr    else
                             '0';
      end generate;
      wb_dat_User_o_if2 : if i >= RTCTime_o'high generate
         wb_dat_User_o(i) <= '0'                         when s_BlockAddr = c_Recurrence_Addr   else
                             '0'                         when s_BlockAddr = c_Timetable_Addr    else
                             '0'                         when s_BlockAddr = c_DatingTable_Addr  else
                             s_wb_dat_DataTableToUser(i) when s_BlockAddr = c_DataTable_Addr    else
                             '0';
      end generate;
   end generate wb_dat_User_o_generate;
   
   -- wb_cyc_User_i
   s_wb_cyc_UserToRecurrence  <= wb_cyc_User_i;
   s_wb_cyc_UserToTimetable   <= wb_cyc_User_i;
   s_wb_cyc_UserToDatingTable <= wb_cyc_User_i;
   s_wb_cyc_UserToDataTable   <= wb_cyc_User_i;
   
   -- wb_stb_User_i
   s_wb_stb_UserToRecurrence  <= wb_stb_User_i when s_BlockAddr = c_Recurrence_Addr    else '0';
   s_wb_stb_UserToTimetable   <= wb_stb_User_i when s_BlockAddr = c_Timetable_Addr     else '0';
   s_wb_stb_UserToDatingTable <= wb_stb_User_i when s_BlockAddr = c_DatingTable_Addr   else '0';
   s_wb_stb_UserToDataTable   <= wb_stb_User_i when s_BlockAddr = c_DataTable_Addr     else '0';
   
   -- wb_ack_User_o
   wb_ack_User_o <= s_wb_ack_RecurrenceToUser
                 or s_wb_ack_TimetableToUser
                 or s_wb_ack_DatingTableToUser
                 or s_wb_ack_DataTableToUser;

--===========================================================================
--       Instanciation des composants
--===========================================================================

   Recurrence_Table_inst : MailBox_Recurrence
   port map
   (
      wb_clk_i       => wb_clk_i,
      wb_rst_i       => wb_rst_i,
      wb_we_usr_i    => s_wb_we_UserToRecurrence,
      wb_adr_usr_i   => s_wb_adr_UserToRecurrence,
      wb_dat_usr_i   => s_wb_dat_UserToRecurrence,
      wb_dat_usr_o   => s_wb_dat_RecurrenceToUser,
      wb_cyc_usr_i   => s_wb_cyc_UserToRecurrence,
      wb_stb_usr_i   => s_wb_stb_UserToRecurrence,
      wb_ack_usr_o   => s_wb_ack_RecurrenceToUser,
      wb_adr_seq_i   => s_wb_adr_SequencerToRecurrence,
      wb_dat_seq_o   => s_wb_dat_RecurrenceToSequencer,
      wb_cyc_seq_i   => s_wb_cyc_SequencerToRecurrence,
      wb_stb_seq_i   => s_wb_stb_SequencerToRecurrence,
      wb_ack_seq_o   => s_wb_ack_RecurrenceToSequencer,
      wb_vld_seq_o   => s_wb_vld_RecurrenceToSequencer
   );

   Timetable_inst : MailBox_Timetable
   port map
   (
      wb_clk_i       => wb_clk_i,
      wb_rst_i       => wb_rst_i,
      wb_we_usr_i    => s_wb_we_UserToTimetable,
      wb_adr_usr_i   => s_wb_adr_UserToTimetable,
      wb_dat_usr_i   => s_wb_dat_UserToTimetable,
      wb_dat_usr_o   => s_wb_dat_TimetableToUser,
      wb_cyc_usr_i   => s_wb_cyc_UserToTimetable,
      wb_stb_usr_i   => s_wb_stb_UserToTimetable,
      wb_ack_usr_o   => s_wb_ack_TimetableToUser,
      wb_we_seq_i    => s_wb_we_SequencerToTimetable,
      wb_adr_seq_i   => s_wb_adr_SequencerToTimetable,
      wb_dat_seq_i   => s_wb_dat_SequencerToTimetable,
      wb_dat_seq_o   => s_wb_dat_TimetableToSequencer,
      wb_cyc_seq_i   => s_wb_cyc_SequencerToTimetable,
      wb_stb_seq_i   => s_wb_stb_SequencerToTimetable,
      wb_ack_seq_o   => s_wb_ack_TimetableToSequencer,
      wb_vld_seq_i   => s_wb_vld_SequencerToTimetable,
      wb_vld_seq_o   => s_wb_vld_TimetableToSequencer
   );

   DatingTable_inst : MailBox_DualPortRAM
   port map
   (
      wb_clk_i    => wb_clk_i,
      wb_rst_i    => wb_rst_i,
      wb_we_A_i   => s_wb_we_UserToDatingTable,
      wb_adr_A_i  => s_wb_adr_UserToDatingTable,
      wb_dat_A_i  => s_wb_dat_UserToDatingTable,
      wb_dat_A_o  => s_wb_dat_DatingTableToUser,
      wb_cyc_A_i  => s_wb_cyc_UserToDatingTable,
      wb_stb_A_i  => s_wb_stb_UserToDatingTable,
      wb_ack_A_o  => s_wb_ack_DatingTableToUser,
      wb_we_B_i   => s_wb_we_SequencerToDatingTable,
      wb_adr_B_i  => s_wb_adr_SequencerToDatingTable,
      wb_dat_B_i  => s_wb_dat_SequencerToDatingTable,
      wb_dat_B_o  => s_wb_dat_DatingTableToSequencer,
      wb_cyc_B_i  => s_wb_cyc_SequencerToDatingTable,
      wb_stb_B_i  => s_wb_stb_SequencerToDatingTable,
      wb_ack_B_o  => s_wb_ack_DatingTableToSequencer
   );

   DataTable_inst : MailBox_DualPortRAM
   port map
   (
      wb_clk_i    => wb_clk_i,
      wb_rst_i    => wb_rst_i,
      wb_we_A_i   => s_wb_we_UserToDataTable,
      wb_adr_A_i  => s_wb_adr_UserToDataTable,
      wb_dat_A_i  => s_wb_dat_UserToDataTable,
      wb_dat_A_o  => s_wb_dat_DataTableToUser,
      wb_cyc_A_i  => s_wb_cyc_UserToDataTable,
      wb_stb_A_i  => s_wb_stb_UserToDataTable,
      wb_ack_A_o  => s_wb_ack_DataTableToUser,
      wb_we_B_i   => s_wb_we_SequencerToDataTable,
      wb_adr_B_i  => s_wb_adr_SequencerToDataTable,
      wb_dat_B_i  => s_wb_dat_SequencerToDataTable,
      wb_dat_B_o  => s_wb_dat_DataTableToSequencer,
      wb_cyc_B_i  => s_wb_cyc_SequencerToDataTable,
      wb_stb_B_i  => s_wb_stb_SequencerToDataTable,
      wb_ack_B_o  => s_wb_ack_DataTableToSequencer
   );

   MailBox_AddrToRead_inst : MailBox_AddrToRead
   port map
   (
      wb_clk_i    => wb_clk_i,
      wb_rst_i    => wb_rst_i,
      wb_we_i     => s_wb_we_SequencerToAddrToRead,
      wb_dat_i    => s_wb_dat_SequencerToAddrToRead,
      wb_cyc_i    => s_wb_cyc_SequencerToAddrToRead,
      wb_stb_i    => s_wb_stb_SequencerToAddrToRead,
      wb_ack_o    => s_wb_ack_AddrToReadToSequencer,
      Read_i      => s_AddrRead,
      Addr_o      => s_AddrToRead,
      AddrAvail_o => s_AddrAvailable
   );
   s_AddrRead <= s_wb_ack_DataTableToUser when s_AddrAvailable = '1' and s_wb_we_UserToDataTable = '0' and s_wb_adr_UserToDataTable = s_AddrToRead else '0';
   AddrToRead_o <= s_AddrToRead;
   DataAvailable_o <= s_AddrAvailable;

   MailBox_Sequencer_inst : MailBox_Sequencer
   port map
   (
      wb_clk_i             => wb_clk_i,
      wb_rst_i             => wb_rst_i,
      
      wb_we_Timetable_o    => s_wb_we_SequencerToTimetable,
      wb_adr_Timetable_o   => s_wb_adr_SequencerToTimetable,
      wb_dat_Timetable_o   => s_wb_dat_SequencerToTimetable,
      wb_dat_Timetable_i   => s_wb_dat_TimetableToSequencer,
      wb_cyc_Timetable_o   => s_wb_cyc_SequencerToTimetable,
      wb_stb_Timetable_o   => s_wb_stb_SequencerToTimetable,
      wb_ack_Timetable_i   => s_wb_ack_TimetableToSequencer,
      wb_vld_Timetable_o   => s_wb_vld_SequencerToTimetable,
      wb_vld_Timetable_i   => s_wb_vld_TimetableToSequencer,
      
      wb_adr_Recurrence_o  => s_wb_adr_SequencerToRecurrence,
      wb_dat_Recurrence_i  => s_wb_dat_RecurrenceToSequencer,
      wb_cyc_Recurrence_o  => s_wb_cyc_SequencerToRecurrence,
      wb_stb_Recurrence_o  => s_wb_stb_SequencerToRecurrence,
      wb_ack_Recurrence_i  => s_wb_ack_RecurrenceToSequencer,
      wb_vld_Recurrence_i  => s_wb_vld_RecurrenceToSequencer,
      
      wb_we_DatingTable_o  => s_wb_we_SequencerToDatingTable,
      wb_adr_DatingTable_o => s_wb_adr_SequencerToDatingTable,
      wb_dat_DatingTable_o => s_wb_dat_SequencerToDatingTable,
      wb_cyc_DatingTable_o => s_wb_cyc_SequencerToDatingTable,
      wb_stb_DatingTable_o => s_wb_stb_SequencerToDatingTable,
      wb_ack_DatingTable_i => s_wb_ack_DatingTableToSequencer,
      
      wb_we_DataTable_o    => s_wb_we_SequencerToDataTable,
      wb_adr_DataTable_o   => s_wb_adr_SequencerToDataTable,
      wb_dat_DataTable_o   => s_wb_dat_SequencerToDataTable,
      wb_dat_DataTable_i   => s_wb_dat_DataTableToSequencer,
      wb_cyc_DataTable_o   => s_wb_cyc_SequencerToDataTable,
      wb_stb_DataTable_o   => s_wb_stb_SequencerToDataTable,
      wb_ack_DataTable_i   => s_wb_ack_DataTableToSequencer,
      
      wb_we_AddrToRead_o   => s_wb_we_SequencerToAddrToRead,
      wb_dat_AddrToRead_o  => s_wb_dat_SequencerToAddrToRead,
      wb_cyc_AddrToRead_o  => s_wb_cyc_SequencerToAddrToRead,
      wb_stb_AddrToRead_o  => s_wb_stb_SequencerToAddrToRead,
      wb_ack_AddrToRead_i  => s_wb_ack_AddrToReadToSequencer,
      
      wb_we_Master_o       => wb_we_Master_o,
      wb_adr_Master_o      => wb_adr_Master_o,
      wb_dat_Master_o      => wb_dat_Master_o,
      wb_dat_Master_i      => wb_dat_Master_i,
      wb_cyc_Master_o      => wb_cyc_Master_o,
      wb_stb_Master_o      => wb_stb_Master_o,
      wb_ack_Master_i      => wb_ack_Master_i,
      
      RTCTime_i            => s_RTCTime,
      
      Trigger_i            => ExtTrigger_i
   );
   
   MailBox_RTC_inst : MailBox_RTC
   generic map
   (
      g_RTCClockPeriode => g_RTCClockPeriode
   )
   port map
   (
      clk_i       => wb_clk_i,
      rst_i       => wb_rst_i,
      RTC_time_o  => s_RTCTime
   );
   RTCTime_o <= s_RTCTime;

end Behavioral;