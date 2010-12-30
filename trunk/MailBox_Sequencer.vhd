----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     MailBox_Sequencer
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

entity MailBox_Sequencer is
    generic
    (
        WB_Addr_Width   : integer := 4;
        WB_Data_Width   : integer := 8;
        RTC_time_Width  : integer := 16
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
        RTC_time                : in std_logic_vector(RTC_time_Width - 1 downto 0)  -- en ms
    );
end MailBox_Sequencer;

architecture MailBox_Sequencer_behavior of MailBox_Sequencer is
    
    signal Scan_counter : std_logic_vector(WB_Addr_Width downto 0);
    signal Scan_enable  : std_logic;
    
    signal RTC_time_Ret             : std_logic_vector(RTC_time_Width - 1 downto 0);    -- retardé de 2^(RTC_time_Width - 1)
    signal Schedule                 : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal Schedule_Next            : std_logic_vector(RTC_time_Width - 1 downto 0);
    signal Schedule_check_enable    : std_logic;
    signal Time_match               : std_logic;
    
    signal Write_Timetable      : std_logic;
    signal Write_DatingTable    : std_logic;
    signal Read_Write           : std_logic;
    signal Read_DataTable       : std_logic;
    signal Write_DataTable      : std_logic;
    signal Write_AddrToRead     : std_logic;
    signal Read_Master          : std_logic;
    signal Write_Master         : std_logic;
    
begin

