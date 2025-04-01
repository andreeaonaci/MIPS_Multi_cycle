library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE work.procmem_definitions.ALL;
entity MIPS is
  Port ( 
       clk : in  STD_LOGIC;
       rst: in STD_LOGIC; -- was some button
       --btn : in  STD_LOGIC_VECTOR (4 downto 0);
       sw : in  STD_LOGIC_VECTOR (15 downto 0)
    );
end MIPS;

architecture Behavioral of MIPS is
    signal RegDst: std_logic;
    signal ExtOP: std_logic := '1';
    signal ALUSrcA: std_logic;
    signal ALUSrcB: std_logic_vector(1 downto 0);
    signal PCWrite: std_logic;
    signal ALUOp: std_logic_vector(1 downto 0); --poate nu i asa
    signal MemWrite: std_logic;
    signal MemRead: std_logic;
    signal MemtoReg: std_logic;
    signal RegWrite: std_logic;
    signal IRWrite: std_logic;
    signal lorD: std_logic := '0';
    signal PCOut: std_logic_vector(width-1 downto 0) := x"00000000"; 
    signal PCEntry: std_logic_vector(width-1 downto 0) := x"00000000";
    signal MemOut: std_logic_vector(width-1 downto 0) := x"00000000"; 
    signal ZeroAlu: std_logic;
    signal WriteRegister : std_logic_vector(regfile_adrsize-1 DOWNTO 0) := "00000";
    signal ReadData1 : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal ReadData2 : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal WriteData : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal AluResultOut : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal AluResultReg: std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal DataMemoryReg: std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal ReadDataA: std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal ReadDataB: std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal ReadData1Mux : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal ReadData2Mux : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal SignExtendOut : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal ShiftOut : std_logic_vector(width-1 DOWNTO 0) := x"00000000";
    signal instr_31_26 : std_logic_VECTOR(5 DOWNTO 0);
    signal instr_25_21 : std_logic_VECTOR(4 DOWNTO 0);
    signal instr_20_16 : std_logic_VECTOR(4 DOWNTO 0);
    signal instr_15_0 : std_logic_VECTOR(15 DOWNTO 0);
    
    component pc IS
    PORT (
        clk : IN std_logic;
        rst_n : IN std_logic;
        pc_in : IN std_logic_VECTOR(width-1 DOWNTO 0);
        PC_en : IN std_logic;
        pc_out : OUT std_logic_VECTOR(width-1 DOWNTO 0) 
        );
    END component;
    
    component Main_Control_Unit is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        instruction : in std_logic_vector (31 downto 0);
        MemRead : out std_logic;
        MemWrite : out std_logic;
        RegDst : out std_logic;
        RegWrite : out std_logic;
        AluSrcA : out std_logic;
        AluSrcB : out std_logic_vector (1 downto 0);
        MemtoReg : out std_logic;
        IRWrite : out std_logic;
        PCWrite : out std_logic;
        AluOp : out std_logic_vector(1 downto 0)
        );
    end component;

    component alu IS
    PORT (
        a, b : IN std_logic_VECTOR(width-1 DOWNTO 0);
        opcode : IN std_logic_VECTOR(1 DOWNTO 0);
        result : OUT std_logic_VECTOR(width-1 DOWNTO 0);
        zero : OUT std_logic
        );
    END component;
    
    component instreg IS
        PORT (
        clk : IN std_logic;
        rst_n : IN std_logic;
        memdata : IN std_logic_VECTOR(width-1 DOWNTO 0);
        IRWrite : IN std_logic;
        instr_31_26 : OUT std_logic_VECTOR(5 DOWNTO 0);
        instr_25_21 : OUT std_logic_VECTOR(4 DOWNTO 0);
        instr_20_16 : OUT std_logic_VECTOR(4 DOWNTO 0);
        instr_15_0 : OUT std_logic_VECTOR(15 DOWNTO 0) 
        );
    END component;
    
    component regfile IS
        PORT (clk,rst_n : IN std_logic;
wen : IN std_logic; -- write control
adrport0 : IN std_logic_vector(regfile_adrsize-1 DOWNTO 0);-- address port 0
adrport1 : IN std_logic_vector(regfile_adrsize-1 DOWNTO 0);-- address port 1
adrwport : IN std_logic_vector(regfile_adrsize-1 DOWNTO 0);-- address write
writeport : IN std_logic_vector(width-1 DOWNTO 0); -- register input
readport0 : OUT std_logic_vector(width-1 DOWNTO 0); -- output port 0
readport1 : OUT std_logic_vector(width-1 DOWNTO 0) -- output port 1
);
    END component;
    
    component DataMemory is
    port ( 
        
        MemRead  : in std_logic;
        MemWrite : in std_logic;
        lorD:      in std_logic;
        addr     : in std_logic_vector(width-1 downto 0);
        di       : in std_logic_vector(width-1 downto 0);
        do       : out std_logic_vector(width-1 downto 0)
    );
    end component;
    
begin
        pc_portmap: pc port map(clk, rst, PCEntry, PCWrite, PCOut);
    data_memory_portmap: DataMemory port map ( MemRead, MemWrite, lorD, PCOut, ReadDataB, MemOut);
    controlUnit_portmap: Main_Control_Unit port map(clk, rst, MemOut, MemRead, MemWrite, RegDst, RegWrite, AluSrcA, AluSrcB,
                                              MemtoReg, IRWrite, PCWrite, AluOp);
    --PCEntry <= AluResultOut;

    process(clk, rst)
    begin
        if rst = '1' then
            DataMemoryReg <= (others => '0');
        elsif rising_edge(clk) then
            DataMemoryReg <= MemOut;
        end if;
    end process;
    WriteData <= DataMemoryReg when MemToReg = '1' else AluResultReg;
    WriteRegister <= instr_20_16 when RegDst = '0' else instr_15_0(15 downto 11);
    instruction_register_portmap: instreg port map(clk, rst, MemOut, IRWrite, instr_31_26, instr_25_21, instr_20_16, instr_15_0);
    


    
    ShiftOut <= "00" & SignExtendOut(29 downto 0);
    
    regfile_portmap: regfile port map (clk, rst, RegWrite, instr_25_21, instr_20_16, WriteRegister, WriteData, ReadData1, ReadData2);
    
    process(clk, rst)
    begin
        if rst = '1' then
            ReadDataA <= (others => '0');
        elsif rising_edge(clk) then
            ReadDataA <= ReadData1;
        end if;
    end process;
    
    process(clk, rst)
    begin
        if rst = '1' then
            ReadDataB <= (others => '0');
        elsif rising_edge(clk) then
            ReadDataB <= ReadData2;
        end if;
    end process;

    ReadData1Mux <= ReadDataA when AluSrcA = '1' else PCOut;
    ReadData2Mux <= ReadDataB when AluSrcB = "00" else x"00000100" when AluSrcB = "01";
    alu_portmap: alu port map (ReadData1Mux, ReadData2Mux, AluOp, AluResultOut, ZeroAlu);
    process(clk, rst)
    begin
        if rst = '1' then
            AluResultReg <= (others => '0');
        elsif rising_edge(clk) then
            AluResultReg <= AluResultOut;
        end if;
    end process;
    
end Behavioral;
