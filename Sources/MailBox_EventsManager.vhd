----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_EventsManager
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

entity MailBox_EventsManager is
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
end MailBox_EventsManager;

architecture MailBox_EventsManager_behavior of MailBox_EventsManager is
   
   type t_Event is (TimeEvent, ExtEvent);
   
   constant c_FIFOSize  : std_logic_vector(EventAddr_o'range) := (others => '1');
   
   signal s_LastEvent   : t_Event;
   
   signal s_TimeEventFIFORead    : std_logic;
   signal s_TimeEventFIFOAddr    : std_logic_vector(TimeEventAddr_i'range);
   signal s_TimeEventFIFOEmpty   : std_logic;
   
   signal s_ExtEventFIFORead     : std_logic;
   signal s_ExtEventFIFOAddr     : std_logic_vector(ExtEventAddr_i'range);
   signal s_ExtEventFIFOEmpty    : std_logic;
   
begin
   
   --
   -- assert
   --
   assert TimeEventAddr_i'length = ExtEventAddr_i'length + 1
      and  TimeEventAddr_i'length = EventAddr_o'length
      report "Size of address buses does not match"
      severity failure;
   
   --
   -- Main Process
   --
   Manager_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         NewEvent_o <= '0';
         EventAddr_o <= (EventAddr_o'range => '0');
         s_LastEvent <= TimeEvent;
         s_TimeEventFIFORead <= '0';
         s_ExtEventFIFORead <= '0';
      elsif rising_edge(clk_i) then
         NewEvent_o <= '0';
         s_TimeEventFIFORead <= '0';
         s_ExtEventFIFORead <= '0';
         
         if ReadyForEvent_i = '1' then
            if s_TimeEventFIFOEmpty = '0' and (s_ExtEventFIFOEmpty = '1' or s_LastEvent = ExtEvent) then
               NewEvent_o <= '1';
               EventAddr_o <= s_TimeEventFIFOAddr;
               s_LastEvent <= TimeEvent;
               s_TimeEventFIFORead <= '1';
            elsif s_ExtEventFIFOEmpty = '0' and (s_TimeEventFIFOEmpty = '1' or s_LastEvent = TimeEvent) then
               NewEvent_o <= '1';
               EventAddr_o <= '0' & s_ExtEventFIFOAddr;
               s_LastEvent <= ExtEvent;
               s_ExtEventFIFORead <= '1';
            end if;
         end if;
         
      end if;
   end process;
   
   TimeEventFIFO : MailBox_FIFO
   generic map
   (
      g_FIFOSize  => c_FIFOSize
   )
   port map
   (
      rst_i    => rst_i,
      clk_i    => clk_i,
      
      WE_i     => NewTimeEvent_i,
      Data_i   => TimeEventAddr_i,
      RE_i     => s_TimeEventFIFORead,
      Data_o   => s_TimeEventFIFOAddr,
      
      Empty_o  => s_TimeEventFIFOEmpty,
      Full_o   => open
   );
   
   ExtEventFIFO : MailBox_FIFO
   generic map
   (
      g_FIFOSize  => c_FIFOSize
   )
   port map
   (
      rst_i    => rst_i,
      clk_i    => clk_i,
      
      WE_i     => NewExtEvent_i,
      Data_i   => ExtEventAddr_i,
      RE_i     => s_ExtEventFIFORead,
      Data_o   => s_ExtEventFIFOAddr,
      
      Empty_o  => s_ExtEventFIFOEmpty,
      Full_o   => open
   );
   
end MailBox_EventsManager_behavior;
