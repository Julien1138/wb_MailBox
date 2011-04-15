----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_Timetable
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

entity MailBox_Timetable is
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
end MailBox_Timetable;

architecture MailBox_Timetable_behavior of MailBox_Timetable is
   
   signal s_ActivatedAddresses   : std_logic_vector((2**wb_adr_usr_i'length) - 1 downto 0);
   
begin
   
   --
   -- Assert
   --
   assert wb_adr_usr_i'length = wb_adr_seq_i'length -- On vérifie que les bus d'adresse ont la même taille
      report "Both address buses shall have the same size"
      severity failure;
      
   assert wb_dat_usr_i'length = wb_dat_usr_o'length
      and wb_dat_usr_i'length = wb_dat_seq_i'length
      and wb_dat_usr_o'length = wb_dat_seq_o'length -- On vérifie que les bus de donnée ont la même taille
      report "the four data buses shall have the same size"
      severity failure;
   
   ActivatedAddresses_process : process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
         s_ActivatedAddresses <= (others => '0');
      elsif rising_edge(wb_clk_i) then
      
         if wb_we_usr_i = '1' and wb_cyc_usr_i = '1' and wb_stb_usr_i = '1' then
            s_ActivatedAddresses(to_integer(unsigned(wb_adr_usr_i))) <= '1';
         end if;
         
         if wb_we_seq_i = '1' and wb_cyc_seq_i = '1' and wb_stb_seq_i = '1' then
            if wb_vld_seq_i = '0' then
               s_ActivatedAddresses(to_integer(unsigned(wb_adr_seq_i))) <= '0';
            else
               s_ActivatedAddresses(to_integer(unsigned(wb_adr_seq_i))) <= '1';
            end if;
         end if;
         
      end if;
   end process;
   
   vld_seq_process : process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
            wb_vld_seq_o <= '0';
      elsif rising_edge(wb_clk_i) then
      
         if wb_cyc_seq_i = '1' and wb_stb_seq_i = '1' and wb_we_seq_i = '0' then
            wb_vld_seq_o <= s_ActivatedAddresses(to_integer(unsigned(wb_adr_seq_i)));
         end if;
         
      end if;
   end process;

   wb_DualPortRAM_inst : MailBox_DualPortRAM
   port map
   (
      wb_clk_i    => wb_clk_i,
      wb_rst_i    => wb_rst_i,
      wb_we_A_i   => wb_we_usr_i,
      wb_adr_A_i  => wb_adr_usr_i,
      wb_dat_A_i  => wb_dat_usr_i,
      wb_dat_A_o  => wb_dat_usr_o,
      wb_cyc_A_i  => wb_cyc_usr_i,
      wb_stb_A_i  => wb_stb_usr_i,
      wb_ack_A_o  => wb_ack_usr_o,
      wb_we_B_i   => wb_we_seq_i,
      wb_adr_B_i  => wb_adr_seq_i,
      wb_dat_B_i  => wb_dat_seq_i,
      wb_dat_B_o  => wb_dat_seq_o,
      wb_cyc_B_i  => wb_cyc_seq_i,
      wb_stb_B_i  => wb_stb_seq_i,
      wb_ack_B_o  => wb_ack_seq_o
   );

end MailBox_Timetable_behavior;