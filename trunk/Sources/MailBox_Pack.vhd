----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    wb_MailBox_Pack
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
use ieee.math_real.all;

library MailBox_Lib;

package MailBox_Pack is

   constant Recurrence_Addr   : std_logic_vector(1 downto 0) := "00";
   constant Timetable_Addr    : std_logic_vector(1 downto 0) := "01";
   constant DatingTable_Addr   : std_logic_vector(1 downto 0) := "10";
   constant DataTable_Addr    : std_logic_vector(1 downto 0) := "11";

   component MailBox
      generic
      (
         g_RTCClockPeriode : std_logic_vector;  -- Durée d'une période de l'horloge de datation - 1
         WB_Addr_Width         : integer;
         WB_Data_Width         : integer;
         RTC_time_Width        : integer
      );
      port
      (
         wb_clk_i      : in std_logic;
         wb_rst_i      : in std_logic;
         
      -- Settings and Data Read Interface
         wb_we_i_User   : in std_logic;
         wb_adr_i_User  : in std_logic_vector(WB_Addr_Width + 2 downto 0);
         wb_dat_i_User  : in std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_dat_o_User  : out std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_cyc_i_User  : in std_logic;
         wb_stb_i_User  : in std_logic;
         wb_ack_o_User  : out std_logic;
         wb_dtr_o_User  : out std_logic;   -- Data is available to be read
         wb_atr_o_User  : out std_logic_vector(WB_Addr_Width downto 0); -- Address at which Data should be read
         
      -- External Master Interface
         wb_we_o_Master  : out std_logic;
         wb_adr_o_Master : out std_logic_vector(WB_Addr_Width - 1 downto 0);
         wb_dat_o_Master : out std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_dat_i_Master : in std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_cyc_o_Master : out std_logic;
         wb_stb_o_Master : out std_logic;
         wb_ack_i_Master : in std_logic;
      
         RTCTime_o      : out std_logic_vector(RTC_time_Width - 1 downto 0)
      );
   end component;

   component MailBox_Sequencer
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
   end component;
   
   component MailBox_DataTablesInterface
      port
      (
         wb_clk_i             : in std_logic;
         wb_rst_i             : in std_logic;
         
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
         
      -- Event Manager Interface
         EventAddr_i          : in std_logic_vector;
         NewEvent_i           : in std_logic;
         ReadyForEvent_o      : out std_logic
         
      );
   end component;
   
   component MailBox_EventsManager
      port
      (
      -- global signals
         clk_i             : in std_logic;
         rst_i             : in std_logic;
         
      -- Time Triggered Events Interface
         NewTimeEvent_i    : in std_logic;
         TimeEventAddr_i   : in std_logic_vector;
         
      -- Ext Triggered Events Interface
         NewExtEvent_i     : in std_logic;
         ExtEventAddr_i    : in std_logic_vector;
         
      -- Data Tables Interface
         NewEvent_o        : out std_logic;
         EventAddr_o       : out std_logic_vector;
         ReadyForEvent_i   : in std_logic
      );
   end component;
   
   component MailBox_ScheduleTablesInterface
      port
      (
         wb_clk_i                : in std_logic;
         wb_rst_i                : in std_logic;
         
      -- Timetable Interface
         wb_we_Timetable_o       : out std_logic;
         wb_adr_Timetable_o      : out std_logic_vector;
         wb_dat_Timetable_o      : out std_logic_vector;
         wb_dat_Timetable_i      : in std_logic_vector;
         wb_cyc_Timetable_o      : out std_logic;
         wb_stb_Timetable_o      : out std_logic;
         wb_ack_Timetable_i      : in std_logic;
         wb_vld_Timetable_o      : out std_logic;
         wb_vld_Timetable_i      : in std_logic;
         
      -- Recurrence Table Interface
         wb_adr_Recurrence_o     : out std_logic_vector;
         wb_dat_Recurrence_i     : in std_logic_vector;
         wb_cyc_Recurrence_o     : out std_logic;
         wb_stb_Recurrence_o     : out std_logic;
         wb_ack_Recurrence_i     : in std_logic;
         wb_vld_Recurrence_i     : in std_logic;
         
      -- Event Manager Interface
         ScanEnable_i            : in std_logic;
         WriteTimetable_i        : in std_logic;
         ScanCounter_i           : in std_logic_vector;
         Schedule_o              : out std_logic_vector;
         Recurrence_o            : out std_logic_vector;
         ScheduleNext_i          : in std_logic_vector;
         TimetableDataIsValid_i  : in std_logic;
         TimetableDataIsValid_o  : out std_logic;
         RecurrenceDataIsValid_o : out std_logic;
         TimetableEOO_o          : out std_logic;  -- End of Bus Operations
         RecurrenceEOO_o         : out std_logic   -- End of Bus Operations
         
      );
   end component;
   
   component MailBox_TimeTriggeredEvents
      port
      (
      -- global signals
         clk_i                   : in std_logic;
         rst_i                   : in std_logic;
         
      -- RTC interface
         RTCTime_i               : in std_logic_vector;
      
      -- Schedule Tables Interface
         ScanEnable_o            : out std_logic;
         WriteTimetable_o        : out std_logic;
         ScanCounter_o           : out std_logic_vector;
         Schedule_i              : in std_logic_vector;
         Recurrence_i            : in std_logic_vector;
         ScheduleNext_o          : out std_logic_vector;
         TimetableDataIsValid_o  : out std_logic;
         TimetableDataIsValid_i  : in std_logic;
         RecurrenceDataIsValid_i : in std_logic;
         TimetableEOO_i          : in std_logic;  -- End of Bus Operations
         RecurrenceEOO_i         : in std_logic;  -- End of Bus Operations
         
      -- Event Manager Interface
         NewEvent_o              : out std_logic;
         EventAddr_o             : out std_logic_vector
      );
   end component;
   
   component MailBox_ExtTriggeredEvents
      port
      (
      -- global signals
         clk_i       : in std_logic;
         rst_i       : in std_logic;
         
      -- Ext Interface
         Trigger_i   : in std_logic_vector;
         
      -- Event Manager Interface
         NewEvent_o  : out std_logic;
         EventAddr_o : out std_logic_vector
      );
   end component;
   
   component MailBox_Recurrence
      port
      (
         wb_clk_i       : in std_logic;
         wb_rst_i       : in std_logic;
         
      -- Interface A
         wb_we_usr_i    : in std_logic;
         wb_adr_usr_i   : in std_logic_vector;
         wb_dat_usr_i   : in std_logic_vector;
         wb_dat_usr_o   : out std_logic_vector;
         wb_cyc_usr_i   : in std_logic;
         wb_stb_usr_i   : in std_logic;
         wb_ack_usr_o   : out std_logic;
         
      -- Interface B
         wb_adr_seq_i   : in std_logic_vector;
         wb_dat_seq_o   : out std_logic_vector;
         wb_cyc_seq_i   : in std_logic;
         wb_stb_seq_i   : in std_logic;
         wb_ack_seq_o   : out std_logic;
         wb_vld_seq_o   : out std_logic   -- Indique si la valeur lue est valide
      );
   end component;
   
   component MailBox_Timetable
      port
      (
         wb_clk_i       : in std_logic;
         wb_rst_i       : in std_logic;
         
      -- Interface A
         wb_we_usr_i    : in std_logic;
         wb_adr_usr_i   : in std_logic_vector;
         wb_dat_usr_i   : in std_logic_vector;
         wb_dat_usr_o   : out std_logic_vector;
         wb_cyc_usr_i   : in std_logic;
         wb_stb_usr_i   : in std_logic;
         wb_ack_usr_o   : out std_logic;
         
      -- Interface B
         wb_we_seq_i    : in std_logic;
         wb_adr_seq_i   : in std_logic_vector;
         wb_dat_seq_i   : in std_logic_vector;
         wb_dat_seq_o   : out std_logic_vector;
         wb_cyc_seq_i   : in std_logic;
         wb_stb_seq_i   : in std_logic;
         wb_ack_seq_o   : out std_logic;
         wb_vld_seq_i   : in std_logic;   -- Indique que la valeur n'est plus valide
         wb_vld_seq_o   : out std_logic   -- Indique si la valeur lue est valide
      );
   end component;
   
   component MailBox_RTC
      generic
      (
         g_RTCClockPeriode : std_logic_vector   -- Durée d'une période de l'horloge de datation - 1
      );
      port
      (
         clk_i       : in std_logic;
         rst_i       : in std_logic;
         RTC_time_o  : out std_logic_vector
      );
   end component;
   
   component MailBox_AddrToRead
      port
      (
         wb_clk_i    : in std_logic;
         wb_rst_i    : in std_logic;
         
      -- Input Interface
         wb_we_i     : in std_logic;
         wb_dat_i    : in std_logic_vector;
         wb_cyc_i    : in std_logic;
         wb_stb_i    : in std_logic;
         wb_ack_o    : out std_logic;
         
      -- Output Interface
         Read_i      : in std_logic; -- Current address is being read
         Addr_o      : out std_logic_vector;
         AddrAvail_o : out std_logic -- Address Available to be read
      );
   end component;
   
   component MailBox_DualPortRAM
      port
      (
         wb_clk_i    : in std_logic;
         wb_rst_i    : in std_logic;
         
      -- Interface A
         wb_we_A_i   : in std_logic;
         wb_adr_A_i  : in std_logic_vector;
         wb_dat_A_i  : in std_logic_vector;
         wb_dat_A_o  : out std_logic_vector;
         wb_cyc_A_i  : in std_logic;
         wb_stb_A_i  : in std_logic;
         wb_ack_A_o  : out std_logic;
         
      -- Interface B
         wb_we_B_i  : in std_logic;
         wb_adr_B_i : in std_logic_vector;
         wb_dat_B_i : in std_logic_vector;
         wb_dat_B_o : out std_logic_vector;
         wb_cyc_B_i : in std_logic;
         wb_stb_B_i : in std_logic;
         wb_ack_B_o : out std_logic
      );
   end component;
   
   component MailBox_FIFO
      generic
      (
         g_FIFOSize  : std_logic_vector := X"3FF"  -- Nombre d'éléments de la FIFO - 1
      );
      port
      (
         rst_i    : in std_logic;
         clk_i    : in std_logic;
         
         WE_i     : in std_logic;
         Data_i   : in std_logic_vector;
         RE_i     : in std_logic;
         Data_o   : out std_logic_vector;
         
         Empty_o  : out std_logic;
         Full_o   : out std_logic
      );
   end component;

end MailBox_Pack;
