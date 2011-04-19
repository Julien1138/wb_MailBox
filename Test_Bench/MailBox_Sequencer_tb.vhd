----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_Sequencer_tb
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
use MailBox_Lib.MailBox_Pack.all;

entity MailBox_Sequencer_tb is
   generic
   (
      WB_Addr_Width   : integer := 4;
      WB_Data_Width   : integer := 8;
      RTC_time_Width  : integer := 16
   );
end MailBox_Sequencer_tb;

architecture behavior of MailBox_Sequencer_tb is

   signal s_clk         : std_logic := '1';
   signal s_rst         : std_logic := '1';
   
-- Interface Recurrence Table
   signal s_wb_adr_UutToRecurrence     : std_logic_vector(WB_Addr_Width downto 0);
   signal s_wb_dat_RecurrenceToUut     : std_logic_vector(RTC_time_Width - 1 downto 0) := X"0004";
   signal s_wb_cyc_UutToRecurrence     : std_logic;
   signal s_wb_stb_UutToRecurrence     : std_logic;
   signal s_wb_ack_RecurrenceToUut     : std_logic := '0';
   signal s_wb_ack_RecurrenceToUut_int : std_logic := '0';
   signal s_wb_vld_RecurrenceToUut     : std_logic := '1';
   
-- Interface Timetable
   signal s_wb_we_UutToTimetable       : std_logic;
   signal s_wb_adr_UutToTimetable      : std_logic_vector(WB_Addr_Width downto 0);
   signal s_wb_dat_UutToTimetable      : std_logic_vector(RTC_time_Width - 1 downto 0);
   signal s_wb_dat_TimetableToUut      : std_logic_vector(RTC_time_Width - 1 downto 0) := X"0001";
   signal s_wb_cyc_UutToTimetable      : std_logic;
   signal s_wb_stb_UutToTimetable      : std_logic;
   signal s_wb_ack_TimetableToUut      : std_logic := '0';
   signal s_wb_ack_TimetableToUut_int  : std_logic := '0';
   signal s_wb_vld_UutToTimetable      : std_logic;
   signal s_wb_vld_TimetableToUut      : std_logic := '1';
      
-- Interface DatingTable
   signal s_wb_we_UutToDatingTable        : std_logic;
   signal s_wb_adr_UutToDatingTable       : std_logic_vector(WB_Addr_Width downto 0);
   signal s_wb_dat_UutToDatingTable       : std_logic_vector(RTC_time_Width - 1 downto 0);
   signal s_wb_cyc_UutToDatingTable       : std_logic;
   signal s_wb_stb_UutToDatingTable       : std_logic;
   signal s_wb_ack_DatingTableToUut       : std_logic := '0';
   signal s_wb_ack_DatingTableToUut_int   : std_logic := '0';
      
-- Interface DataTable
   signal s_wb_we_UutToDataTable       : std_logic;
   signal s_wb_adr_UutToDataTable      : std_logic_vector(WB_Addr_Width downto 0);
   signal s_wb_dat_UutToDataTable      : std_logic_vector(WB_Data_Width - 1 downto 0);
   signal s_wb_dat_DataTableToUut      : std_logic_vector(WB_Data_Width - 1 downto 0) := X"52";
   signal s_wb_cyc_UutToDataTable      : std_logic;
   signal s_wb_stb_UutToDataTable      : std_logic;
   signal s_wb_ack_DataTableToUut      : std_logic := '0';
   signal s_wb_ack_DataTableToUut_int  : std_logic := '0';
   
-- Interface AddrToRead
   signal s_wb_we_UutToAddrToRead      : std_logic;
   signal s_wb_dat_UutToAddrToRead     : std_logic_vector(WB_Addr_Width downto 0);
   signal s_wb_cyc_UutToAddrToRead     : std_logic;
   signal s_wb_stb_UutToAddrToRead     : std_logic;
   signal s_wb_ack_AddrToReadToUut     : std_logic := '0';
   signal s_wb_ack_AddrToReadToUut_int : std_logic := '0';
   