--===========================================================================
--         Interfaces WishBone Master    
--===========================================================================

    -- Interface Timetable
    Timetable_Interface_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_we_o_Timetable <= '0';
                wb_cyc_o_Timetable <= '0';
                wb_stb_o_Timetable <= '0';
                wb_vld_o_Timetable <= '0';
            else
                if Scan_enable = '1' then
                    if wb_ack_i_Timetable = '0' then
                        wb_we_o_Timetable <= '0';
                        wb_cyc_o_Timetable <= '1';
                        wb_stb_o_Timetable <= '1';
                        wb_vld_o_Timetable <= '0';
                    else
                        wb_we_o_Timetable <= '0';
                        wb_cyc_o_Timetable <= '1'; -- on laisse à '1' pour la lecture en bloc
                        wb_stb_o_Timetable <= '0';
                        wb_vld_o_Timetable <= '0';
                    end if;
                elsif Write_Timetable = '1' then
                    if wb_ack_i_Timetable = '0' then
                        wb_we_o_Timetable <= '1';
                        wb_cyc_o_Timetable <= '1';
                        wb_stb_o_Timetable <= '1';
                        wb_vld_o_Timetable <= wb_vld_i_Recurrence;
                    else
                        wb_we_o_Timetable <= '0';
                        wb_cyc_o_Timetable <= '0';
                        wb_stb_o_Timetable <= '0';
                        wb_vld_o_Timetable <= '0';
                    end if;
                else
                    wb_we_o_Timetable <= '0';
                    wb_cyc_o_Timetable <= '0';
                    wb_stb_o_Timetable <= '0';
                    wb_vld_o_Timetable <= '0';
                end if;
            end if;
        end if;
    end process;
    wb_adr_o_Timetable <= Scan_counter;
    wb_dat_o_Timetable <= Schedule_Next;

    -- Interface Reccurence Table
    Reccurence_Interface_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_cyc_o_Recurrence <= '0';
                wb_stb_o_Recurrence <= '0';
            else
                if Scan_enable = '1' then
                    if wb_ack_i_Recurrence = '0' then
                        wb_cyc_o_Recurrence <= '1';
                        wb_stb_o_Recurrence <= '1';
                    else
                        wb_cyc_o_Recurrence <= '1'; -- on laisse à '1' pour la lecture en bloc
                        wb_stb_o_Recurrence <= '0';
                    end if;
                else
                    wb_cyc_o_Recurrence <= '0';
                    wb_stb_o_Recurrence <= '0';
                end if;
            end if;
        end if;
    end process;
    wb_adr_o_Recurrence <= Scan_counter;

    -- Interface Dating Table
    DatingTable_Interface_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_we_o_DatingTable <= '0';
                wb_cyc_o_DatingTable <= '0';
                wb_stb_o_DatingTable <= '0';
                wb_dat_o_DatingTable <= (others => '0');
            else
                if Write_DatingTable = '1' then
                    if wb_ack_i_DatingTable = '0' then
                        wb_we_o_DatingTable <= '1';
                        wb_cyc_o_DatingTable <= '1';
                        wb_stb_o_DatingTable <= '1';
                        wb_dat_o_DatingTable <= RTC_time;
                    else
                        wb_we_o_DatingTable <= '0';
                        wb_cyc_o_DatingTable <= '0';
                        wb_stb_o_DatingTable <= '0';
                    end if;
                else
                    wb_we_o_DatingTable <= '0';
                    wb_cyc_o_DatingTable <= '0';
                    wb_stb_o_DatingTable <= '0';
                end if;
            end if;
        end if;
    end process;
    wb_adr_o_DatingTable <= Scan_counter;
    
    -- Interface Data Table
    DataTable_Interface_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_we_o_DataTable <= '0';
                wb_cyc_o_DataTable <= '0';
                wb_stb_o_DataTable <= '0';
                wb_dat_o_Master <= (others => '0');
            else
                if Read_DataTable = '1' then
                    if wb_ack_i_DataTable = '0' then
                        wb_we_o_DataTable <= '0';
                        wb_cyc_o_DataTable <= '1';
                        wb_stb_o_DataTable <= '1';
                    else
                        wb_we_o_DataTable <= '0';
                        wb_cyc_o_DataTable <= '0';
                        wb_stb_o_DataTable <= '0';
                        wb_dat_o_Master <= wb_dat_i_DataTable;
                    end if;
                elsif Write_DataTable = '1' then
                    if wb_ack_i_DataTable = '0' then
                        wb_we_o_DataTable <= '1';
                        wb_cyc_o_DataTable <= '1';
                        wb_stb_o_DataTable <= '1';
                    else
                        wb_we_o_DataTable <= '0';
                        wb_cyc_o_DataTable <= '0';
                        wb_stb_o_DataTable <= '0';
                    end if;
                else
                    wb_we_o_DataTable <= '0';
                    wb_cyc_o_DataTable <= '0';
                    wb_stb_o_DataTable <= '0';
                end if;
            end if;
        end if;
    end process;
    wb_adr_o_DataTable <= Scan_counter;
    
    -- Interface AddrToRead
    AddrToRead_Interface_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_we_o_AddrToRead <= '0';
                wb_cyc_o_AddrToRead <= '0';
                wb_stb_o_AddrToRead <= '0';
                wb_dat_o_AddrToRead <= (others => '0');
            else
                if Write_AddrToRead = '1' then
                    if wb_ack_i_AddrToRead = '0' then
                        wb_we_o_AddrToRead <= '1';
                        wb_cyc_o_AddrToRead <= '1';
                        wb_stb_o_AddrToRead <= '1';
                        wb_dat_o_AddrToRead <= Scan_counter;
                    else
                        wb_we_o_AddrToRead <= '0';
                        wb_cyc_o_AddrToRead <= '0';
                        wb_stb_o_AddrToRead <= '0';
                    end if;
                else
                    wb_we_o_AddrToRead <= '0';
                    wb_cyc_o_AddrToRead <= '0';
                    wb_stb_o_AddrToRead <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- Interface Master Exterieur
    Master_Interface_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_we_o_Master <= '0';
                wb_cyc_o_Master <= '0';
                wb_stb_o_Master <= '0';
                wb_dat_o_DataTable <= (others => '0');
            else
                if Read_Master = '1' then
                    if wb_ack_i_Master = '0' then
                        wb_we_o_Master <= '0';
                        wb_cyc_o_Master <= '1';
                        wb_stb_o_Master <= '1';
                    else
                        wb_we_o_Master <= '0';
                        wb_cyc_o_Master <= '0';
                        wb_stb_o_Master <= '0';
                        wb_dat_o_DataTable <= wb_dat_i_Master;
                    end if;
                elsif Write_Master = '1' then
                    if wb_ack_i_Master = '0' then
                        wb_we_o_Master <= '1';
                        wb_cyc_o_Master <= '1';
                        wb_stb_o_Master <= '1';
                    else
                        wb_we_o_Master <= '0';
                        wb_cyc_o_Master <= '0';
                        wb_stb_o_Master <= '0';
                    end if;
                else
                    wb_we_o_Master <= '0';
                    wb_cyc_o_Master <= '0';
                    wb_stb_o_Master <= '0';
                end if;
            end if;
        end if;
    end process;
    wb_adr_o_Master <= Scan_counter(WB_Addr_Width - 1 downto 0);
    
