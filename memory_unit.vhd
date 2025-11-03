

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity memory_unit is
 port (
    clk         : in  std_logic;
    alu_res_in  : in  std_logic_vector(3 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    mem_write   : in  std_logic;
    mem_data    : out std_logic_vector(15 downto 0)
  );
end memory_unit;

architecture Behavioral of memory_unit is
component ram is
    port (
    clk         : in  std_logic;
    alu_res_in  : in  std_logic_vector(3 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    mem_write   : in  std_logic;
    mem_data    : out std_logic_vector(15 downto 0)
  );
end component;

begin
inst_ram: ram port map(
    clk => clk,
    alu_res_in => alu_res_in,
    rd2 => rd2,
    mem_write => mem_write,
    mem_data => mem_data
);

end Behavioral;
