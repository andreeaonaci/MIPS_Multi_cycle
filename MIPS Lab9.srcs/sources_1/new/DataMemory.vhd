library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE work.procmem_definitions.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

entity DataMemory is
    port ( 
   --     clk      : in std_logic;
        MemRead  : in std_logic;
        MemWrite : in std_logic;
        lorD:      in std_logic;
        addr     : in std_logic_vector(width-1 downto 0);
        di       : in std_logic_vector(width-1 downto 0);
        do       : out std_logic_vector(width-1 downto 0)
    );
end DataMemory;

architecture syn of DataMemory is
    type instructions_t is array (0 to 5) of std_logic_vector(31 downto 0);
    signal instructions_secund: instructions_t;
    signal instructions : instructions_t := (
    b"000000_00000_00001_00010_00000_100000", -- type R (add)
    b"000000_00000_00001_00010_00000_100010", -- type R (sub)
    b"000000_00000_00001_00010_00000_100100", -- type R (and)
    b"100011_00000_00001_0001000000100100", -- load
    b"101011_00000_00001_0001000000100100", -- store
    others => b"000000_00000_00001_00010_00000_100100" -- type R (and)
    );
begin
    process ( MemRead, MemWrite, lorD)
    begin

            if MemWrite = '1' and MemRead = '0' then
                instructions_secund(conv_integer(addr)) <= di(31 downto 0);
--                instructions_secund(conv_integer(addr)+1) <= di(23 downto 16);
--                instructions_secund(conv_integer(addr)+2) <= di(15 downto 8);
--                instructions_secund(conv_integer(addr)+3) <= di(7 downto 0);
            elsif MemWrite = '0' and MemRead = '1'  then
                do(31 downto 0) <= instructions(conv_integer(addr));
--                do(23 downto 16) <= instructions(conv_integer(addr)+1);
--                do(15 downto 8) <= instructions(conv_integer(addr)+2);
--                do(7 downto 0) <= instructions(conv_integer(addr)+3);
            end if;

    end process;
end syn;
