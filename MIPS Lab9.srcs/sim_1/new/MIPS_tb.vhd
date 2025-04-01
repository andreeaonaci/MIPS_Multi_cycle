library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MIPS_TB is
end MIPS_TB;

architecture TB_ARCH of MIPS_TB is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal sw : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    constant CLK_PERIOD : time := 10 ns;

    component MIPS
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            sw : in STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

begin
    process
    begin
        while now < 5000 ns loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    process
    begin
        wait for 2 * CLK_PERIOD;

        -- Apply stimulus to the inputs
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        -- Test 1: Load immediate value to register
        wait for 10 * CLK_PERIOD;
        sw <= "0000000010101010";

        -- Test 2: Branch instruction (modify sw accordingly)
        wait for 10 * CLK_PERIOD;
        sw <= "0000000011001100";

        -- Test 3: ALU operation (modify sw accordingly)
        wait for 10 * CLK_PERIOD;
        sw <= "0000000010010010";

        -- Add more test cases as needed

        wait;
    end process;

    uut: MIPS port map (
        clk => clk,
        rst => rst,
        sw => sw
    );

end TB_ARCH;
