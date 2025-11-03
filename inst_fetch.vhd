library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity inst_fetch is
  port (
    -- inputs
    clk                   : in  std_logic;
    branch_target_address : in  std_logic_vector(15 downto 0);
    jump_address          : in  std_logic_vector(15 downto 0);
    pc_en                 : in  std_logic;
    pc_reset              : in  std_logic;
    -- control signal based inputs
    jump                  : in  std_logic;
    pc_src                : in  std_logic;
    -- outputs
    instruction           : out std_logic_vector(15 downto 0);
    pc_plus_one           : out std_logic_vector(15 downto 0)
  );
end inst_fetch;

architecture behavioral of inst_fetch is

  signal s_adder_out      : std_logic_vector(15 downto 0) := x"0000";
  signal s_pc_out         : std_logic_vector(15 downto 0) := x"0000";
  signal s_mux_branch_out : std_logic_vector(15 downto 0) := x"0000";
  signal s_mux_jump_out   : std_logic_vector(15 downto 0) := x"0000";
  

  type t_rom is array (0 to 255) of std_logic_vector(15 downto 0);
  signal s_rom : t_rom := (
  --  opc rs  rt  rd sa func
 -- R Type
  --  opc rs  rt  rd sa func
    b"000_001_010_011_0_000", -- #x0 x"0530" add  $3 <= $1 + $2 x0b02 + x0c03 = x1705
    b"000_110_100_010_0_001", -- #x1 x"1a21" sub  $2 <= $6 - $4 x123f - x0e05 = x043a
    b"000_000_000_111_1_010", -- #x2 x"007a" sll  $7 <= $0 << 1 x0a01 <<   1  = x1402
    b"000_000_000_111_1_011", -- #x3 x"007b" srl  $7 <= $0 >> 1 x0a01 >>   1  = x0500
    b"000_101_010_110_0_100", -- #x4 x"1564" and  $6 <= $5 & $2 x0f06 & x043a = x0402
    b"000_101_010_110_0_101", -- #x5 x"1565" or   $6 <= $5 | $2 x0f06 | x043a = x0f3e    
  -- I Type  
  --  opc rs  rt  imm
    b"001_111_001_0000101",   -- #x6 x"3c85" addi $1 <= $7 + 5  x0500 + x0005 = x0505
    b"001_111_000_1000001",   -- #x7 x"3c41" addi $4 <= $7 - 63 x0500 - x003f = x04c1
  -- R Type
  --  opc rs  rt  rd sa func
    b"000_001_111_000_0_001", -- #x8 x"0781" sub  $0 <= $1 - $7 x0505 - x0500 = x0005
  -- I Type  
  --  opc rs  rt  imm
    b"011_000_101_0000000",   -- #x9 x"6280" sw   MEM[$0 + 0] <= $5 x0005 + 0 = x0005
    b"010_000_100_0000000",   -- #xa x"4200" lw   $4 <= MEM[$0 + 0] x0005 + 0 = x0005
    b"001_100_000_0000000",   -- #xb x"3000" addi $0 <= $4 + 0 x0005 + 0 = x0005
    b"100_000_100_0000010",   -- #xc x"8202" beq  $4 == $0 x0005 == x0005 PC + 2
    b"100_000_100_0000010",   -- #xd skip
    b"100_000_100_0000010",   -- #xe skip
  -- J Type
  --  opc addr
    b"111_0000000000011",     -- #xf x"e003" j    0003
    others => (others => '1')
  );
  
  -- *  
  -- NO OTHER EXTERNAL COMPONENT DECLARATION NECESSARY
  -- ADDITIONAL SIGNALS HERE

begin

  -- **  
  -- NO OTHER EXTERNAL COMPONENT INSTANTIATION NECESSARY
  -- ADDITIONAL COMPONENT IMPLEMENTATION HERE
  
  --adderul pt next instruction
  s_adder_out <= s_pc_out + '1';
  -- mux pt branch 
  s_mux_branch_out <= branch_target_address when pc_src = '1' else s_adder_out;
  -- mux pt jump
  s_mux_jump_out <= jump_address when jump = '1' else s_mux_branch_out;
  --instruction ia continutul din memorie aratat de pc_out
  instruction <= s_rom(conv_integer(s_pc_out(7 downto 0)));
  --asta e semnalul ce iese din adder 
  pc_plus_one <= s_adder_out;
  
  -- DFF process
  process(clk)
  begin
    if rising_edge(clk) then
        if pc_en = '1' then
            s_pc_out <= s_mux_jump_out; -- cand e enable dff pc_out ia ce iese din ultimul mux care in functie de semnale e pc + 1(next instr), instructiunea de la branch sau cea de la jump)
        elsif pc_reset = '1' then
            s_pc_out <= x"0000";
        end if;
    end if;
  end process;
end behavioral;