----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_tb
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

library wb_MailBox_Lib;
use wb_MailBox_Lib.wb_MailBox_Pack.all;

entity MailBox_tb is
   generic
   (
		g_RTCClockPeriode   : integer := 50000000;	-- Fréquence de l'horloge globale
		RTCClockFrequency	   : integer := 100000;    -- Fréquence de l'horloge de datation
      WB_Addr_Width         : integer := 4;
      WB_Data_Width         : integer := 32;
      RTC_time_Width        : integer := 16
   );
end MailBox_tb;

architecture behavior of MailBox_tb is
   
   signal wb_clk_i      : std_logic := '1';
   signal wb_rst_i      : std_logic := '1';
   
-- Settings and Data Read Interface
   signal wb_we_i_Slave   : std_logic := '0';
   signal wb_adr_i_Slave  : std_logic_vector(WB_Addr_Width + 2 downto 0) := (others => '0');
   signal wb_dat_i_Slave  : std_logic_vector(WB_Data_Width - 1 downto 0) := (others => '0');
   signal wb_dat_o_Slave  : std_logic_vector(WB_Data_Width - 1 downto 0);
   signal wb_cyc_i_Slave  : std_logic := '0';
   signal wb_stb_i_Slave  : std_logic := '0';
   signal wb_ack_o_Slave  : std_logic;
   signal wb_dtr_o_Slave  : std_logic;   -- Data is available to be read
   signal wb_atr_o_Slave  : std_logic_vector(WB_Addr_Width downto 0); -- Address at which Data should be read
   
-- External Master Interface
   signal wb_we_o_Master  : std_logic;
   signal wb_adr_o_Master : std_logic_vector(WB_Addr_Width - 1 downto 0);
   signal wb_dat_o_Master : std_logic_vector(WB_Data_Width - 1 downto 0);
   signal wb_dat_i_Master : std_logic_vector(WB_Data_Width - 1 downto 0) := X"87654321";
   signal wb_cyc_o_Master : std_logic;
   signal wb_stb_o_Master : std_logic;
   signal wb_ack_i_Master : std_logic;
   signal wb_ack_i_Master_int : std_logic;
         
   constant clk_period : time := 20 ns;   -- 50 MHz

begin

   wb_rst_i <= '0' after 53 ns;
   wb_clk_i <= not wb_clk_i after clk_period/2;
   
   process
   begin
      -- write read date
      wait for 10*clk_period;
      wb_we_i_Slave <= '1';
      wb_adr_i_Slave <= "01" & "0" & "1011";
      wb_dat_i_Slave <= X"00000003";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      -- write read recurrence
      wait for 10*clk_period;
      wb_we_i_Slave <= '1';
      wb_adr_i_Slave <= "00" & "0" & "1011";
      wb_dat_i_Slave <= X"00000010";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      
      -- write write date
      wait for 10*clk_period;
      wb_we_i_Slave <= '1';
      wb_adr_i_Slave <= "01" & "1" & "1011";
      wb_dat_i_Slave <= X"00000016";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      -- write write recurrence
      wait for 10*clk_period;
      wb_we_i_Slave <= '1';
      wb_adr_i_Slave <= "00" & "1" & "1011";
      wb_dat_i_Slave <= X"00000050";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      -- write write data
      wait for 10*clk_period;
      wb_we_i_Slave <= '1';
      wb_adr_i_Slave <= "11" & "1" & "1011";
      wb_dat_i_Slave <= X"12345678";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      
      wait for 1 ms;
      
      -- read read date
      wait for 10*clk_period;
      wb_we_i_Slave <= '0';
      wb_adr_i_Slave <= "10" & "0" & "1011";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      -- read read data
      wait for 10*clk_period;
      wb_we_i_Slave <= '0';
      wb_adr_i_Slave <= "11" & "0" & "1011";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      
      -- read write date
      wait for 10*clk_period;
      wb_we_i_Slave <= '0';
      wb_adr_i_Slave <= "10" & "1" & "1011";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      -- read write data
      wait for 10*clk_period;
      wb_we_i_Slave <= '0';
      wb_adr_i_Slave <= "11" & "1" & "1011";
      wb_cyc_i_Slave <= '1';
      wb_stb_i_Slave <= '1';
      wait on wb_ack_o_Slave;
      wait on wb_ack_o_Slave;
      wb_we_i_Slave <= '0';
      wb_cyc_i_Slave <= '0';
      wb_stb_i_Slave <= '0';
      
      wait;
   end process;

   Master_Interface_Ack_process : process(wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i = '1' then
            wb_ack_i_Master_int <= '0';
         else
            wb_ack_i_Master_int <= '0';
            if wb_cyc_o_Master = '1' and wb_stb_o_Master = '1' and wb_ack_i_Master_int = '0' then
               wb_ack_i_Master_int <= '1';
            end if;
         end if;
      end if;
   end process;
   wb_ack_i_Master <= wb_ack_i_Master_int;
   
   MailBox_tb : MailBox
   generic map
   (
      g_RTCClockPeriode => g_RTCClockPeriode,
      RTCClockFrequency => RTCClockFrequency,
      WB_Addr_Width => WB_Addr_Width,
      WB_Data_Width => WB_Data_Width,
      RTC_time_Width => RTC_time_Width
   )
   port map
   (
      wb_clk_i => wb_clk_i,
      wb_rst_i => wb_rst_i,
      wb_we_i_Slave => wb_we_i_Slave,
      wb_adr_i_Slave => wb_adr_i_Slave,
      wb_dat_i_Slave => wb_dat_i_Slave,
      wb_dat_o_Slave => wb_dat_o_Slave,
      wb_cyc_i_Slave => wb_cyc_i_Slave,
      wb_stb_i_Slave => wb_stb_i_Slave,
      wb_ack_o_Slave => wb_ack_o_Slave,
      wb_dtr_o_Slave => wb_dtr_o_Slave,
      wb_atr_o_Slave => wb_atr_o_Slave,
      wb_we_o_Master => wb_we_o_Master,
      wb_adr_o_Master => wb_adr_o_Master,
      wb_dat_o_Master => wb_dat_o_Master,
      wb_dat_i_Master => wb_dat_i_Master,
      wb_cyc_o_Master => wb_cyc_o_Master,
      wb_stb_o_Master => wb_stb_o_Master,
      wb_ack_i_Master => wb_ack_i_Master
   );

end behavior;
