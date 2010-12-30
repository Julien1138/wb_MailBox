----------------------------------------------------------------------------------
-- Engineer:        Julien Aupart
-- 
-- Module Name:     MailBox_Timetable
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

entity MailBox_Timetable is
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
        wb_we_i_A   : in std_logic;
        wb_adr_i_A  : in std_logic_vector(WB_Addr_Width - 1 downto 0);
        wb_dat_i_A  : in std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_dat_o_A  : out std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_cyc_i_A  : in std_logic;
        wb_stb_i_A  : in std_logic;
        wb_ack_o_A  : out std_logic;
        
    -- Interface B
        wb_we_i_B   : in std_logic;
        wb_adr_i_B  : in std_logic_vector(WB_Addr_Width - 1 downto 0);
        wb_dat_i_B  : in std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_dat_o_B  : out std_logic_vector(WB_Data_Width - 1 downto 0);
        wb_cyc_i_B  : in std_logic;
        wb_stb_i_B  : in std_logic;
        wb_ack_o_B  : out std_logic;
        wb_vld_i_B  : in std_logic;     -- Indique que la valeur n'est plus valide
        wb_vld_o_B  : out std_logic     -- Indique si la valeur lue est valide
    );
end MailBox_Timetable;

architecture MailBox_Timetable_behavior of MailBox_Timetable is
    
    signal Activated_Addresses  : std_logic_vector((2**WB_Addr_Width) - 1 downto 0);
    
begin
    
    Activated_Addresses_process : process(wb_rst_i, wb_clk_i)
    begin
        if wb_rst_i = '1' then
            Activated_Addresses <= (others => '0');
        elsif rising_edge(wb_clk_i) then
            if wb_we_i_A = '1' and
               wb_cyc_i_A = '1' and
               wb_stb_i_A = '1' then
                Activated_Addresses(to_integer(unsigned(wb_adr_i_A))) <= '1';
            end if;
            if wb_we_i_B = '1' and
               wb_cyc_i_B = '1' and
               wb_stb_i_B = '1' then
                if wb_vld_i_B = '0' then
                    Activated_Addresses(to_integer(unsigned(wb_adr_i_B))) <= '0';
                else
                    Activated_Addresses(to_integer(unsigned(wb_adr_i_B))) <= '1';
                end if;
            end if;
        end if;
    end process;
    
    wb_vld_o_B_process : process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) then
            if wb_rst_i = '1' then
                wb_vld_o_B <= '0';
            else
                if wb_cyc_i_B = '1' and wb_stb_i_B = '1' and wb_we_i_B = '0' then
                    wb_vld_o_B <= Activated_Addresses(to_integer(unsigned(wb_adr_i_B)));
                end if;
            end if;
        end if;
    end process;

    wb_DualPortRAM_inst : MailBox_DualPortRAM
    generic map
    (
        WB_Addr_Width => WB_Addr_Width,
        WB_Data_Width => WB_Data_Width
    )
    port map
    (
        wb_clk_i => wb_clk_i,
        wb_rst_i => wb_rst_i,
        wb_we_i_A => wb_we_i_A,
        wb_adr_i_A => wb_adr_i_A,
        wb_dat_i_A => wb_dat_i_A,
        wb_dat_o_A => wb_dat_o_A,
        wb_cyc_i_A => wb_cyc_i_A,
        wb_stb_i_A => wb_stb_i_A,
        wb_ack_o_A => wb_ack_o_A,
        wb_we_i_B => wb_we_i_B,
        wb_adr_i_B => wb_adr_i_B,
        wb_dat_i_B => wb_dat_i_B,
        wb_dat_o_B => wb_dat_o_B,
        wb_cyc_i_B => wb_cyc_i_B,
        wb_stb_i_B => wb_stb_i_B,
        wb_ack_o_B => wb_ack_o_B
    );

end MailBox_Timetable_behavior;