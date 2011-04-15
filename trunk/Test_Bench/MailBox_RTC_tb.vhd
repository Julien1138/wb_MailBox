----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_RTC_tb
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

entity MailBox_RTC_tb is
   generic
   (
      g_RTCClockPeriode : std_logic_vector := X"13" -- Durée d'une période de l'horloge de datation - 1
   );
end MailBox_RTC_tb;

architecture behavior of MailBox_RTC_tb is

   signal s_clk      : std_logic := '1';
   signal s_rst      : std_logic := '1';
   
   signal s_RTC_time : std_logic_vector(15 downto 0);
   
   constant clk_period : time := 20 ns;   -- 50 MHz

begin

   s_rst <= '0' after 53 ns;
   s_clk <= not s_clk after clk_period/2;

   MailBox_RTC_tb : MailBox_RTC
   generic map
   (
      g_RTCClockPeriode => g_RTCClockPeriode
   )
   port map
   (
      clk_i       => s_clk,
      rst_i       => s_rst,
      RTC_time_o  => s_RTC_time
   );

end behavior;