-- Interface Master Exterieur
   signal s_wb_we_UutToMaster       : std_logic;
   signal s_wb_adr_UutToMaster      : std_logic_vector(WB_Addr_Width - 1 downto 0);
   signal s_wb_dat_UutToMaster      : std_logic_vector(WB_Data_Width - 1 downto 0);
   signal s_wb_dat_MasterToUut      : std_logic_vector(WB_Data_Width - 1 downto 0) := X"3B";
   signal s_wb_cyc_UutToMaster      : std_logic;
   signal s_wb_stb_UutToMaster      : std_logic;
   signal s_wb_ack_MasterToUut      : std_logic := '0';
   signal s_wb_ack_MasterToUut_int  : std_logic := '0';
   
-- RTC interface
   signal s_RTCtime  : std_logic_vector(RTC_time_Width - 1 downto 0) := (others => '0');
   
-- External Trigger
   signal s_Trigger  : std_logic_vector(2**WB_Addr_Width - 1 downto 0) := (others => '0');
   
   constant clk_period : time := 20 ns;   -- 50 MHz

begin

   s_rst <= '0' after 53 ns;
   s_clk <= not s_clk after clk_period/2;

   s_RTCtime <= s_RTCtime + 1 after 1 ms;

   Recurrence_Interface_Ack_process : process(s_clk)
   begin
      if rising_edge(s_clk) then
         if s_rst = '1' then
            s_wb_ack_RecurrenceToUut_int <= '0';
         else
            s_wb_ack_RecurrenceToUut_int <= '0';
            if s_wb_cyc_UutToRecurrence = '1' and s_wb_stb_UutToRecurrence = '1' and s_wb_ack_RecurrenceToUut_int = '0' then
               s_wb_ack_RecurrenceToUut_int <= '1';
            end if;
         end if;
      end if;
   end process;
   s_wb_ack_RecurrenceToUut <= s_wb_ack_RecurrenceToUut_int;

   DatingTable_Interface_Ack_process : process(s_clk)
   begin
      if rising_edge(s_clk) then
         if s_rst = '1' then
            s_wb_ack_DatingTableToUut_int <= '0';
         else
            s_wb_ack_DatingTableToUut_int <= '0';
            if s_wb_cyc_UutToDatingTable = '1' and s_wb_stb_UutToDatingTable = '1' and s_wb_ack_DatingTableToUut_int = '0' then
               s_wb_ack_DatingTableToUut_int <= '1';
            end if;
         end if;
      end if;
   end process;
   s_wb_ack_DatingTableToUut <= s_wb_ack_DatingTableToUut_int;

   Timetable_Interface_Ack_process : process(s_clk)
   begin
      if rising_edge(s_clk) then
         if s_rst = '1' then
            s_wb_ack_TimetableToUut_int <= '0';
         else
            s_wb_ack_TimetableToUut_int <= '0';
            if s_wb_cyc_UutToTimetable = '1' and s_wb_stb_UutToTimetable = '1' and s_wb_ack_TimetableToUut_int = '0' then
               s_wb_ack_TimetableToUut_int <= '1';
            end if;
         end if;
      end if;
   end process;
   s_wb_ack_TimetableToUut <= s_wb_ack_TimetableToUut_int;
   
   DataTable_Interface_Ack_process : process(s_clk)
   begin
      if rising_edge(s_clk) then
         if s_rst = '1' then
            s_wb_ack_DataTableToUut_int <= '0';
         else
            s_wb_ack_DataTableToUut_int <= '0';
            if s_wb_cyc_UutToDataTable = '1' and s_wb_stb_UutToDataTable = '1' and s_wb_ack_DataTableToUut_int = '0' then
               s_wb_ack_DataTableToUut_int <= '1';
            end if;
         end if;
      end if;
   end process;
   s_wb_ack_DataTableToUut <= s_wb_ack_DataTableToUut_int;
   
   AddrToRead_Interface_Ack_process : process(s_clk)
   begin
      if rising_edge(s_clk) then
         if s_rst = '1' then
            s_wb_ack_AddrToReadToUut_int <= '0';
         else
            s_wb_ack_AddrToReadToUut_int <= '0';
            if s_wb_cyc_UutToAddrToRead = '1' and s_wb_stb_UutToAddrToRead = '1' and s_wb_ack_AddrToReadToUut_int = '0' then
               s_wb_ack_AddrToReadToUut_int <= '1';
            end if;
         end if;
      end if;
   end process;
   s_wb_ack_AddrToReadToUut <= s_wb_ack_AddrToReadToUut_int;

   Master_Interface_Ack_process : process(s_clk)
   begin
      if rising_edge(s_clk) then
         if s_rst = '1' then
            s_wb_ack_MasterToUut_int <= '0';
         else
            s_wb_ack_MasterToUut_int <= '0';
            if s_wb_cyc_UutToMaster = '1' and s_wb_stb_UutToMaster = '1' and s_wb_ack_MasterToUut_int = '0' then
               s_wb_ack_MasterToUut_int <= '1';
            end if;
         end if;
      end if;
   end process;
   s_wb_ack_MasterToUut <= s_wb_ack_MasterToUut_int;
   
   MailBox_Sequencer_tb : MailBox_Sequencer
   port map
   (
      wb_clk_i             => s_clk,
      wb_rst_i             => s_rst,
      
      wb_we_Timetable_o    => s_wb_we_UutToTimetable,
      wb_adr_Timetable_o   => s_wb_adr_UutToTimetable,
      wb_dat_Timetable_o   => s_wb_dat_UutToTimetable,
      wb_dat_Timetable_i   => s_wb_dat_TimetableToUut,
      wb_cyc_Timetable_o   => s_wb_cyc_UutToTimetable,
      wb_stb_Timetable_o   => s_wb_stb_UutToTimetable,
      wb_ack_Timetable_i   => s_wb_ack_TimetableToUut,
      wb_vld_Timetable_o   => s_wb_vld_UutToTimetable,
      wb_vld_Timetable_i   => s_wb_vld_TimetableToUut,
      
      wb_adr_Recurrence_o  => s_wb_adr_UutToRecurrence,
      wb_dat_Recurrence_i  => s_wb_dat_RecurrenceToUut,
      wb_cyc_Recurrence_o  => s_wb_cyc_UutToRecurrence,
      wb_stb_Recurrence_o  => s_wb_stb_UutToRecurrence,
      wb_ack_Recurrence_i  => s_wb_ack_RecurrenceToUut,
      wb_vld_Recurrence_i  => s_wb_vld_RecurrenceToUut,
      
      wb_we_DatingTable_o  => s_wb_we_UutToDatingTable,
      wb_adr_DatingTable_o => s_wb_adr_UutToDatingTable,
      wb_dat_DatingTable_o => s_wb_dat_UutToDatingTable,
      wb_cyc_DatingTable_o => s_wb_cyc_UutToDatingTable,
      wb_stb_DatingTable_o => s_wb_stb_UutToDatingTable,
      wb_ack_DatingTable_i => s_wb_ack_DatingTableToUut,
      
      wb_we_DataTable_o    => s_wb_we_UutToDataTable,
      wb_adr_DataTable_o   => s_wb_adr_UutToDataTable,
      wb_dat_DataTable_o   => s_wb_dat_UutToDataTable,
      wb_dat_DataTable_i   => s_wb_dat_DataTableToUut,
      wb_cyc_DataTable_o   => s_wb_cyc_UutToDataTable,
      wb_stb_DataTable_o   => s_wb_stb_UutToDataTable,
      wb_ack_DataTable_i   => s_wb_ack_DataTableToUut,
      
      wb_we_AddrToRead_o   => s_wb_we_UutToAddrToRead,
      wb_dat_AddrToRead_o  => s_wb_dat_UutToAddrToRead,
      wb_cyc_AddrToRead_o  => s_wb_cyc_UutToAddrToRead,
      wb_stb_AddrToRead_o  => s_wb_stb_UutToAddrToRead,
      wb_ack_AddrToRead_i  => s_wb_ack_AddrToReadToUut,
      
      wb_we_Master_o       => s_wb_we_UutToMaster,
      wb_adr_Master_o      => s_wb_adr_UutToMaster,
      wb_dat_Master_o      => s_wb_dat_UutToMaster,
      wb_dat_Master_i      => s_wb_dat_MasterToUut,
      wb_cyc_Master_o      => s_wb_cyc_UutToMaster,
      wb_stb_Master_o      => s_wb_stb_UutToMaster,
      wb_ack_Master_i      => s_wb_ack_MasterToUut,
      
      RTCTime_i            => s_RTCtime,
      
      Trigger_i            => s_Trigger
   );

end behavior;
