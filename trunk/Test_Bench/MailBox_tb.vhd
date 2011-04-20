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

library MailBox_Lib;
use MailBox_Lib.MailBox_Pack.all;

entity MailBox_tb is
   generic
   (
      g_RTCClockPeriode    : std_logic_vector := "100";
      g_WB_Addr_Width         : integer := 4;
      g_WB_Data_Width         : integer := 32;
      g_RTC_time_Width        : integer := 16
   );
end MailBox_tb;

architecture behavior of MailBox_tb is
   
   signal s_clk   : std_logic := '1';
   signal s_rst   : std_logic := '1';
   
-- Settings and Data Read Interface
   signal s_wb_we_UserToUut   : std_logic := '0';
   signal s_wb_adr_UserToUut  : std_logic_vector(g_WB_Addr_Width + 2 downto 0) := (others => '0');
   signal s_wb_dat_UserToUut  : std_logic_vector(g_WB_Data_Width - 1 downto 0) := (others => '0');
   signal s_wb_dat_UutToUser  : std_logic_vector(g_WB_Data_Width - 1 downto 0);
   signal s_wb_cyc_UserToUut  : std_logic := '0';
   signal s_wb_stb_UserToUut  : std_logic := '0';
   signal s_wb_ack_UutToUser  : std_logic;
   signal s_DataAvailable     : std_logic;   -- Data is available to be read
   signal s_AddrToRead        : std_logic_vector(g_WB_Addr_Width downto 0); -- Address at which Data should be read
   
-- External Master Interface
   signal s_wb_we_UutToSlave  : std_logic;
   signal s_wb_adr_UutToSlave : std_logic_vector(g_WB_Addr_Width - 1 downto 0);
   signal s_wb_dat_UutToSlave : std_logic_vector(g_WB_Data_Width - 1 downto 0);
   signal s_wb_dat_SlaveToUut : std_logic_vector(g_WB_Data_Width - 1 downto 0) := X"87654321";
   signal s_wb_cyc_UutToSlave : std_logic;
   signal s_wb_stb_UutToSlave : std_logic;
   signal s_wb_ack_SlaveToUut : std_logic;
   signal s_wb_ack_SlaveToUut_int : std_logic;
   
-- External trigger interface
   signal s_ExtTrigger  : std_logic_vector(2**g_WB_Addr_Width - 1 downto 0) := (others => '0');
   
-- RTC value
   signal s_RTCTime  : std_logic_vector(g_RTC_time_Width - 1 downto 0);
   
   
   constant c_ClkPeriod : time := 20 ns;   -- 50 MHz

begin

   s_rst <= '0' after 53 ns;
   s_clk <= not s_clk after c_ClkPeriod/2;
   
   process
   begin
      -- write read date
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '1';
      s_wb_adr_UserToUut <= "01" & "0" & "1011";
      s_wb_dat_UserToUut <= X"00000003";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      -- write read recurrence
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '1';
      s_wb_adr_UserToUut <= "00" & "0" & "1011";
      s_wb_dat_UserToUut <= X"00000010";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      
      -- write write date
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '1';
      s_wb_adr_UserToUut <= "01" & "1" & "1011";
      s_wb_dat_UserToUut <= X"00000016";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      -- write write recurrence
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '1';
      s_wb_adr_UserToUut <= "00" & "1" & "1011";
      s_wb_dat_UserToUut <= X"00000050";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      -- write write data
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '1';
      s_wb_adr_UserToUut <= "11" & "1" & "1011";
      s_wb_dat_UserToUut <= X"12345678";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      
      wait for 1 ms;
      
      -- read read date
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '0';
      s_wb_adr_UserToUut <= "10" & "0" & "1011";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      -- read read data
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '0';
      s_wb_adr_UserToUut <= "11" & "0" & "1011";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      
      -- read write date
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '0';
      s_wb_adr_UserToUut <= "10" & "1" & "1011";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      -- read write data
      wait for 10*c_ClkPeriod;
      s_wb_we_UserToUut <= '0';
      s_wb_adr_UserToUut <= "11" & "1" & "1011";
      s_wb_cyc_UserToUut <= '1';
      s_wb_stb_UserToUut <= '1';
      wait on s_wb_ack_UutToUser;
      wait on s_wb_ack_UutToUser;
      s_wb_we_UserToUut <= '0';
      s_wb_cyc_UserToUut <= '0';
      s_wb_stb_UserToUut <= '0';
      
      wait;
   end process;

   Master_Interface_Ack_process : process(s_rst, s_clk)
   begin
      if s_rst = '1' then
         s_wb_ack_SlaveToUut_int <= '0';
      elsif rising_edge(s_clk) then
         s_wb_ack_SlaveToUut_int <= '0';
         if s_wb_cyc_UutToSlave = '1' and s_wb_stb_UutToSlave = '1' and s_wb_ack_SlaveToUut_int = '0' then
            s_wb_ack_SlaveToUut_int <= '1';
         end if;
      end if;
   end process;
   s_wb_ack_SlaveToUut <= s_wb_ack_SlaveToUut_int;
   
   MailBox_tb : MailBox
   generic map
   (
      g_RTCClockPeriode => g_RTCClockPeriode,
      WB_Addr_Width => g_WB_Addr_Width,
      WB_Data_Width => g_WB_Data_Width,
      RTC_time_Width => g_RTC_time_Width
   )
   port map
   (
      wb_clk_i          => s_clk,
      wb_rst_i          => s_rst,
      
      wb_we_User_i      => s_wb_we_UserToUut,
      wb_adr_User_i     => s_wb_adr_UserToUut,
      wb_dat_User_i     => s_wb_dat_UserToUut,
      wb_dat_User_o     => s_wb_dat_UutToUser,
      wb_cyc_User_i     => s_wb_cyc_UserToUut,
      wb_stb_User_i     => s_wb_stb_UserToUut,
      wb_ack_User_o     => s_wb_ack_UutToUser,
   
      DataAvailable_o   => s_DataAvailable,
      AddrToRead_o      => s_AddrToRead,
      
      wb_we_Master_o    => s_wb_we_UutToSlave,
      wb_adr_Master_o   => s_wb_adr_UutToSlave,
      wb_dat_Master_i   => s_wb_dat_UutToSlave,
      wb_dat_Master_o   => s_wb_dat_SlaveToUut,
      wb_cyc_Master_o   => s_wb_cyc_UutToSlave,
      wb_stb_Master_o   => s_wb_stb_UutToSlave,
      wb_ack_Master_i   => s_wb_ack_SlaveToUut,
   
   -- External trigger interface
      ExtTrigger_i      => s_ExtTrigger,
      
   -- RTC value
      RTCTime_o         => s_RTCTime
   );

end behavior;
