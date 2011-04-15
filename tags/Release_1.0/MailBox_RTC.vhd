----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     MailBox_RTC
--
-- Description:        
--
-- 
-- Create Date:     19/07/2009
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
        GlobalClockFrequency    : integer := 50000000;    -- Fréquence de l'horloge globale
        RTCClockFrequency       : integer := 1000;      -- Fréquence de l'horloge de datation
        RTC_time_Width          : integer := 16
    );
    port
    (
        clk         : in std_logic;
        rst         : in std_logic;
        RTC_time    : out std_logic_vector(RTC_time_Width - 1 downto 0)
    );
end MailBox_RTC;

architecture MailBox_RTC_behavior of MailBox_RTC is

    constant RTCClockPeriode    : integer := integer(real(GlobalClockFrequency)/real(RTCClockFrequency));

    signal clk_periode_counter  : std_logic_vector(integer(ceil(log2(real(RTCClockPeriode)))) - 1 downto 0);
    signal RTC_time_count       : std_logic_vector(RTC_time_Width - 1 downto 0);
    
begin

    clk_periode_counter_process : process(rst, clk)
    begin
        if rst = '1' then
            clk_periode_counter <= std_logic_vector(to_unsigned(RTCClockPeriode, integer(ceil(log2(real(RTCClockPeriode))))));
        elsif rising_edge(clk) then
            if clk_periode_counter = 0 then
                clk_periode_counter <= std_logic_vector(to_unsigned(RTCClockPeriode, integer(ceil(log2(real(RTCClockPeriode))))));
            else
                clk_periode_counter <= clk_periode_counter - 1;
            end if;
        end if;
    end process;
    
    RTC_time_count_process : process(rst, clk)
    begin
        if rst = '1' then
            RTC_time_count <= (others => '0');
        elsif rising_edge(clk) then
            if clk_periode_counter = 0 then
                RTC_time_count <= RTC_time_count + 1;
            end if;
        end if;
    end process;
    RTC_time <= RTC_time_count;

end MailBox_RTC_behavior;