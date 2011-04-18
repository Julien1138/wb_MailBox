----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_ScheduleTablesInterface
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

entity MailBox_ScheduleTablesInterface is
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
end MailBox_ScheduleTablesInterface;

architecture MailBox_ScheduleTablesInterface_behavior of MailBox_ScheduleTablesInterface is

begin
   
   -- Assert
   assert wb_adr_Recurrence_o'length = wb_adr_Timetable_o'length
      and wb_adr_Recurrence_o'length = ScanCounter_i'length        -- On vérifie que les bus d'adresse ont la même taille
      report "All wb address buses shall have the same size"
      severity failure;
      
   assert wb_dat_Recurrence_i'length = wb_dat_Timetable_o'length
      and wb_dat_Timetable_o'length = wb_dat_Timetable_i'length
      and wb_dat_Timetable_o'length = ScheduleNext_i'length        -- On vérifie que les bus de données ont la même taille
      report "All wb data buses shall have the same size"
      severity failure;
   
   --
   -- Timetable Management process
   --
   TimetableManagement_process : process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
         wb_we_Timetable_o <= '0';
         wb_cyc_Timetable_o <= '0';
         wb_stb_Timetable_o <= '0';
         wb_vld_Timetable_o <= '0';
      elsif rising_edge(wb_clk_i) then
         if ScanEnable_i = '1' then
            if wb_ack_Timetable_i = '0' then
               wb_we_Timetable_o <= '0';
               wb_cyc_Timetable_o <= '1';
               wb_stb_Timetable_o <= '1';
               wb_vld_Timetable_o <= '0';
            else
               wb_we_Timetable_o <= '0';
               wb_cyc_Timetable_o <= '1'; -- on laisse à '1' pour la lecture en bloc
               wb_stb_Timetable_o <= '0';
               wb_vld_Timetable_o <= '0';
            end if;
         elsif WriteTimetable_i = '1' then
            if wb_ack_Timetable_i = '0' then
               wb_we_Timetable_o <= '1';
               wb_cyc_Timetable_o <= '1';
               wb_stb_Timetable_o <= '1';
               wb_vld_Timetable_o <= TimetableDataIsValid_i;
            else
               wb_we_Timetable_o <= '0';
               wb_cyc_Timetable_o <= '0';
               wb_stb_Timetable_o <= '0';
               wb_vld_Timetable_o <= '0';
            end if;
         else
            wb_we_Timetable_o <= '0';
            wb_cyc_Timetable_o <= '0';
            wb_stb_Timetable_o <= '0';
            wb_vld_Timetable_o <= '0';
         end if;
      end if;
   end process;
   wb_adr_Timetable_o <= ScanCounter_i;
   wb_dat_Timetable_o <= ScheduleNext_i;
   TimetableDataIsValid_o <= wb_vld_Timetable_i;
   TimetableEOO_o <= wb_ack_Timetable_i;
   Schedule_o <= wb_dat_Timetable_i;

   -- Recurrence Table Management process
   RecurrenceTableManagement_process : process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
         wb_cyc_Recurrence_o <= '0';
         wb_stb_Recurrence_o <= '0';
      elsif rising_edge(wb_clk_i) then
         if ScanEnable_i = '1' then
            if wb_ack_Recurrence_i = '0' then
               wb_cyc_Recurrence_o <= '1';
               wb_stb_Recurrence_o <= '1';
            else
               wb_cyc_Recurrence_o <= '1'; -- on laisse à '1' pour la lecture en bloc
               wb_stb_Recurrence_o <= '0';
            end if;
         else
            wb_cyc_Recurrence_o <= '0';
            wb_stb_Recurrence_o <= '0';
         end if;
      end if;
   end process;
   wb_adr_Recurrence_o <= ScanCounter_i;
   RecurrenceDataIsValid_o <= wb_vld_Recurrence_i;
   RecurrenceEOO_o <= wb_ack_Recurrence_i;
   Recurrence_o <= wb_dat_Recurrence_i;

end MailBox_ScheduleTablesInterface_behavior;
