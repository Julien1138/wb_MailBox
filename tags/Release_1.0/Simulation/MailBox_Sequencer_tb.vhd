----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     MailBox_Sequencer_tb
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

library wb_MailBox_Lib;
use wb_MailBox_Lib.wb_MailBox_Pack.all;

entity MailBox_Sequencer_tb is
    generic
    (
        WB_Addr_Width   : integer := 4;
        WB_Data_Width   : integer := 8;
        RTC_time_Width  : integer := 16
    );
end MailBox_Sequencer_tb;

architecture behavior of MailBox_Sequencer_tb is

    signal wb_clk_i            : std_logic := '1';
    signal wb_rst_i            : std_logic := '1';
    
-- Interface Recurrence Table
    signal wb_we_o_Recurrence  : std_logic;
    signal wb_adr_o_Recurrence : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_i_Recurrence : std_logic_vector(RTC_time_Width - 1 downto 0) := X"0004";
    signal wb_cyc_o_Recurrence : std_logic;
    signal wb_stb_o_Recurrence : std_logic;
    signal wb_ack_i_Recurrence : std_logic := '0';
    signal wb_ack_i_Recurrence_int : std_logic := '0';
    
-- Interface Timetable
    signal wb_we_o_Timetable   : std_logic;
    signal wb_adr_o_Timetable  : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_o_Timetable  : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_dat_i_Timetable  : std_logic_vector(RTC_time_Width - 1 downto 0) := X"0001";
    signal wb_cyc_o_Timetable  : std_logic;
    signal wb_stb_o_Timetable  : std_logic;
    signal wb_ack_i_Timetable  : std_logic := '0';
    signal wb_ack_i_Timetable_int  : std_logic := '0';
        
-- Interface DatingTable
    signal wb_we_o_DatingTable     : std_logic;
    signal wb_adr_o_DatingTable    : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_o_DatingTable    : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal wb_cyc_o_DatingTable    : std_logic;
    signal wb_stb_o_DatingTable    : std_logic;
    signal wb_ack_i_DatingTable    : std_logic := '0';
    signal wb_ack_i_DatingTable_int    : std_logic := '0';
        
-- Interface DataTable
    signal wb_we_o_DataTable   : std_logic;
    signal wb_adr_o_DataTable  : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_dat_o_DataTable  : std_logic_vector(WB_Data_Width - 1 downto 0);
    signal wb_dat_i_DataTable  : std_logic_vector(WB_Data_Width - 1 downto 0) := X"52";
    signal wb_cyc_o_DataTable  : std_logic;
    signal wb_stb_o_DataTable  : std_logic;
    signal wb_ack_i_DataTable  : std_logic := '0';
    signal wb_ack_i_DataTable_int  : std_logic := '0';
    
-- Interface AddrToRead
    signal wb_we_o_AddrToRead   : std_logic;
    signal wb_dat_o_AddrToRead  : std_logic_vector(WB_Addr_Width downto 0);
    signal wb_cyc_o_AddrToRead  : std_logic;
    signal wb_stb_o_AddrToRead  : std_logic;
    signal wb_ack_i_AddrToRead  : std_logic := '0';
    signal wb_ack_i_AddrToRead_int  : std_logic := '0';
    
-- Interface Master Exterieur
    signal wb_we_o_Master      : std_logic;
    signal wb_adr_o_Master     : std_logic_vector(WB_Addr_Width - 1 downto 0);
    signal wb_dat_o_Master     : std_logic_vector(WB_Data_Width - 1 downto 0);
    signal wb_dat_i_Master     : std_logic_vector(WB_Data_Width - 1 downto 0) := X"3B";
    signal wb_cyc_o_Master     : std_logic;
    signal wb_stb_o_Master     : std_logic;
    signal wb_ack_i_Master     : std_logic := '0';
    signal wb_ack_i_Master_int     : std_logic := '0';
    
-- RTC interface
    signal RTC_time            : std_logic_vector(RTC_time_Width - 1 downto 0) := (others => '0');
    
    constant clk_period : time := 20 ns;    -- 50 MHz

