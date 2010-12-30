----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     MailBox_AddrToRead
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
-- use ieee.math_real.all;

library MailBox_Lib;
use MailBox_Lib.MailBox_Pack.all;

entity MailBox_AddrToRead is
    generic
    (
        WB_Addr_Width   : integer := 4
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
end MailBox_AddrToRead;

architecture MailBox_AddrToRead_behavior of MailBox_AddrToRead is
    
    signal AddrToRead_vector    : std_logic_vector(2**(WB_Addr_Width + 1) - 1 downto 0);

    signal Write_en     : std_logic;
    signal Read_en      : std_logic;
    signal FIFO_Empty   : std_logic;
    signal FIFO_Full    : std_logic;
    
    signal wb_ack_o_Input_int   : std_logic;
    
    signal AddrToRead_int   : std_logic_vector(WB_Addr_Width downto 0);
    
begin

--===========================================================================
--         Filtrage des données  
--===========================================================================
    
    -- On mémorise les données qui sont présentes dans la FIFO
    process(wb_rst_i, wb_clk_i)
    begin
        if wb_rst_i = '1' then
            AddrToRead_vector <= (others => '0');
        elsif rising_edge(wb_clk_i) then
        
            if wb_cyc_i_Input = '1' and
               wb_stb_i_Input = '1' and
               wb_we_i_Input = '1' and
               wb_ack_o_Input_int = '0' then
                AddrToRead_vector(to_integer(unsigned(wb_dat_i_Input))) <= '1';
            end if;
            
            if AddrRead = '1' then
                AddrToRead_vector(to_integer(unsigned(AddrToRead_int))) <= '0';
            end if;
            
        end if;
    end process;

--===========================================================================
--         FIFO wishbone
--===========================================================================

    Input_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_o_Input_int <= '0';
            else
                wb_ack_o_Input_int <= '0';
                if wb_cyc_i_Input = '1' and wb_stb_i_Input = '1' and wb_ack_o_Input_int = '0' then
                    wb_ack_o_Input_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_o_Input <= wb_ack_o_Input_int;
    
    -- On n'écrit la donnée que si elle n'est pas déja dans la FIFO
    Write_en <= wb_cyc_i_Input and wb_stb_i_Input and wb_we_i_Input and (not wb_ack_o_Input_int) and (not AddrToRead_vector(to_integer(unsigned(wb_dat_i_Input))));
    
    Read_en <= AddrRead;

    FIFO_inst : MailBox_FIFO
    generic map
    (
        FIFOSize => 2**(WB_Addr_Width + 1),
        Data_Width => WB_Addr_Width + 1
    )
    port map
    (
        rst => wb_rst_i,
        clk => wb_clk_i,
        Write_en => Write_en,
        Data_in => wb_dat_i_Input,
        Read_en => Read_en,
        Data_out => AddrToRead_int,
        FIFO_Empty => FIFO_Empty,
        FIFO_Full => open
    );
    AddrToRead <= AddrToRead_int;
    AddrAvailable <= not FIFO_Empty;

end MailBox_AddrToRead_behavior;