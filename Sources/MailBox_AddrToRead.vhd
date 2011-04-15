----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_Addr
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
-- use ieee.math_real.all;

library MailBox_Lib;
use MailBox_Lib.MailBox_Pack.all;

entity MailBox_AddrToRead is
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
end MailBox_AddrToRead;

architecture MailBox_AddrToRead_behavior of MailBox_AddrToRead is
   
   constant c_FIFOSize  : std_logic_vector(wb_dat_i'range) := (others => '1');
   
   signal s_StoredAddr  : std_logic_vector((2**wb_dat_i'length) - 1 downto 0);

   signal s_FIFOWrite   : std_logic;
   signal s_FIFORead    : std_logic;
   signal s_FIFOEmpty   : std_logic;
   
   signal s_wb_ack      : std_logic;
   
   signal s_AddrOut     : std_logic_vector(Addr_o'range);
   
begin

   --
   -- Assert
   --
   assert wb_dat_i'length = Addr_o'length -- On vérifie que les bus d'adresse/données ont la même taille
      report "Both buses shall have the same size"
      severity failure;
      
--===========================================================================
--       Filtrage des données
--===========================================================================
   
   -- On mémorise les données qui sont présentes dans la FIFO
   process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
         s_StoredAddr <= (others => '0');
      elsif rising_edge(wb_clk_i) then
      
         if wb_cyc_i = '1' and wb_stb_i = '1' and wb_we_i = '1' and s_wb_ack = '0' then
            s_StoredAddr(to_integer(unsigned(wb_dat_i))) <= '1';
         end if;
         
         if Read_i = '1' then
            s_StoredAddr(to_integer(unsigned(s_AddrOut))) <= '0';
         end if;
         
      end if;
   end process;

--===========================================================================
--       FIFO interface
--===========================================================================

   Input_Interface_Ack_process : process(wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i = '1' then
            s_wb_ack <= '0';
         else
            s_wb_ack <= '0';
            if wb_cyc_i = '1' and wb_stb_i = '1' and s_wb_ack = '0' then
               s_wb_ack <= '1';
            end if;
         end if;
      end if;
   end process;
   wb_ack_o <= s_wb_ack;
   
   -- On n'écrit la donnée que si elle n'est pas déja dans la FIFO
   s_FIFOWrite <= wb_cyc_i and wb_stb_i and wb_we_i and (not s_wb_ack) and (not s_StoredAddr(to_integer(unsigned(wb_dat_i))));
   
   s_FIFORead <= Read_i;

   FIFO_inst : MailBox_FIFO
   generic map
   (
      g_FIFOSize => c_FIFOSize
   )
   port map
   (
      rst_i    => wb_rst_i,
      clk_i    => wb_clk_i,
      WE_i     => s_FIFOWrite,
      Data_i   => wb_dat_i,
      RE_i     => s_FIFORead,
      Data_o   => s_AddrOut,
      Empty_o  => s_FIFOEmpty,
      Full_o   => open
   );
   Addr_o <= s_AddrOut;
   AddrAvail_o <= not s_FIFOEmpty;
   
end MailBox_AddrToRead_behavior;