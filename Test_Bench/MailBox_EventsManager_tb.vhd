----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_EventsManager_tb
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

entity MailBox_EventsManager_tb is
end MailBox_EventsManager_tb;

architecture MailBox_EventsManager_tb_behavior of MailBox_EventsManager_tb is

   signal s_clk      : std_logic := '1';
   signal s_rst      : std_logic := '1';
   
   signal s_NewTimeEvent   : std_logic := '0';
   signal s_TimeEventAddr  : std_logic_vector(3 downto 0) := (others => '0');
   
   signal s_NewExtEvent    : std_logic := '0';
   signal s_ExtEventAddr   : std_logic_vector(3 downto 0) := (others => '0');
   
   signal s_NewEvent       : std_logic;
   signal s_EventAddr      : std_logic_vector(3 downto 0);
   signal s_ReadyForEvent  : std_logic := '0';
   
   signal s_NewEvent_d     : std_logic;
   signal s_NewEvent_dd    : std_logic;
   
   constant clk_period : time := 20 ns;   -- 50 MHz

begin

   s_rst <= '0' after 53 ns;
   s_clk <= not s_clk after clk_period/2;
   
   TimeEvent_process : process
   begin
      wait for 100 ns;
         s_NewTimeEvent <= '1';
         s_TimeEventAddr <= "1000";
      wait for clk_period;
         s_NewTimeEvent <= '0';
         
      wait for 100 ns;
         s_NewTimeEvent <= '1';
         s_TimeEventAddr <= "1001";
      wait for clk_period;
         s_NewTimeEvent <= '0';
         
      wait for 100 ns;
         s_NewTimeEvent <= '1';
         s_TimeEventAddr <= "1010";
      wait for clk_period;
         s_NewTimeEvent <= '0';
         
      wait for 100 ns;
         s_NewTimeEvent <= '1';
         s_TimeEventAddr <= "1011";
      wait for clk_period;
         s_NewTimeEvent <= '0';
         
      wait for 100 ns;
         s_NewTimeEvent <= '1';
         s_TimeEventAddr <= "1100";
      wait for clk_period;
         s_NewTimeEvent <= '0';
         
      wait for 100 ns;
         s_NewTimeEvent <= '1';
         s_TimeEventAddr <= "1101";
      wait for clk_period;
         s_NewTimeEvent <= '0';
         
      wait for 100 ns;
         s_NewTimeEvent <= '1';
         s_TimeEventAddr <= "1110";
      wait for clk_period;
         s_NewTimeEvent <= '0';
         
      wait;
   end process;
   
   ExtEvent_process : process
   begin
      wait for 150 ns;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0000";
      wait for clk_period;
         s_NewExtEvent <= '0';
         
      wait for 50 ns;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0001";
      wait for clk_period;
         s_NewExtEvent <= '0';
         
      wait for 100 ns;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0010";
      wait for clk_period;
         s_NewExtEvent <= '0';
         
      wait for 120 ns;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0011";
      wait for clk_period;
         s_NewExtEvent <= '0';
         
      wait for 200 ns;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0100";
      wait for clk_period;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0101";
      wait for 20 ns;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0110";
      wait for 20 ns;
         s_NewExtEvent <= '1';
         s_ExtEventAddr <= "0111";
      wait for clk_period;
         s_NewExtEvent <= '0';
         
      wait;
   end process;
   
   ReadyForEvent_process : process(s_rst, s_clk)
   begin
      if s_rst = '1' then
         s_NewEvent_d <= '0';
         s_NewEvent_dd <= '0';
      elsif rising_edge(s_clk) then
         
         s_NewEvent_d <= s_NewEvent;
         s_NewEvent_dd <= s_NewEvent_d;
         
      end if;
   end process;
   s_ReadyForEvent <= not (s_NewEvent or s_NewEvent_d or s_NewEvent_dd);

   MailBox_EventsManager_tb : MailBox_EventsManager
   port map
   (
      clk_i             => s_clk,
      rst_i             => s_rst,
      NewTimeEvent_i    => s_NewTimeEvent,
      TimeEventAddr_i   => s_TimeEventAddr,
      NewExtEvent_i     => s_NewExtEvent,
      ExtEventAddr_i    => s_ExtEventAddr,
      NewEvent_o        => s_NewEvent,
      EventAddr_o       => s_EventAddr,
      ReadyForEvent_i   => s_ReadyForEvent
   );

end MailBox_EventsManager_tb_behavior;