--===========================================================================
--         Séquencement des opérations   
--===========================================================================

    -- Incrémentation du compteur de l'adresse en cours de scan
    Scan_process : process(wb_rst_i, wb_clk_i)
    begin
        if wb_rst_i = '1' then
            Scan_counter <= (others => '0');
        elsif rising_edge(wb_clk_i) then
            if (Scan_enable = '1'     and wb_ack_i_Timetable = '1') or  -- Dans le cas où il n'y a pas de Time_match
               (Write_DataTable = '1' and wb_ack_i_DataTable = '1') or  -- Dans le cas où il y a Time_match et Lecture sur le bus master
               (Write_Master = '1'    and wb_ack_i_Master = '1') then   -- Dans le cas où il y a Time_match et Ecriture sur le bus master
                Scan_counter <= Scan_counter + 1;
            end if;
        end if;
    end process;
    Scan_enable <= not (Time_match or Write_Timetable or Write_DatingTable or Write_AddrToRead or Read_DataTable or Write_DataTable or Read_Master or Write_Master);
    Read_Write <= Scan_counter(WB_Addr_Width); -- Le bit de poids fort de l'adresse correspond à l'opération à effectuer (lecture = '0' / ecriture = '1')

    -- Calcul des données temporelles 
    RTC_time_Ret <= RTC_time - std_logic_vector(to_unsigned(2**(RTC_time_Width - 1), RTC_time_Width));  -- Calcul de la fenêtre de comparaison de dates
    Schedule <= wb_dat_i_Timetable;
    Schedule_Next <= Schedule + wb_dat_i_Recurrence when wb_vld_i_Recurrence = '1' else (others => '0');
    
    -- Détection d'un Time_match
    Time_match_detection : process(Schedule_check_enable, RTC_time, RTC_time_Ret, Schedule)
    begin
        if Schedule_check_enable = '1' then
            if RTC_time_Ret < RTC_time then
                if Schedule <= RTC_time and Schedule > RTC_time_Ret then
                    Time_match <= '1';
                else
                    Time_match <= '0';
                end if;
            else
                if Schedule <= RTC_time or Schedule > RTC_time_Ret then
                    Time_match <= '1';
                else
                    Time_match <= '0';
                end if;
            end if;
        else
            Time_match <= '0';
        end if;
    end process;
    Schedule_check_enable <= wb_ack_i_Recurrence and wb_ack_i_Timetable and wb_vld_i_Timetable;
    
    -- Séquencement des différentes opérations sur les ports WishBone
    Operation_sequencer_process : process(wb_rst_i, wb_clk_i)
    begin
        if wb_rst_i = '1' then
            Write_Timetable <= '0';
            Write_DatingTable <= '0';
            Write_AddrToRead <= '0';
            Read_DataTable <= '0';
            Write_DataTable <= '0';
            Read_Master <= '0';
            Write_Master <= '0';
        elsif rising_edge(wb_clk_i) then
        
            if Time_match = '1' then
                Write_Timetable <= '1';
                Write_DatingTable <= '1';
                Write_AddrToRead <= '1';
                if Read_Write = '0' then    -- Read
                    Read_Master <= '1';
                else    -- Write
                    Read_DataTable <= '1';
                end if;
            end if;
            
            if Write_Timetable = '1' and wb_ack_i_Timetable = '1' then
                Write_Timetable <= '0';
            end if;
            
            if Write_DatingTable = '1' and wb_ack_i_DatingTable = '1' then
                Write_DatingTable <= '0';
            end if;
            
            if Write_AddrToRead = '1' and wb_ack_i_AddrToRead = '1' then
                Write_AddrToRead <= '0';
            end if;
            
            if Read_DataTable = '1' and wb_ack_i_DataTable = '1' then
                Read_DataTable <= '0';
                Write_Master <= '1';
            end if;
            
            if Write_Master = '1' and wb_ack_i_Master = '1' then
                Write_Master <= '0';
            end if;
            
            if Read_Master = '1' and wb_ack_i_Master = '1' then
                Read_Master <= '0';
                Write_DataTable <= '1';
            end if;
            
            if Write_DataTable = '1' and wb_ack_i_DataTable = '1' then
                Write_DataTable <= '0';
            end if;
            
        end if;
    end process;

end MailBox_Sequencer_behavior;