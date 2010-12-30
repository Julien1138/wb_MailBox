-----------------------------------------------------------------------------------
--
-- Project Name : MailBox_FIFO
-- Supplier     : Teuchos
--
-- Design Name  : MailBox_FIFO
-- Module Name  : MailBox_FIFO.vhd
--
-- Description  : Universal Asynchronous Receiver Transmitter
-- 
-- --------------------------------------------------------------------------------
-- Revision List
-- Version      Author(s)       Date        Changes
--
-- 1.0          J.Aupart        22/08/10    Creation
-----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

library MailBox_Lib;
use MailBox_Lib.MailBox_Pack.all;

entity MailBox_FIFO is
    generic
    (
        FIFOSize        : integer := 1024;
        Data_Width      : integer := 8
    );
    port
    (
        rst         : in std_logic;
        clk         : in std_logic;
        
        Write_en    : in std_logic;
        Data_in     : in std_logic_vector(Data_Width - 1 downto 0);
        Read_en     : in std_logic;
        Data_out    : out std_logic_vector(Data_Width - 1 downto 0);
        
        FIFO_Empty  : out std_logic;
        FIFO_Full   : out std_logic
    );
end MailBox_FIFO;

architecture MailBox_FIFO_behavior of MailBox_FIFO is

    type FIFO_type is array (FIFOSize-1 downto 0) of std_logic_vector(Data_Width-1 downto 0);
    impure function FillRAM return FIFO_type is
        variable RAM : FIFO_type;
    begin
        for I in FIFO_type'range loop
            RAM(I) := (others => '0');
       end loop;
       return RAM;
    end function;
    signal MailBox_FIFO : FIFO_type := FillRAM;
    
    signal Write_Idx        : std_logic_vector(integer(ceil(log2(real(FIFOSize)))) - 1 downto 0);
    signal Read_Idx         : std_logic_vector(integer(ceil(log2(real(FIFOSize)))) - 1 downto 0);
    signal NbrOfElements    : std_logic_vector(integer(ceil(log2(real(FIFOSize)))) - 1 downto 0);
    
begin

    Write_process : process(rst, clk)
    begin
        if rst = '1' then
            Write_Idx <= (others => '0');
        elsif rising_edge(clk) then
        
            if Write_en = '1' then
                MailBox_FIFO(to_integer(unsigned(Write_Idx))) <= Data_in;
                Write_Idx <= Write_Idx + 1;
            end if;
            
        end if;
    end process;

    Read_process : process(rst, clk)
    begin
        if rst = '1' then
            Read_Idx <= (others => '0');
        elsif rising_edge(clk) then
        
            Data_out <= MailBox_FIFO(to_integer(unsigned(Read_Idx)));
            
            if Read_en = '1' then
                Read_Idx <= Read_Idx + 1;
            end if;
            
        end if;
    end process;
    
    NbrOfElements_process : process(rst, clk)
    begin
        if rst = '1' then
            NbrOfElements <= (others => '0');
        elsif rising_edge(clk) then
        
            if Write_en = '1' and Read_en = '0' then
                NbrOfElements <= NbrOfElements + 1;
            elsif Write_en = '0' and Read_en = '1' then
                NbrOfElements <= NbrOfElements - 1;
            else
                NbrOfElements <= NbrOfElements;
            end if;
            
        end if;
    end process;
    
    FIFO_Empty <= '1' when NbrOfElements = 0 else
                  '0';
    FIFO_Full <= '1' when signed(NbrOfElements) = -1 else
                 '0';

end MailBox_FIFO_behavior;