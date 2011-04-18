----------------------------------------------------------------------------------
-- Engineer:      Julien Aupart
-- 
-- Module Name:    MailBox_DataTablesInterface
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

entity MailBox_DataTablesInterface is
   port
   (
      wb_clk_i             : in std_logic;
      wb_rst_i             : in std_logic;
      
   -- Interface DatingTable
      wb_we_DatingTable_o  : out std_logic;
      wb_adr_DatingTable_o : out std_logic_vector;
      wb_dat_DatingTable_o : out std_logic_vector;
      wb_cyc_DatingTable_o : out std_logic;
      wb_stb_DatingTable_o : out std_logic;
      wb_ack_DatingTable_i : in std_logic;
      
   -- Interface DataTable
      wb_we_DataTable_o    : out std_logic;
      wb_adr_DataTable_o   : out std_logic_vector;
      wb_dat_DataTable_o   : out std_logic_vector;
      wb_dat_DataTable_i   : in std_logic_vector;
      wb_cyc_DataTable_o   : out std_logic;
      wb_stb_DataTable_o   : out std_logic;
      wb_ack_DataTable_i   : in std_logic;
      
   -- Interface AddrToRead
      wb_we_AddrToRead_o   : out std_logic;
      wb_dat_AddrToRead_o  : out std_logic_vector;
      wb_cyc_AddrToRead_o  : out std_logic;
      wb_stb_AddrToRead_o  : out std_logic;
      wb_ack_AddrToRead_i  : in std_logic;
      
   -- Interface Master Exterieur
      wb_we_Master_o       : out std_logic;
      wb_adr_Master_o      : out std_logic_vector;
      wb_dat_Master_o      : out std_logic_vector;
      wb_dat_Master_i      : in std_logic_vector;
      wb_cyc_Master_o      : out std_logic;
      wb_stb_Master_o      : out std_logic;
      wb_ack_Master_i      : in std_logic;
      
   -- RTC interface
      RTCTime_i            : in std_logic_vector;
      
   -- Event Manager Interface
      EventAddr_i          : in std_logic_vector;
      NewEvent_i           : in std_logic
      
   );
end MailBox_DataTablesInterface;

architecture MailBox_DataTablesInterface_behavior of MailBox_DataTablesInterface is
   
   signal s_WriteDatingTable  : std_logic;
   signal s_ReadDataTable     : std_logic;
   signal s_WriteDataTable    : std_logic;
   signal s_WriteAddrToRead   : std_logic;
   signal s_ReadMaster        : std_logic;
   signal s_WriteMaster       : std_logic;
   
   signal s_ReadWrite         : std_logic;
   