begin

    wb_rst_i <= '0' after 53 ns;
    wb_clk_i <= not wb_clk_i after clk_period/2;

    RTC_time <= RTC_time + 1 after 1 ms;

    Recurrence_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_i_Recurrence_int <= '0';
            else
                wb_ack_i_Recurrence_int <= '0';
                if wb_cyc_o_Recurrence = '1' and wb_stb_o_Recurrence = '1' and wb_ack_i_Recurrence_int = '0' then
                    wb_ack_i_Recurrence_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_i_Recurrence <= wb_ack_i_Recurrence_int;

    DatingTable_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_i_DatingTable_int <= '0';
            else
                wb_ack_i_DatingTable_int <= '0';
                if wb_cyc_o_DatingTable = '1' and wb_stb_o_DatingTable = '1' and wb_ack_i_DatingTable_int = '0' then
                    wb_ack_i_DatingTable_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_i_DatingTable <= wb_ack_i_DatingTable_int;

    Timetable_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_i_Timetable_int <= '0';
            else
                wb_ack_i_Timetable_int <= '0';
                if wb_cyc_o_Timetable = '1' and wb_stb_o_Timetable = '1' and wb_ack_i_Timetable_int = '0' then
                    wb_ack_i_Timetable_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_i_Timetable <= wb_ack_i_Timetable_int;
    
    DataTable_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_i_DataTable_int <= '0';
            else
                wb_ack_i_DataTable_int <= '0';
                if wb_cyc_o_DataTable = '1' and wb_stb_o_DataTable = '1' and wb_ack_i_DataTable_int = '0' then
                    wb_ack_i_DataTable_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_i_DataTable <= wb_ack_i_DataTable_int;
    
    AddrToRead_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_i_AddrToRead_int <= '0';
            else
                wb_ack_i_AddrToRead_int <= '0';
                if wb_cyc_o_AddrToRead = '1' and wb_stb_o_AddrToRead = '1' and wb_ack_i_AddrToRead_int = '0' then
                    wb_ack_i_AddrToRead_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_i_AddrToRead <= wb_ack_i_AddrToRead_int;

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
    
    MailBox_Sequencer_tb : MailBox_Sequencer
    generic map
    (
        WB_Addr_Width => WB_Addr_Width,
        WB_Data_Width => WB_Data_Width,
        RTC_time_Width => RTC_time_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_we_o_Recurrence => wb_we_o_Recurrence,
        wb_adr_o_Recurrence => wb_adr_o_Recurrence,
        wb_dat_i_Recurrence => wb_dat_i_Recurrence,
        wb_cyc_o_Recurrence => wb_cyc_o_Recurrence,
        wb_stb_o_Recurrence => wb_stb_o_Recurrence,
        wb_ack_i_Recurrence => wb_ack_i_Recurrence,
        wb_we_o_Timetable => wb_we_o_Timetable,
        wb_adr_o_Timetable => wb_adr_o_Timetable,
        wb_dat_o_Timetable => wb_dat_o_Timetable,
        wb_dat_i_Timetable => wb_dat_i_Timetable,
        wb_cyc_o_Timetable => wb_cyc_o_Timetable,
        wb_stb_o_Timetable => wb_stb_o_Timetable,
        wb_ack_i_Timetable => wb_ack_i_Timetable,
        wb_we_o_DatingTable => wb_we_o_DatingTable,
        wb_adr_o_DatingTable => wb_adr_o_DatingTable,
        wb_dat_o_DatingTable => wb_dat_o_DatingTable,
        wb_cyc_o_DatingTable => wb_cyc_o_DatingTable,
        wb_stb_o_DatingTable => wb_stb_o_DatingTable,
        wb_ack_i_DatingTable => wb_ack_i_DatingTable,
        wb_we_o_DataTable => wb_we_o_DataTable,
        wb_adr_o_DataTable => wb_adr_o_DataTable,
        wb_dat_o_DataTable => wb_dat_o_DataTable,
        wb_dat_i_DataTable => wb_dat_i_DataTable,
        wb_cyc_o_DataTable => wb_cyc_o_DataTable,
        wb_stb_o_DataTable => wb_stb_o_DataTable,
        wb_ack_i_DataTable => wb_ack_i_DataTable,
        wb_we_o_AddrToRead => wb_we_o_AddrToRead,
        wb_dat_o_AddrToRead => wb_dat_o_AddrToRead,
        wb_cyc_o_AddrToRead => wb_cyc_o_AddrToRead,
        wb_stb_o_AddrToRead => wb_stb_o_AddrToRead,
        wb_ack_i_AddrToRead => wb_ack_i_AddrToRead,
        wb_we_o_Master => wb_we_o_Master,
        wb_adr_o_Master => wb_adr_o_Master,
        wb_dat_o_Master => wb_dat_o_Master,
        wb_dat_i_Master => wb_dat_i_Master,
        wb_cyc_o_Master => wb_cyc_o_Master,
        wb_stb_o_Master => wb_stb_o_Master,
        wb_ack_i_Master => wb_ack_i_Master,
        RTC_time => RTC_time
    );

end behavior;
