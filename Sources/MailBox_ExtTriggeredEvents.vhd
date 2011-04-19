----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_ExtTriggeredEvents
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

entity MailBox_ExtTriggeredEvents is
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
end MailBox_ExtTriggeredEvents;

architecture MailBox_ExtTriggeredEvents_behavior of MailBox_ExtTriggeredEvents is
   
   constant c_NbrOfTriggers   : std_logic_vector(EventAddr_o'range) := (others => '1');   -- Trigger Bus Size - 1
   
   signal s_Trigger_d            : std_logic_vector(Trigger_i'range);
   signal s_RisingEdgeDetected   : std_logic_vector(Trigger_i'range);
   
   signal s_ScanCounter : std_logic_vector(EventAddr_o'range);
   
begin
   
   --
   -- Assert
   --
   assert Trigger_i'length - 1 = c_NbrOfTriggers
      report "Sizes of Trigger_i and EventAddr_o buses don't match"
      severity failure;
   
   TriggerRetard_process : process(rst_i, clk_i, Trigger_i)
   begin
      if rst_i = '1' then
         s_Trigger_d <= Trigger_i;
      elsif rising_edge(clk_i) then
         s_Trigger_d <= Trigger_i;
      end if;
   end process;
   
   RisingEdgeDetection_generate :
   for Idx in 0 to to_integer(unsigned(c_NbrOfTriggers)) generate
   begin
      RisingEdgeDetection_process : process(rst_i, clk_i)
      begin
         if rst_i = '1' then
            s_RisingEdgeDetected(Idx) <= '0';
         elsif rising_edge(clk_i) then
            
            if s_ScanCounter = Idx then
               s_RisingEdgeDetected(Idx) <= '0';
            end if;
            
            if s_Trigger_d(Idx) = '0' and Trigger_i(Idx) = '1' then
               s_RisingEdgeDetected(Idx) <= '1';
            end if;
            
         end if;
      end process;
   end generate;
   
   Scan_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_ScanCounter <= (others => '0');
      elsif rising_edge(clk_i) then
         s_ScanCounter <= s_ScanCounter + 1;
      end if;
   end process;
   
   EventManagerNotification_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         NewEvent_o <= '0';
         EventAddr_o <= (EventAddr_o'range => '0');
      elsif rising_edge(clk_i) then
         NewEvent_o <= '0';
         
         if s_RisingEdgeDetected(to_integer(unsigned(s_ScanCounter))) = '1' then
            NewEvent_o <= '1';
            EventAddr_o <= s_ScanCounter;
         end if;
         
      end if;
   end process;
   
end MailBox_ExtTriggeredEvents_behavior;
