----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_RTC
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

entity MailBox_RTC is
   generic
   (
      g_RTCClockPeriode : std_logic_vector := X"C349" -- Durée d'une période de l'horloge de datation - 1
   );
   port
   (
      clk_i       : in std_logic;
      rst_i       : in std_logic;
      RTC_time_o  : out std_logic_vector
   );
end MailBox_RTC;

architecture MailBox_RTC_behavior of MailBox_RTC is

   signal s_ClkPeriodeCounter : std_logic_vector(g_RTCClockPeriode'range);
   signal s_RtcTimeCount      : std_logic_vector(RTC_time_o'range);
   
begin

   --
   --! ClkPeriodeCounter_process
   --
   ClkPeriodeCounter_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_ClkPeriodeCounter <= g_RTCClockPeriode;
      elsif rising_edge(clk_i) then
      
         if s_ClkPeriodeCounter = 0 then
            s_ClkPeriodeCounter <= g_RTCClockPeriode;
         else
            s_ClkPeriodeCounter <= s_ClkPeriodeCounter - 1;
         end if;
         
      end if;
   end process;
   
   --
   --! RtcTimeCount_process
   --
   RtcTimeCount_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_RtcTimeCount <= (others => '0');
      elsif rising_edge(clk_i) then
      
         if s_ClkPeriodeCounter = 0 then
            s_RtcTimeCount <= s_RtcTimeCount + 1;
         end if;
         
      end if;
   end process;
   RTC_time_o <= s_RtcTimeCount;

end MailBox_RTC_behavior;