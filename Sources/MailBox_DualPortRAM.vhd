----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_DualPortRAM
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

library MailBox_Lib;
use MailBox_Lib.MailBox_Pack.all;

entity MailBox_DualPortRAM is
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
end MailBox_DualPortRAM;

architecture MailBox_DualPortRAM_behavior of MailBox_DualPortRAM is
   
   type t_RAM is array ((2**wb_adr_A_i'length) - 1 downto 0) of std_logic_vector(wb_dat_A_i'range);
   
   impure function FillRAM return t_RAM is
      variable RAM : t_RAM;
   begin
      for I in t_RAM'range loop
         RAM(I) := (others => '0');
      end loop;
      return RAM;
   end function;
   
   shared variable v_Table : t_RAM := FillRAM;
   
   signal s_wb_ack_A : std_logic;
   signal s_wb_ack_B : std_logic;
   
begin
   
   --
   -- Assert
   --
   assert wb_adr_A_i'length = wb_adr_B_i'length -- On vérifie que les bus d'adresse ont la même taille
      report "Both address buses shall have the same size"
      severity failure;
      
   assert wb_dat_A_i'length = wb_dat_A_o'length
      and wb_dat_A_i'length = wb_dat_B_i'length
      and wb_dat_A_o'length = wb_dat_B_o'length -- On vérifie que les bus de donnée ont la même taille
      report "the four data buses shall have the same size"
      severity failure;
   
   -- Gestion de l'interface A
   A_Interface_Data_process : process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_cyc_A_i = '1' and wb_stb_A_i = '1' then
            if wb_we_A_i = '1' then
               v_Table(to_integer(unsigned(wb_adr_A_i))) := wb_dat_A_i;
            else
               wb_dat_A_o <= v_Table(to_integer(unsigned(wb_adr_A_i)));
            end if;
         end if;
      end if;
   end process;
   
   A_Interface_Ack_process : process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
         s_wb_ack_A <= '0';
      elsif rising_edge(wb_clk_i) then
         s_wb_ack_A <= '0';
         
         if wb_cyc_A_i = '1' and wb_stb_A_i = '1' and s_wb_ack_A = '0' then
            s_wb_ack_A <= '1';
         end if;
         
      end if;
   end process;
   wb_ack_A_o <= s_wb_ack_A;

   -- Gestion de l'interface B
   B_Interface_Data_process : process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_cyc_B_i = '1' and wb_stb_B_i = '1' then
            if wb_we_B_i = '1' then
               v_Table(to_integer(unsigned(wb_adr_B_i))) := wb_dat_B_i;
            else
               wb_dat_B_o <= v_Table(to_integer(unsigned(wb_adr_B_i)));
            end if;
         end if;
      end if;
   end process;
   
   B_Interface_Ack_process : process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
         s_wb_ack_B <= '0';
      elsif rising_edge(wb_clk_i) then
         s_wb_ack_B <= '0';
         
         if wb_cyc_B_i = '1' and wb_stb_B_i = '1' and s_wb_ack_B = '0' then
            s_wb_ack_B <= '1';
         end if;
         
      end if;
   end process;
   wb_ack_B_o <= s_wb_ack_B;

end MailBox_DualPortRAM_behavior;