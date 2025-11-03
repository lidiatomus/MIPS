library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity ram is
    port (
    clk         : in  std_logic;
    alu_res_in  : in  std_logic_vector(3 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    mem_write   : in  std_logic;
    mem_data    : out std_logic_vector(15 downto 0)
  );
end entity;

  architecture rtl of ram is

    type t_ram is array (0 to 3) of std_logic_vector(15 downto 0);
    signal s_ram : t_ram := (
      (others => '0'),
      x"0001",
      x"0002",
      x"0003",
      others => (others => '0')
    );
  
  begin
  
    process (clk)
    begin
      if rising_edge(clk) then
        if mem_write = '1' then
          s_ram(conv_integer(alu_res_in)) <= rd2;
        end if;
      end if;
    end process;

    mem_data <= s_ram(conv_integer(alu_res_in));
  
  end architecture;