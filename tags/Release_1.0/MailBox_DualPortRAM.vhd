----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     MailBox_DualPortRAM
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
use MailBox_Lib.MailBox_Pack.all;

entity MailBox_DualPortRAM is
    generic
    (
        WB_Addr_Width   : integer := 4;
        WB_Data_Width   : integer := 32
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
end MailBox_DualPortRAM;

architecture MailBox_DualPortRAM_behavior of MailBox_DualPortRAM is
    
    type ram_type is array ((2**WB_Addr_Width) - 1 downto 0) of std_logic_vector (WB_Data_Width - 1 downto 0);
    impure function FillRAM return ram_type is
        variable RAM : ram_type;
    begin
        for I in ram_type'range loop
            RAM(I) := (others => '0');
       end loop;
       return RAM;
    end function;
    shared variable Table : ram_type := FillRAM;
    
    signal wb_ack_o_A_int  : std_logic;
    signal wb_ack_o_B_int : std_logic;
    
begin

    -- Gestion de l'interface A
    A_Interface_Data_process : process (wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_cyc_i_A = '1' and wb_stb_i_A = '1' then
                if wb_we_i_A = '1' then
                    Table(to_integer(unsigned(wb_adr_i_A))) := wb_dat_i_A;
                else
                    wb_dat_o_A <= Table(to_integer(unsigned(wb_adr_i_A)));
                end if;
            end if;
        end if;
    end process;
    
    A_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_o_A_int <= '0';
            else
                wb_ack_o_A_int <= '0';
                if wb_cyc_i_A = '1' and wb_stb_i_A = '1' and wb_ack_o_A_int = '0' then
                    wb_ack_o_A_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_o_A <= wb_ack_o_A_int;

    -- Gestion de l'interface B
    B_Interface_Data_process : process (wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_cyc_i_B = '1' and wb_stb_i_B = '1' then
                if wb_we_i_B = '1' then
                    Table(to_integer(unsigned(wb_adr_i_B))) := wb_dat_i_B;
                else
                    wb_dat_o_B <= Table(to_integer(unsigned(wb_adr_i_B)));
                end if;
            end if;
        end if;
    end process;
    
    B_Interface_Ack_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_ack_o_B_int <= '0';
            else
                wb_ack_o_B_int <= '0';
                if wb_cyc_i_B = '1' and wb_stb_i_B = '1' and wb_ack_o_B_int = '0' then
                    wb_ack_o_B_int <= '1';
                end if;
            end if;
        end if;
    end process;
    wb_ack_o_B <= wb_ack_o_B_int;

end MailBox_DualPortRAM_behavior;