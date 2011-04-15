----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    wb_MailBox_Pack
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

package MailBox_Pack is

   constant Recurrence_Addr   : std_logic_vector(1 downto 0) := "00";
   constant Timetable_Addr    : std_logic_vector(1 downto 0) := "01";
   constant DatingTable_Addr   : std_logic_vector(1 downto 0) := "10";
   constant DataTable_Addr    : std_logic_vector(1 downto 0) := "11";

   component MailBox
      generic
      (
         g_RTCClockPeriode : std_logic_vector;  -- Durée d'une période de l'horloge de datation - 1
         WB_Addr_Width         : integer;
         WB_Data_Width         : integer;
         RTC_time_Width        : integer
      );
      port
      (
         wb_clk_i      : in std_logic;
         wb_rst_i      : in std_logic;
         
      -- Settings and Data Read Interface
         wb_we_i_User   : in std_logic;
         wb_adr_i_User  : in std_logic_vector(WB_Addr_Width + 2 downto 0);
         wb_dat_i_User  : in std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_dat_o_User  : out std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_cyc_i_User  : in std_logic;
         wb_stb_i_User  : in std_logic;
         wb_ack_o_User  : out std_logic;
         wb_dtr_o_User  : out std_logic;   -- Data is available to be read
         wb_atr_o_User  : out std_logic_vector(WB_Addr_Width downto 0); -- Address at which Data should be read
         
      -- External Master Interface
         wb_we_o_Master  : out std_logic;
         wb_adr_o_Master : out std_logic_vector(WB_Addr_Width - 1 downto 0);
         wb_dat_o_Master : out std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_dat_i_Master : in std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_cyc_o_Master : out std_logic;
         wb_stb_o_Master : out std_logic;
         wb_ack_i_Master : in std_logic;
      
         RTCTime_o      : out std_logic_vector(RTC_time_Width - 1 downto 0)
      );
   end component;

   component MailBox_Sequencer
      generic
      (
         WB_Addr_Width   : integer;
         WB_Data_Width   : integer;
         RTC_time_Width  : integer
      );
      port
      (
         wb_clk_i            : in std_logic;
         wb_rst_i            : in std_logic;
         
      -- Interface Recurrence Table
         wb_adr_o_Recurrence    : out std_logic_vector(WB_Addr_Width downto 0);
         wb_dat_i_Recurrence    : in std_logic_vector(RTC_time_Width - 1 downto 0);
         wb_cyc_o_Recurrence    : out std_logic;
         wb_stb_o_Recurrence    : out std_logic;
         wb_ack_i_Recurrence    : in std_logic;
         wb_vld_i_Recurrence    : in std_logic;
         
      -- Interface Timetable
         wb_we_o_Timetable      : out std_logic;
         wb_adr_o_Timetable     : out std_logic_vector(WB_Addr_Width downto 0);
         wb_dat_o_Timetable     : out std_logic_vector(RTC_time_Width - 1 downto 0);
         wb_dat_i_Timetable     : in std_logic_vector(RTC_time_Width - 1 downto 0);
         wb_cyc_o_Timetable     : out std_logic;
         wb_stb_o_Timetable     : out std_logic;
         wb_ack_i_Timetable     : in std_logic;
         wb_vld_o_Timetable     : out std_logic;
         wb_vld_i_Timetable     : in std_logic;
         
      -- Interface DatingTable
         wb_we_o_DatingTable    : out std_logic;
         wb_adr_o_DatingTable   : out std_logic_vector(WB_Addr_Width downto 0);
         wb_dat_o_DatingTable   : out std_logic_vector(RTC_time_Width - 1 downto 0);
         wb_cyc_o_DatingTable   : out std_logic;
         wb_stb_o_DatingTable   : out std_logic;
         wb_ack_i_DatingTable   : in std_logic;
         
      -- Interface DataTable
         wb_we_o_DataTable      : out std_logic;
         wb_adr_o_DataTable     : out std_logic_vector(WB_Addr_Width downto 0);
         wb_dat_o_DataTable     : out std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_dat_i_DataTable     : in std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_cyc_o_DataTable     : out std_logic;
         wb_stb_o_DataTable     : out std_logic;
         wb_ack_i_DataTable     : in std_logic;
         
      -- Interface AddrToRead
         wb_we_o_AddrToRead     : out std_logic;
         wb_dat_o_AddrToRead    : out std_logic_vector(WB_Addr_Width downto 0);
         wb_cyc_o_AddrToRead    : out std_logic;
         wb_stb_o_AddrToRead    : out std_logic;
         wb_ack_i_AddrToRead    : in std_logic;
         
      -- Interface Master Exterieur
         wb_we_o_Master        : out std_logic;
         wb_adr_o_Master       : out std_logic_vector(WB_Addr_Width - 1 downto 0);
         wb_dat_o_Master       : out std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_dat_i_Master       : in std_logic_vector(WB_Data_Width - 1 downto 0);
         wb_cyc_o_Master       : out std_logic;
         wb_stb_o_Master       : out std_logic;
         wb_ack_i_Master       : in std_logic;
         
      -- RTC interface
         RTC_time            : in std_logic_vector(RTC_time_Width - 1 downto 0)
      );
   end component;
   
   component MailBox_Recurrence
      port
      (
         wb_clk_i       : in std_logic;
         wb_rst_i       : in std_logic;
         
      -- Interface A
         wb_we_usr_i    : in std_logic;
         wb_adr_usr_i   : in std_logic_vector;
         wb_dat_usr_i   : in std_logic_vector;
         wb_dat_usr_o   : out std_logic_vector;
         wb_cyc_usr_i   : in std_logic;
         wb_stb_usr_i   : in std_logic;
         wb_ack_usr_o   : out std_logic;
         
      -- Interface B
         wb_adr_seq_i   : in std_logic_vector;
         wb_dat_seq_o   : out std_logic_vector;
         wb_cyc_seq_i   : in std_logic;
         wb_stb_seq_i   : in std_logic;
         wb_ack_seq_o   : out std_logic;
         wb_vld_seq_o   : out std_logic   -- Indique si la valeur lue est valide
      );
   end component;
   
   component MailBox_Timetable
      port
      (
         wb_clk_i       : in std_logic;
         wb_rst_i       : in std_logic;
         
      -- Interface A
         wb_we_usr_i    : in std_logic;
         wb_adr_usr_i   : in std_logic_vector;
         wb_dat_usr_i   : in std_logic_vector;
         wb_dat_usr_o   : out std_logic_vector;
         wb_cyc_usr_i   : in std_logic;
         wb_stb_usr_i   : in std_logic;
         wb_ack_usr_o   : out std_logic;
         
      -- Interface B
         wb_we_seq_i    : in std_logic;
         wb_adr_seq_i   : in std_logic_vector;
         wb_dat_seq_i   : in std_logic_vector;
         wb_dat_seq_o   : out std_logic_vector;
         wb_cyc_seq_i   : in std_logic;
         wb_stb_seq_i   : in std_logic;
         wb_ack_seq_o   : out std_logic;
         wb_vld_seq_i   : in std_logic;   -- Indique que la valeur n'est plus valide
         wb_vld_seq_o   : out std_logic   -- Indique si la valeur lue est valide
      );
   end component;
   
   component MailBox_RTC
      generic
      (
         g_RTCClockPeriode : std_logic_vector   -- Durée d'une période de l'horloge de datation - 1
      );
      port
      (
         clk_i       : in std_logic;
         rst_i       : in std_logic;
         RTC_time_o  : out std_logic_vector
      );
   end component;
   
   component MailBox_AddrToRead
      port
      (
         wb_clk_i    : in std_logic;
         wb_rst_i    : in std_logic;
         
      -- Input Interface
         wb_we_i     : in std_logic;
         wb_dat_i    : in std_logic_vector;
         wb_cyc_i    : in std_logic;
         wb_stb_i    : in std_logic;
         wb_ack_o    : out std_logic;
         
      -- Output Interface
         Read_i      : in std_logic; -- Current address is being read
         Addr_o      : out std_logic_vector;
         AddrAvail_o : out std_logic -- Address Available to be read
      );
   end component;
   
   component MailBox_DualPortRAM
      port
      (
         wb_clk_i    : in std_logic;
         wb_rst_i    : in std_logic;
         
      -- Interface A
         wb_we_A_i   : in std_logic;
         wb_adr_A_i  : in std_logic_vector;
         wb_dat_A_i  : in std_logic_vector;
         wb_dat_A_o  : out std_logic_vector;
         wb_cyc_A_i  : in std_logic;
         wb_stb_A_i  : in std_logic;
         wb_ack_A_o  : out std_logic;
         
      -- Interface B
         wb_we_B_i  : in std_logic;
         wb_adr_B_i : in std_logic_vector;
         wb_dat_B_i : in std_logic_vector;
         wb_dat_B_o : out std_logic_vector;
         wb_cyc_B_i : in std_logic;
         wb_stb_B_i : in std_logic;
         wb_ack_B_o : out std_logic
      );
   end component;
   
   component MailBox_FIFO
      generic
      (
         g_FIFOSize  : std_logic_vector := X"3FF"  -- Nombre d'éléments de la FIFO - 1
      );
      port
      (
         rst_i    : in std_logic;
         clk_i    : in std_logic;
         
         WE_i     : in std_logic;
         Data_i   : in std_logic_vector;
         RE_i     : in std_logic;
         Data_o   : out std_logic_vector;
         
         Empty_o  : out std_logic;
         Full_o   : out std_logic
      );
   end component;

end MailBox_Pack;