begin

   -- Dating Table Interface
   DatingTable_Interface_process : process(wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i = '1' then
            wb_we_DatingTable_o <= '0';
            wb_cyc_DatingTable_o <= '0';
            wb_stb_DatingTable_o <= '0';
            wb_dat_DatingTable_o <= (wb_dat_DatingTable_o'high downto 0 => '0');
         else
            if s_WriteDatingTable = '1' then
               if wb_ack_DatingTable_i = '0' then
                  wb_we_DatingTable_o <= '1';
                  wb_cyc_DatingTable_o <= '1';
                  wb_stb_DatingTable_o <= '1';
                  wb_dat_DatingTable_o <= RTCTime_i;
               else
                  wb_we_DatingTable_o <= '0';
                  wb_cyc_DatingTable_o <= '0';
                  wb_stb_DatingTable_o <= '0';
               end if;
            else
               wb_we_DatingTable_o <= '0';
               wb_cyc_DatingTable_o <= '0';
               wb_stb_DatingTable_o <= '0';
            end if;
         end if;
      end if;
   end process;
   wb_adr_DatingTable_o <= EventAddr_i;
   
   -- Data Table Interface
   DataTable_Interface_process : process(wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i = '1' then
            wb_we_DataTable_o <= '0';
            wb_cyc_DataTable_o <= '0';
            wb_stb_DataTable_o <= '0';
            wb_dat_Master_o <= (wb_dat_Master_o'high downto 0 => '0');
         else
            if s_ReadDataTable = '1' then
               if wb_ack_DataTable_i = '0' then
                  wb_we_DataTable_o <= '0';
                  wb_cyc_DataTable_o <= '1';
                  wb_stb_DataTable_o <= '1';
               else
                  wb_we_DataTable_o <= '0';
                  wb_cyc_DataTable_o <= '0';
                  wb_stb_DataTable_o <= '0';
                  wb_dat_Master_o <= wb_dat_DataTable_i;
               end if;
            elsif s_WriteDataTable = '1' then
               if wb_ack_DataTable_i = '0' then
                  wb_we_DataTable_o <= '1';
                  wb_cyc_DataTable_o <= '1';
                  wb_stb_DataTable_o <= '1';
               else
                  wb_we_DataTable_o <= '0';
                  wb_cyc_DataTable_o <= '0';
                  wb_stb_DataTable_o <= '0';
               end if;
            else
               wb_we_DataTable_o <= '0';
               wb_cyc_DataTable_o <= '0';
               wb_stb_DataTable_o <= '0';
            end if;
         end if;
      end if;
   end process;
   wb_adr_DataTable_o <= EventAddr_i;
   
   -- AddrToRead Interface
   AddrToRead_Interface_process : process(wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i = '1' then
            wb_we_AddrToRead_o <= '0';
            wb_cyc_AddrToRead_o <= '0';
            wb_stb_AddrToRead_o <= '0';
            wb_dat_AddrToRead_o <= (wb_dat_AddrToRead_o'high downto 0 => '0');
         else
            if s_WriteAddrToRead = '1' then
               if wb_ack_AddrToRead_i = '0' then
                  wb_we_AddrToRead_o <= '1';
                  wb_cyc_AddrToRead_o <= '1';
                  wb_stb_AddrToRead_o <= '1';
                  wb_dat_AddrToRead_o <= EventAddr_i;
               else
                  wb_we_AddrToRead_o <= '0';
                  wb_cyc_AddrToRead_o <= '0';
                  wb_stb_AddrToRead_o <= '0';
               end if;
            else
               wb_we_AddrToRead_o <= '0';
               wb_cyc_AddrToRead_o <= '0';
               wb_stb_AddrToRead_o <= '0';
            end if;
         end if;
      end if;
   end process;
   
   -- Master Exterieur Interface
   Master_Interface_process : process(wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if wb_rst_i = '1' then
            wb_we_Master_o <= '0';
            wb_cyc_Master_o <= '0';
            wb_stb_Master_o <= '0';
            wb_dat_DataTable_o <= (wb_dat_DataTable_o'high downto 0 => '0');
         else
            if s_ReadMaster = '1' then
               if wb_ack_Master_i = '0' then
                  wb_we_Master_o <= '0';
                  wb_cyc_Master_o <= '1';
                  wb_stb_Master_o <= '1';
               else
                  wb_we_Master_o <= '0';
                  wb_cyc_Master_o <= '0';
                  wb_stb_Master_o <= '0';
                  wb_dat_DataTable_o <= wb_dat_Master_i;
               end if;
            elsif s_WriteMaster = '1' then
               if wb_ack_Master_i = '0' then
                  wb_we_Master_o <= '1';
                  wb_cyc_Master_o <= '1';
                  wb_stb_Master_o <= '1';
               else
                  wb_we_Master_o <= '0';
                  wb_cyc_Master_o <= '0';
                  wb_stb_Master_o <= '0';
               end if;
            else
               wb_we_Master_o <= '0';
               wb_cyc_Master_o <= '0';
               wb_stb_Master_o <= '0';
            end if;
         end if;
      end if;
   end process;
   wb_adr_Master_o <= EventAddr_i(wb_adr_Master_o'range);
   
   s_ReadWrite <= EventAddr_i(EventAddr_i'high);
   
   -- Séquencement des différentes opérations sur les ports WishBone
   Operation_sequencer_process : process(wb_rst_i, wb_clk_i)
   begin
      if wb_rst_i = '1' then
         s_WriteDatingTable <= '0';
         s_WriteAddrToRead <= '0';
         s_ReadDataTable <= '0';
         s_WriteDataTable <= '0';
         s_ReadMaster <= '0';
         s_WriteMaster <= '0';
      elsif rising_edge(wb_clk_i) then
      
         if NewEvent_i = '1' then
            s_WriteDatingTable <= '1';
            s_WriteAddrToRead <= '1';
            if s_ReadWrite = '0' then   -- Read
               s_ReadMaster <= '1';
            else   -- Write
               s_ReadDataTable <= '1';
            end if;
         end if;
         
         if s_WriteDatingTable = '1' and wb_ack_DatingTable_i = '1' then
            s_WriteDatingTable <= '0';
         end if;
         
         if s_WriteAddrToRead = '1' and wb_ack_AddrToRead_i = '1' then
            s_WriteAddrToRead <= '0';
         end if;
         
         if s_ReadDataTable = '1' and wb_ack_DataTable_i = '1' then
            s_ReadDataTable <= '0';
            s_WriteMaster <= '1';
         end if;
         
         if s_WriteMaster = '1' and wb_ack_Master_i = '1' then
            s_WriteMaster <= '0';
         end if;
         
         if s_ReadMaster = '1' and wb_ack_Master_i = '1' then
            s_ReadMaster <= '0';
            s_WriteDataTable <= '1';
         end if;
         
         if s_WriteDataTable = '1' and wb_ack_DataTable_i = '1' then
            s_WriteDataTable <= '0';
         end if;
         
      end if;
   end process;

end MailBox_DataTablesInterface_behavior;
