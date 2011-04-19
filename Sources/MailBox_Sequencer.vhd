----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_Sequencer
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

entity MailBox_Sequencer is
   port
   (
      wb_clk_i             : in std_logic;
      wb_rst_i             : in std_logic;
      
   -- Timetable Interface
      wb_we_Timetable_o    : out std_logic;
      wb_adr_Timetable_o   : out std_logic_vector;
      wb_dat_Timetable_o   : out std_logic_vector;
      wb_dat_Timetable_i   : in std_logic_vector;
      wb_cyc_Timetable_o   : out std_logic;
      wb_stb_Timetable_o   : out std_logic;
      wb_ack_Timetable_i   : in std_logic;
      wb_vld_Timetable_o   : out std_logic;
      wb_vld_Timetable_i   : in std_logic;
      
   -- Recurrence Table Interface
      wb_adr_Recurrence_o  : out std_logic_vector;
      wb_dat_Recurrence_i  : in std_logic_vector;
      wb_cyc_Recurrence_o  : out std_logic;
      wb_stb_Recurrence_o  : out std_logic;
      wb_ack_Recurrence_i  : in std_logic;
      wb_vld_Recurrence_i  : in std_logic;
      
   -- Interface DatingTable
      wb_we_DatingTable_o  : out std_logic;
      wb_adr_DatingTable_o : out std_logic_vector;
      wb_dat_DatingTable_o : out std_logic_vector;
      wb_cyc_DatingTable_o : out std_logic;
      wb_stb_DatingTable_o : out std_logic;
      wb_ack_DatingTable_i : in std_logic;
      
   -- Interface DataTable
      wb_we_DataTable_o    : out std_logic;
      wb_adr_DataTable_o   : out std_logic_vector;
      wb_dat_DataTable_o   : out std_logic_vector;
      wb_dat_DataTable_i   : in std_logic_vector;
      wb_cyc_DataTable_o   : out std_logic;
      wb_stb_DataTable_o   : out std_logic;
      wb_ack_DataTable_i   : in std_logic;
      
   -- Interface AddrToRead
      wb_we_AddrToRead_o   : out std_logic;
      wb_dat_AddrToRead_o  : out std_logic_vector;
      wb_cyc_AddrToRead_o  : out std_logic;
      wb_stb_AddrToRead_o  : out std_logic;
      wb_ack_AddrToRead_i  : in std_logic;
      
   -- Interface Master Exterieur
      wb_we_Master_o       : out std_logic;
      wb_adr_Master_o      : out std_logic_vector;
      wb_dat_Master_o      : out std_logic_vector;
      wb_dat_Master_i      : in std_logic_vector;
      wb_cyc_Master_o      : out std_logic;
      wb_stb_Master_o      : out std_logic;
      wb_ack_Master_i      : in std_logic;
      
   -- RTC interface
      RTCTime_i            : in std_logic_vector;
      
   -- Ext Interface
      Trigger_i            : in std_logic_vector
   );
end MailBox_Sequencer;

