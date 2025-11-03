library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity instr_decode is
  port (
    -- inputs
    clk       : in  std_logic;
    instr     : in  std_logic_vector(15 downto 0); -- instructiunea: 12:10 rs, 9-7 rt, 6-4 rd
    wd        : in  std_logic_vector(15 downto 0); --write data(normal e de la write back, ori load din memorie in reg ori din alu rezultatul)
    wa : in std_logic_vector(2 downto 0);
    -- control signal based inputs
    ext_op    : in  std_logic; --extend signal, 1 cand avem nevoie de sign extension(mostly pt i si j type op), 0 cand e zero extension
    reg_dst   : in  std_logic; -- selecteaza destinatia, 1 pt rd(r type op), 0 pt rt(i type op)
    reg_write : in  std_logic; -- enable ca sa scriem in registru, ca sa salvam rezultatul la operatii(signal control)
    -- outputs
    ext_imm   : out std_logic_vector(15 downto 0); -- imm cu sign extension
    func      : out std_logic_vector(2  downto 0); -- ultimii 3 biti din 3 type care se duc in alu si reprezinta operatia pe care o vrem
    rd1       : out std_logic_vector(15 downto 0);
    rd2       : out std_logic_vector(15 downto 0);        
    sa        : out std_logic
  );
end instr_decode;

architecture behavioral of instr_decode is

  component reg_file
  port (
    clk : in  std_logic;
    ra1 : in  std_logic_vector(2  downto 0); -- ia rs
    ra2 : in  std_logic_vector(2  downto 0); -- ia rt
    wa  : in  std_logic_vector(2  downto 0); -- ia rs sau rd
    wd  : in  std_logic_vector(15 downto 0); -- ia rezultatul din ALU sau din memorie
    wen : in  std_logic; -- write enable
    rd1 : out std_logic_vector(15 downto 0); 
    rd2 : out std_logic_vector(15 downto 0)
  );
  end component;

    signal mux_out: std_logic_vector(2 downto 0):= (others => '0');
    signal ext_unit_out: std_logic_vector(15 downto 0):= (others => '0');
    signal ext_unit_0 : std_logic_vector(8 downto 0):= (others => '0');
    signal ext_unit_1 : std_logic_vector(8 downto 0):= (others => '1');
  -- *  
  -- NO OTHER EXTERNAL COMPONENT DECLARATION NECESSARY
  -- ADDITIONAL SIGNALS HERE

begin

  inst_rf : reg_file
  port map (
    clk => clk ,
    ra1 => instr(12 downto 10),
    ra2 => instr(9 downto 7),
    wa  => wa,
    wd  => wd,
    wen => reg_write,
    rd1 => rd1,
    rd2 => rd2
  );
 ext_unit_out <= ext_unit_0 & instr(6 downto 0) when ext_op = '0' else ext_unit_1 & instr(6 downto 0); -- extend cu 1 cand semanlul e 1 sau cu 0 cand e 0

  -- **  
  -- NO OTHER EXTERNAL COMPONENT INSTANTIATION NECESSARY
  -- ADDITIONAL COMPONENT IMPLEMENTATION HERE
  

end behavioral;