
library ieee;
  use ieee.std_logic_1164.all;library IEEE;
  use ieee.std_logic_arith.all;use IEEE.STD_LOGIC_1164.ALL;
  use ieee.std_logic_unsigned.all;

entity rams_no_change is
        port ( clk : in std_logic;
               we : in std_logic;
               en : in std_logic;
               addr : in std_logic_vector(3 downto 0);
               di : in std_logic_vector(31 downto 0);
               do : out std_logic_vector(31 downto 0));
end rams_no_change;

architecture syn of rams_no_change is

    type ram_type is array (0 to 15) of std_logic_vector (31 downto 0);
    signal RAM: ram_type:= (0 => (others => '0'),
                                1 => x"00000001", 
                                2 => x"00000002", 
                                3 => x"00000003", 
                          others => (others => '0')) ;
    
begin
    process (clk)
        begin
            if clk'event and clk = '1' then
                if en = '1' then
                    if we = '1' then
                        RAM(conv_integer(addr)) <= di;
                        do <= di;
                    else
                        do <= RAM( conv_integer(addr));
                    end if;
                end if;
            end if;
        end process;
end syn;