architecture MailBox_Sequencer_behavior of MailBox_Sequencer is
   
   -- Event Manager Interface
   signal s_EventAddr_ManagerToDataTables       : std_logic_vector(wb_adr_DataTable_o'range);
   signal s_NewEvent_ManagerToDataTablest       : std_logic;
   signal s_ReadyForEvent_DataTablesToManager   : std_logic;
   
   -- Time Triggered Events Interface
   signal s_EventAddr_TimeTrigToManager   : std_logic_vector(wb_adr_DataTable_o'range);
   signal s_NewEvent_TimeTrigToManager    : std_logic;
   
   -- Ext Triggered Events Interface
   signal s_EventAddr_ExtTrigToManager    : std_logic_vector(wb_adr_Master_o'range);
   signal s_NewEvent_ExtTrigToManager     : std_logic;
   
   -- Schedule Management Interface
   signal s_TimeTriggerToTable_ScanEnable             : std_logic;
   signal s_TimeTriggerToTable_WriteTimetable         : std_logic;
   signal s_TimeTriggerToTable_ScanCounter            : std_logic_vector(wb_adr_DataTable_o'range);
   signal s_TableToTimeTrigger_Schedule               : std_logic_vector(RTCTime_i'range);
   signal s_TableToTimeTrigger_Recurrence             : std_logic_vector(RTCTime_i'range);
   signal s_TimeTriggerToTable_ScheduleNext           : std_logic_vector(RTCTime_i'range);
   signal s_TimeTriggerToTable_TimetableDataIsValid   : std_logic;
   signal s_TableToTimeTrigger_TimetableDataIsValid   : std_logic;
   signal s_TableToTimeTrigger_RecurrenceDataIsValid  : std_logic;
   signal s_TableToTimeTrigger_TimetableEOO           : std_logic;
   signal s_TableToTimeTrigger_RecurrenceEOO          : std_logic;
   
begin
   
   --
   -- Assert
   --
   assert wb_adr_Timetable_o'length    = wb_adr_Recurrence_o'length
      and wb_adr_Recurrence_o'length   = wb_adr_DatingTable_o'length
      and wb_adr_DatingTable_o'length  = wb_adr_DataTable_o'length
      and wb_adr_DataTable_o'length    = wb_dat_AddrToRead_o'length
      and wb_dat_AddrToRead_o'length   = wb_adr_Master_o'length + 1
      report "Size of address buses does not match"
      severity failure;
      
   assert wb_dat_DataTable_o'length    = wb_dat_DataTable_i'length
      and wb_dat_DataTable_i'length    = wb_dat_Master_o'length
      and wb_dat_Master_o'length       = wb_dat_Master_i'length
      report "Size of data buses does not match"
      severity failure;
      
   assert wb_dat_Timetable_o'length    = wb_dat_Timetable_i'length
      and wb_dat_Timetable_i'length    = wb_dat_Recurrence_i'length
      and wb_dat_Recurrence_i'length   = wb_dat_DatingTable_o'length
      report "Size of Time buses does not match"
      severity failure;
   
   MailBox_DataTablesInterface_inst : MailBox_DataTablesInterface
   port map
   (
      wb_clk_i             => wb_clk_i,
      wb_rst_i             => wb_rst_i,
      
      wb_we_DatingTable_o  => wb_we_DatingTable_o,
      wb_adr_DatingTable_o => wb_adr_DatingTable_o,
      wb_dat_DatingTable_o => wb_dat_DatingTable_o,
      wb_cyc_DatingTable_o => wb_cyc_DatingTable_o,
      wb_stb_DatingTable_o => wb_stb_DatingTable_o,
      wb_ack_DatingTable_i => wb_ack_DatingTable_i,
      
      wb_we_DataTable_o    => wb_we_DataTable_o,
      wb_adr_DataTable_o   => wb_adr_DataTable_o,
      wb_dat_DataTable_o   => wb_dat_DataTable_o,
      wb_dat_DataTable_i   => wb_dat_DataTable_i,
      wb_cyc_DataTable_o   => wb_cyc_DataTable_o,
      wb_stb_DataTable_o   => wb_stb_DataTable_o,
      wb_ack_DataTable_i   => wb_ack_DataTable_i,
      
      wb_we_AddrToRead_o   => wb_we_AddrToRead_o,
      wb_dat_AddrToRead_o  => wb_dat_AddrToRead_o,
      wb_cyc_AddrToRead_o  => wb_cyc_AddrToRead_o,
      wb_stb_AddrToRead_o  => wb_stb_AddrToRead_o,
      wb_ack_AddrToRead_i  => wb_ack_AddrToRead_i,
      
      wb_we_Master_o       => wb_we_Master_o,
      wb_adr_Master_o      => wb_adr_Master_o,
      wb_dat_Master_o      => wb_dat_Master_o,
      wb_dat_Master_i      => wb_dat_Master_i,
      wb_cyc_Master_o      => wb_cyc_Master_o,
      wb_stb_Master_o      => wb_stb_Master_o,
      wb_ack_Master_i      => wb_ack_Master_i,
      
      RTCTime_i            => RTCTime_i,
      
      EventAddr_i          => s_EventAddr_ManagerToDataTables,
      NewEvent_i           => s_NewEvent_ManagerToDataTablest,
      ReadyForEvent_o      => s_ReadyForEvent_DataTablesToManager
   );
   
   MailBox_EventsManager_inst : MailBox_EventsManager
   port map
   (
      clk_i             => wb_clk_i,
      rst_i             => wb_rst_i,
      
      NewTimeEvent_i    => s_NewEvent_TimeTrigToManager,
      TimeEventAddr_i   => s_EventAddr_TimeTrigToManager,
      
      NewExtEvent_i     => s_NewEvent_ExtTrigToManager,
      ExtEventAddr_i    => s_EventAddr_ExtTrigToManager,
      
      EventAddr_o       => s_EventAddr_ManagerToDataTables,
      NewEvent_o        => s_NewEvent_ManagerToDataTablest,
      ReadyForEvent_i   => s_ReadyForEvent_DataTablesToManager
   );
   
   MailBox_ScheduleTablesInterface_inst : MailBox_ScheduleTablesInterface
   port map
   (
      wb_clk_i                => wb_clk_i,
      wb_rst_i                => wb_rst_i,
      
      wb_we_Timetable_o       => wb_we_Timetable_o,
      wb_adr_Timetable_o      => wb_adr_Timetable_o,
      wb_dat_Timetable_o      => wb_dat_Timetable_o,
      wb_dat_Timetable_i      => wb_dat_Timetable_i,
      wb_cyc_Timetable_o      => wb_cyc_Timetable_o,
      wb_stb_Timetable_o      => wb_stb_Timetable_o,
      wb_ack_Timetable_i      => wb_ack_Timetable_i,
      wb_vld_Timetable_o      => wb_vld_Timetable_o,
      wb_vld_Timetable_i      => wb_vld_Timetable_i,
      
      wb_adr_Recurrence_o     => wb_adr_Recurrence_o,
      wb_dat_Recurrence_i     => wb_dat_Recurrence_i,
      wb_cyc_Recurrence_o     => wb_cyc_Recurrence_o,
      wb_stb_Recurrence_o     => wb_stb_Recurrence_o,
      wb_ack_Recurrence_i     => wb_ack_Recurrence_i,
      wb_vld_Recurrence_i     => wb_vld_Recurrence_i,
      
      ScanEnable_i            => s_TimeTriggerToTable_ScanEnable,
      WriteTimetable_i        => s_TimeTriggerToTable_WriteTimetable,
      ScanCounter_i           => s_TimeTriggerToTable_ScanCounter,
      Schedule_o              => s_TableToTimeTrigger_Schedule,
      Recurrence_o            => s_TableToTimeTrigger_Recurrence,
      ScheduleNext_i          => s_TimeTriggerToTable_ScheduleNext,
      TimetableDataIsValid_i  => s_TimeTriggerToTable_TimetableDataIsValid,
      TimetableDataIsValid_o  => s_TableToTimeTrigger_TimetableDataIsValid,
      RecurrenceDataIsValid_o => s_TableToTimeTrigger_RecurrenceDataIsValid,
      TimetableEOO_o          => s_TableToTimeTrigger_TimetableEOO,
      RecurrenceEOO_o         => s_TableToTimeTrigger_RecurrenceEOO
   );
   
   MailBox_TimeTriggeredEvents_inst : MailBox_TimeTriggeredEvents
   port map
   (
      clk_i                   => wb_clk_i,
      rst_i                   => wb_rst_i,
      
      RTCTime_i               => RTCTime_i,
      
      ScanEnable_o            => s_TimeTriggerToTable_ScanEnable,
      WriteTimetable_o        => s_TimeTriggerToTable_WriteTimetable,
      ScanCounter_o           => s_TimeTriggerToTable_ScanCounter,
      Schedule_i              => s_TableToTimeTrigger_Schedule,
      Recurrence_i            => s_TableToTimeTrigger_Recurrence,
      ScheduleNext_o          => s_TimeTriggerToTable_ScheduleNext,
      TimetableDataIsValid_o  => s_TimeTriggerToTable_TimetableDataIsValid,
      TimetableDataIsValid_i  => s_TableToTimeTrigger_TimetableDataIsValid,
      RecurrenceDataIsValid_i => s_TableToTimeTrigger_RecurrenceDataIsValid,
      TimetableEOO_i          => s_TableToTimeTrigger_TimetableEOO,
      RecurrenceEOO_i         => s_TableToTimeTrigger_RecurrenceEOO,
      
      NewEvent_o              => s_NewEvent_TimeTrigToManager,
      EventAddr_o             => s_EventAddr_TimeTrigToManager
   );
   
   MailBox_ExtTriggeredEvents_inst : MailBox_ExtTriggeredEvents
   port map
   (
      clk_i       => wb_clk_i,
      rst_i       => wb_rst_i,
      
      Trigger_i   => Trigger_i,
      
      NewEvent_o  => s_NewEvent_ExtTrigToManager,
      EventAddr_o => s_EventAddr_ExtTrigToManager
   );

end MailBox_Sequencer_behavior;