----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_TimeTriggeredEvents
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

entity MailBox_TimeTriggeredEvents is
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
end MailBox_TimeTriggeredEvents;

architecture MailBox_TimeTriggeredEvents_behavior of MailBox_TimeTriggeredEvents is
   
   constant c_TimeWindow   : std_logic_vector(RTCTime_i'high - 1 downto 0) := (others => '1');
   
   signal s_ScanEnable           : std_logic;
   signal s_TimeMatch            : std_logic;
   signal s_TimeMatch_r1         : std_logic;
   signal s_WriteTimetable       : std_logic;
   signal s_ScanCounter          : std_logic_vector(ScanCounter_o'range);
   signal s_RTCTimeRet           : std_logic_vector(RTCTime_i'range);
   signal s_ScheduleCheckEnable  : std_logic;
   
begin
   
   -- Assert
   assert ScanCounter_o'length = EventAddr_o'length
      report "ScanCounter_o and EventAddr_o buses shall have the same size"
      severity failure;
      
   assert RTCTime_i'length = Schedule_i'length
      and Schedule_i'length = Recurrence_i'length
      and Recurrence_i'length = ScheduleNext_o'length
      report "RTCTime_i, Schedule_i, Recurrence_i, and ScheduleNext_o buses shall have the same size"
      severity failure;
   
   -- Incrémentation du compteur de l'adresse en cours de scan
   Scan_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_ScanCounter <= (others => '0');
      elsif rising_edge(clk_i) then
         if s_ScanEnable = '1' and TimetableEOO_i = '1' then   -- Dans le cas où il n'y a pas de "Time match"
            s_ScanCounter <= s_ScanCounter + 1;
         end if;
      end if;
   end process;
   s_ScanEnable <= not (s_TimeMatch or s_WriteTimetable);
   ScanEnable_o <= s_ScanEnable;
   ScanCounter_o <= s_ScanCounter;
   EventAddr_o <= s_ScanCounter;
   
   -- Calcul des données temporelles 
   s_RTCTimeRet <= RTCTime_i - ('0' & c_TimeWindow);  -- Calcul de la fenêtre de comparaison de dates
   ScheduleNext_o <= Schedule_i + Recurrence_i;
   TimetableDataIsValid_o <= RecurrenceDataIsValid_i;
   
   -- Détection d'un s_TimeMatch
   TimeMatch_detection : process(s_ScheduleCheckEnable, RTCTime_i, s_RTCTimeRet, Schedule_i)
   begin
      if s_ScheduleCheckEnable = '1' then
         if s_RTCTimeRet < RTCTime_i then
            if Schedule_i <= RTCTime_i and Schedule_i >= s_RTCTimeRet then
               s_TimeMatch <= '1';
            else
               s_TimeMatch <= '0';
            end if;
         else
            if Schedule_i <= RTCTime_i or Schedule_i >= s_RTCTimeRet then
               s_TimeMatch <= '1';
            else
               s_TimeMatch <= '0';
            end if;
         end if;
      else
         s_TimeMatch <= '0';
      end if;
   end process;
   s_ScheduleCheckEnable <= RecurrenceEOO_i and TimetableEOO_i and TimetableDataIsValid_i;
   
   TimeMatchRetard_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_TimeMatch_r1 <= '0';
      elsif rising_edge(clk_i) then
         s_TimeMatch_r1 <= s_TimeMatch;
      end if;
   end process;
   
   WriteNewSchedule_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_WriteTimetable <= '0';
      elsif rising_edge(clk_i) then
         
         if s_TimeMatch = '1' then
            s_WriteTimetable <= '1';
         end if;
         
         if s_WriteTimetable = '1' and TimetableEOO_i = '1' then
            s_WriteTimetable <= '0';
         end if;
         
      end if;
   end process;
   WriteTimetable_o <= s_WriteTimetable;
   
   EventNotification_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         NewEvent_o <= '0';
      elsif rising_edge(clk_i) then
         NewEvent_o <= '0';
         
         if s_TimeMatch_r1 = '0' and s_TimeMatch = '1' then
            NewEvent_o <= '1';
         end if;
         
      end if;
   end process;
   
end MailBox_TimeTriggeredEvents_behavior;
