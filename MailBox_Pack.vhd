----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     wb_MailBox_Pack
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

library MailBox_Lib;

package MailBox_Pack is

    constant Recurrence_Addr    : std_logic_vector(1 downto 0) := "00";
    constant Timetable_Addr     : std_logic_vector(1 downto 0) := "01";
    constant DatingTable_Addr   : std_logic_vector(1 downto 0) := "10";
    constant DataTable_Addr     : std_logic_vector(1 downto 0) := "11";

    component MailBox
        generic
        (
            GlobalClockFrequency    : integer;	-- Fréquence de l'horloge globale
            RTCClockFrequency	    : integer;  -- Fréquence de l'horloge de datation
            WB_Addr_Width           : integer;
            WB_Data_Width           : integer;
            RTC_time_Width          : integer
        );
        port
        (
            wb_clk_i        : in std_logic;
            wb_rst_i        : in std_logic;
            
        -- Settings and Data Read Interface
            wb_we_i_Slave   : in std_logic;
            wb_adr_i_Slave  : in std_logic_vector(WB_Addr_Width + 2 downto 0);
            wb_dat_i_Slave  : in std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_dat_o_Slave  : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_i_Slave  : in std_logic;
            wb_stb_i_Slave  : in std_logic;
            wb_ack_o_Slave  : out std_logic;
            wb_dtr_o_Slave  : out std_logic;    -- Data is available to be read
            wb_atr_o_Slave  : out std_logic_vector(WB_Addr_Width downto 0); -- Address at which Data should be read
            
        -- External Master Interface
            wb_we_o_Master  : out std_logic;
            wb_adr_o_Master : out std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_o_Master : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_dat_i_Master : in std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_o_Master : out std_logic;
            wb_stb_o_Master : out std_logic;
            wb_ack_i_Master : in std_logic;
        
            RTC_time        : out std_logic_vector(RTC_time_Width - 1 downto 0)
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
            wb_clk_i                : in std_logic;
            wb_rst_i                : in std_logic;
            
        -- Interface Recurrence Table
            wb_adr_o_Recurrence     : out std_logic_vector(WB_Addr_Width downto 0);
            wb_dat_i_Recurrence     : in std_logic_vector(RTC_time_Width - 1 downto 0);
            wb_cyc_o_Recurrence     : out std_logic;
            wb_stb_o_Recurrence     : out std_logic;
            wb_ack_i_Recurrence     : in std_logic;
            wb_vld_i_Recurrence     : in std_logic;
            
        -- Interface Timetable
            wb_we_o_Timetable       : out std_logic;
            wb_adr_o_Timetable      : out std_logic_vector(WB_Addr_Width downto 0);
            wb_dat_o_Timetable      : out std_logic_vector(RTC_time_Width - 1 downto 0);
            wb_dat_i_Timetable      : in std_logic_vector(RTC_time_Width - 1 downto 0);
            wb_cyc_o_Timetable      : out std_logic;
            wb_stb_o_Timetable      : out std_logic;
            wb_ack_i_Timetable      : in std_logic;
            wb_vld_o_Timetable      : out std_logic;
            wb_vld_i_Timetable      : in std_logic;
            
        -- Interface DatingTable
            wb_we_o_DatingTable     : out std_logic;
            wb_adr_o_DatingTable    : out std_logic_vector(WB_Addr_Width downto 0);
            wb_dat_o_DatingTable    : out std_logic_vector(RTC_time_Width - 1 downto 0);
            wb_cyc_o_DatingTable    : out std_logic;
            wb_stb_o_DatingTable    : out std_logic;
            wb_ack_i_DatingTable    : in std_logic;
            
        -- Interface DataTable
            wb_we_o_DataTable       : out std_logic;
            wb_adr_o_DataTable      : out std_logic_vector(WB_Addr_Width downto 0);
            wb_dat_o_DataTable      : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_dat_i_DataTable      : in std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_o_DataTable      : out std_logic;
            wb_stb_o_DataTable      : out std_logic;
            wb_ack_i_DataTable      : in std_logic;
            
        -- Interface AddrToRead
            wb_we_o_AddrToRead      : out std_logic;
            wb_dat_o_AddrToRead     : out std_logic_vector(WB_Addr_Width downto 0);
            wb_cyc_o_AddrToRead     : out std_logic;
            wb_stb_o_AddrToRead     : out std_logic;
            wb_ack_i_AddrToRead     : in std_logic;
            
        -- Interface Master Exterieur
            wb_we_o_Master          : out std_logic;
            wb_adr_o_Master         : out std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_o_Master         : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_dat_i_Master         : in std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_o_Master         : out std_logic;
            wb_stb_o_Master         : out std_logic;
            wb_ack_i_Master         : in std_logic;
            
        -- RTC interface
            RTC_time                : in std_logic_vector(RTC_time_Width - 1 downto 0)
        );
    end component;
    
    component MailBox_Recurrence
        generic
        (
            WB_Addr_Width   : integer;
            WB_Data_Width   : integer
        );
        port
        (
            wb_clk_i        : in std_logic;
            wb_rst_i        : in std_logic;
            
        -- Interface A
            wb_we_i_A   : in std_logic;
            wb_adr_i_A  : in std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_i_A  : in std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_dat_o_A  : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_i_A  : in std_logic;
            wb_stb_i_A  : in std_logic;
            wb_ack_o_A  : out std_logic;
            
        -- Interface B
            wb_adr_i_B  : in std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_o_B  : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_i_B  : in std_logic;
            wb_stb_i_B  : in std_logic;
            wb_ack_o_B  : out std_logic;
            wb_vld_o_B  : out std_logic     -- Indique si la valeur lue est valide
        );
    end component;
    
    component MailBox_Timetable
        generic
        (
            WB_Addr_Width   : integer;
            WB_Data_Width   : integer
        );
        port
        (
            wb_clk_i        : in std_logic;
            wb_rst_i        : in std_logic;
            
        -- Interface A
            wb_we_i_A   : in std_logic;
            wb_adr_i_A  : in std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_i_A  : in std_logic_vector(WB_Data_Width - 1 downto 0) := (others => '0');
            wb_dat_o_A  : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_i_A  : in std_logic;
            wb_stb_i_A  : in std_logic;
            wb_ack_o_A  : out std_logic;
            
        -- Interface B
            wb_we_i_B   : in std_logic;
            wb_adr_i_B  : in std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_i_B  : in std_logic_vector(WB_Data_Width - 1 downto 0) := (others => '0');
            wb_dat_o_B  : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_i_B  : in std_logic;
            wb_stb_i_B  : in std_logic;
            wb_ack_o_B  : out std_logic;
            wb_vld_i_B  : in std_logic;
            wb_vld_o_B  : out std_logic
        );
    end component;
    
    component MailBox_RTC
        generic
        (
            GlobalClockFrequency    : integer;
            RTCClockFrequency	    : integer;
            RTC_time_Width          : integer
        );
        port
        (
            clk         : in std_logic;
            rst         : in std_logic;
            RTC_time    : out std_logic_vector(RTC_time_Width - 1 downto 0)
        );
    end component;
    
    component MailBox_AddrToRead
        generic
        (
            WB_Addr_Width   : integer
        );
        port
        (
            wb_clk_i        : in std_logic;
            wb_rst_i        : in std_logic;
            
        -- Input Interface
            wb_we_i_Input   : in std_logic;
            wb_dat_i_Input  : in std_logic_vector(WB_Addr_Width downto 0);
            wb_cyc_i_Input  : in std_logic;
            wb_stb_i_Input  : in std_logic;
            wb_ack_o_Input  : out std_logic;
            
        -- Output Interface
            AddrRead        : in std_logic; -- Current address is being read
            AddrToRead      : out std_logic_vector(WB_Addr_Width downto 0);
            AddrAvailable   : out std_logic -- Address Available to be read
        );
    end component;
    
    component MailBox_DualPortRAM
        generic
        (
            WB_Addr_Width   : integer;
            WB_Data_Width   : integer
        );
        port
        (
            wb_clk_i        : in std_logic;
            wb_rst_i        : in std_logic;
            
        -- Interface A
            wb_we_i_A   : in std_logic := '0';
            wb_adr_i_A  : in std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_i_A  : in std_logic_vector(WB_Data_Width - 1 downto 0) := (others => '0');
            wb_dat_o_A  : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_i_A  : in std_logic;
            wb_stb_i_A  : in std_logic;
            wb_ack_o_A  : out std_logic;
            
        -- Interface B
            wb_we_i_B  : in std_logic := '0';
            wb_adr_i_B : in std_logic_vector(WB_Addr_Width - 1 downto 0);
            wb_dat_i_B : in std_logic_vector(WB_Data_Width - 1 downto 0) := (others => '0');
            wb_dat_o_B : out std_logic_vector(WB_Data_Width - 1 downto 0);
            wb_cyc_i_B : in std_logic;
            wb_stb_i_B : in std_logic;
            wb_ack_o_B : out std_logic
        );
    end component;
    
    component MailBox_FIFO
        generic
        (
            FIFOSize        : integer;
            Data_Width      : integer
        );
        port
        (
            rst         : in std_logic;
            clk         : in std_logic;
            
            Write_en    : in std_logic;
            Data_in     : in std_logic_vector(Data_Width - 1 downto 0);
            Read_en     : in std_logic;
            Data_out    : out std_logic_vector(Data_Width - 1 downto 0);
            
            FIFO_Empty  : out std_logic;
            FIFO_Full   : out std_logic
        );
    end component;

end MailBox_Pack;
