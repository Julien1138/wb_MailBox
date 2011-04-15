----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_FIFO
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

entity MailBox_FIFO is
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
end MailBox_FIFO;

architecture MailBox_FIFO_behavior of MailBox_FIFO is

   type t_FIFO is array (to_integer(unsigned(g_FIFOSize)) downto 0) of std_logic_vector(Data_i'range);
   
   impure function FillMEM return t_FIFO is
      variable RAM : t_FIFO;
   begin
      for I in t_FIFO'range loop
         RAM(I) := (others => '0');
      end loop;
      return RAM;
   end function;
   
   signal s_FIFO : t_FIFO := FillMEM;
   
   signal s_WriteIdx       : std_logic_vector(g_FIFOSize'range);
   signal s_ReadIdx        : std_logic_vector(g_FIFOSize'range);
   signal s_NbrOfElements  : std_logic_vector(g_FIFOSize'range);
   
begin

   --
   -- Assert
   --
   assert Data_i'length = Data_o'length   -- On vérifie que les bus de données ont la même taille
      report "Both data buses shall have the same size"
      severity failure;

   Write_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_WriteIdx <= (others => '0');
      elsif rising_edge(clk_i) then
      
         if WE_i = '1' and s_NbrOfElements /= g_FIFOSize then
            s_FIFO(to_integer(unsigned(s_WriteIdx))) <= Data_i;
            s_WriteIdx <= s_WriteIdx + 1;
         end if;
         
      end if;
   end process;

   Read_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_ReadIdx <= (others => '0');
      elsif rising_edge(clk_i) then
      
         Data_o <= s_FIFO(to_integer(unsigned(s_ReadIdx)));
         
         if RE_i = '1' and s_NbrOfElements /= 0 then
            s_ReadIdx <= s_ReadIdx + 1;
         end if;
         
      end if;
   end process;
   
   s_NbrOfElements_process : process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         s_NbrOfElements <= (others => '0');
      elsif rising_edge(clk_i) then
      
         if WE_i = '1' and RE_i = '0' and s_NbrOfElements /= g_FIFOSize then
            s_NbrOfElements <= s_NbrOfElements + 1;
         elsif WE_i = '0' and RE_i = '1' and s_NbrOfElements /= 0 then
            s_NbrOfElements <= s_NbrOfElements - 1;
         else
            s_NbrOfElements <= s_NbrOfElements;
         end if;
         
      end if;
   end process;
   
   Empty_o <= '1' when s_NbrOfElements = 0 else
              '0';
              
   Full_o <= '1' when s_NbrOfElements = g_FIFOSize else
             '0';

end MailBox_FIFO_behavior;