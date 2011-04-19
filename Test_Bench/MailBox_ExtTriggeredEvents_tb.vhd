----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_ExtTriggeredEvents_tb
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

entity MailBox_ExtTriggeredEvents_tb is
end MailBox_ExtTriggeredEvents_tb;

architecture MailBox_ExtTriggeredEvents_tb_behavior of MailBox_ExtTriggeredEvents_tb is

   signal s_clk      : std_logic := '1';
   signal s_rst      : std_logic := '1';
   
   signal s_Trigger     : std_logic_vector(15 downto 0) := (others => '0');
   
   signal s_NewEvent    : std_logic;
   signal s_EventAddr   : std_logic_vector(3 downto 0);
   
   constant clk_period : time := 20 ns;   -- 50 MHz

begin

   s_rst <= '0' after 53 ns;
   s_clk <= not s_clk after clk_period/2;
   
   process
   begin
      wait for 100 ns;
         s_Trigger(0) <= '1';
      wait for 50 ns;
         s_Trigger(5) <= '1';
         s_Trigger(12) <= '1';
         s_Trigger(15) <= '1';
      wait for 20 ns;
         s_Trigger(5) <= '0';
         s_Trigger(12) <= '0';
         s_Trigger(15) <= '0';
      wait for 200 ns;
         s_Trigger(0) <= '0';
         s_Trigger(1) <= '1';
      
      wait;
   end process;

   MailBox_ExtTriggeredEvents_tb : MailBox_ExtTriggeredEvents
   port map
   (
      clk_i             => s_clk,
      rst_i             => s_rst,
      Trigger_i         => s_Trigger,
      NewEvent_o        => s_NewEvent,
      EventAddr_o       => s_EventAddr
   );

end MailBox_ExtTriggeredEvents_tb_behavior;
