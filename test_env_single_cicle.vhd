library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity test_env is
  port (
    clk : in std_logic;
    btn : in  std_logic_vector(4  downto 0);
    sw  : in  std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0);
    an  : out std_logic_vector(7  downto 0);
    cat : out std_logic_vector(6  downto 0)
  );
end entity test_env;

architecture behavioral of test_env is

  signal s_mpg_out    : std_logic_vector(4  downto 0) := (others => '0');
  signal digits_ssd   : std_logic_vector(31 downto 0);
  
  component mono_pulse_gen
  port (
    clk    : in  std_logic;
    btn    : in  std_logic_vector(4  downto 0);
    enable : out std_logic_vector(4  downto 0)
  );
  end component;
  
  component seven_seg_disp is
  port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31 downto 0);   
    an     : out std_logic_vector(7  downto 0);
    cat    : out std_logic_vector(6  downto 0)
  );
  end component seven_seg_disp;
  
  component rams_no_change is
    port ( 
    clk : in std_logic;
    we : in std_logic;
    en : in std_logic;  
    addr : in std_logic_vector(3 downto 0);
    di : in std_logic_vector(31 downto 0);
    do : out std_logic_vector(31 downto 0));
  end component rams_no_change;
  
  component inst_fetch
  port (
    clk                   : in  std_logic;
    branch_target_address : in  std_logic_vector(15 downto 0);
    jump_address          : in  std_logic_vector(15 downto 0);
    jump                  : in  std_logic;
    pc_src                : in  std_logic;
    pc_en                 : in  std_logic;
    pc_reset              : in  std_logic;
    instruction           : out std_logic_vector(15 downto 0);
    pc_plus_one           : out std_logic_vector(15 downto 0)
  );
  end component;
  
  component control_unit
  port (
    op_code    : in std_logic_vector(2 downto 0);
    reg_dst    : out std_logic;
    ext_op     : out std_logic;
    alu_src    : out std_logic;
    branch     : out std_logic;
    jump       : out std_logic;
    alu_op     : out std_logic_vector(2 downto 0);
    mem_write  : out std_logic;
    mem_to_reg : out std_logic;
    reg_write  : out std_logic
  );
  end component;
  
  component instr_decode
  port (
    clk       : in  std_logic;
    instr     : in  std_logic_vector(15 downto 0);
    wd        : in  std_logic_vector(15 downto 0);
    ext_op    : in  std_logic;
    reg_dst   : in  std_logic;
    reg_write : in  std_logic;
    ext_imm   : out std_logic_vector(15 downto 0);
    func      : out std_logic_vector(2  downto 0);
    rd1       : out std_logic_vector(15 downto 0);
    rd2       : out std_logic_vector(15 downto 0);
    sa        : out std_logic
  );
  end component;
 
   component exec_unit
  port (
    ext_imm     : in  std_logic_vector(15 downto 0);
    func        : in  std_logic_vector(2  downto 0);
    rd1         : in  std_logic_vector(15 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    pc_plus_one : in  std_logic_vector(15 downto 0);
    sa          : in  std_logic;
    alu_op      : in  std_logic_vector(2  downto 0);
    alu_src     : in  std_logic;
    alu_res     : out std_logic_vector(15 downto 0);
    bta         : out std_logic_vector(15 downto 0);
    zero        : out std_logic
  );
  end component;
  
  component memory_unit is
    port (
    clk         : in  std_logic;
    alu_res_in  : in  std_logic_vector(3 downto 0);
    rd2         : in  std_logic_vector(15 downto 0);
    mem_write   : in  std_logic;
    mem_data    : out std_logic_vector(15 downto 0)
  );
end component;
 
 --signals
 signal s_if_out_instruction: std_logic_vector(15 downto 0);
 signal s_if_in_jump_address: std_logic_vector(15 downto 0);

 signal s_ctrl_ext_op: std_logic;
 signal s_ctrl_reg_dst: std_logic;
  signal s_id_in_reg_write : std_logic                     := '0';
  signal s_id_in_wd        : std_logic_vector(15 downto 0) := x"0000";
  signal s_id_out_ext_imm  : std_logic_vector(15 downto 0) := x"0000";
  signal s_id_out_func     : std_logic_vector(2  downto 0) := b"000";
  signal s_id_out_rd1      : std_logic_vector(15 downto 0) := x"0000";
  signal s_id_out_rd2      : std_logic_vector(15 downto 0) := x"0000";
  signal s_id_out_sa       : std_logic                     := '0';
 signal s_ctrl_reg_wr: std_logic;
 signal s_ctrl_alu_src: std_logic;
 signal s_ctrl_branch: std_logic;
 signal s_ctrl_mem_write: std_logic;
 signal s_ctrl_mem_to_reg: std_logic;
 signal s_ctrl_reg_write: std_logic;
 signal s_ctrl_jump: std_logic;
 signal s_ctrl_alu_op: std_logic_vector(2 downto 0);
 signal s_digits_upper: std_logic_vector(15 downto 0);
 signal s_if_out_pc_plus_one: std_logic_vector(15 downto 0);
 signal s_digits_lower: std_logic_vector(15 downto 0);
 signal s_digits: std_logic_vector(31 downto 0);

  -- Execution Unit
  signal s_eu_out_alu_res : std_logic_vector(15 downto 0) := x"0000";
  signal s_eu_out_bta     : std_logic_vector(15 downto 0) := x"0000";
  signal s_eu_out_zero    : std_logic                     := '0';
  
  --memory unit
  signal s_mem_write: std_logic := '0';
  signal s_mu_out_mem_data: std_logic_vector(15 downto 0) := x"0000"; 
  signal s_wb_out_wd: std_logic_vector(15 downto 0):= x"0000";
   
begin

  mpg_inst : mono_pulse_gen
  port map (
      clk    => clk,    
      btn    => btn,    
      enable => s_mpg_out
  );
  
  ssd_inst : seven_seg_disp
  port map (
      clk    => clk,
      digits => s_digits,
      an     => an,
      cat    => cat
  );
  
  inst_infe : inst_fetch
  port map (
    clk                    => clk,
    branch_target_address  => s_eu_out_bta,
    jump_address           => s_if_in_jump_address,
    jump                   => sw(0),
    pc_src                 => sw(1),
    pc_en                  => s_mpg_out(0),
    pc_reset               => s_mpg_out(1),
    instruction            => s_if_out_instruction,
    pc_plus_one            => s_if_out_pc_plus_one
  );
  
  inst_indcd : instr_decode
  port map (
    clk       => clk,
    instr     => digits_ssd(15 downto 0),
    wd        => s_id_in_wd,
    ext_op    => s_ctrl_ext_op,
    reg_dst   => s_ctrl_reg_dst,
    reg_write => s_id_in_reg_write,
    ext_imm   => s_id_out_ext_imm,
    func      => s_id_out_func,
    rd1       => s_id_out_rd1,
    rd2       => s_id_out_rd2,
    sa        => s_id_out_sa
  );
  --write back
  s_id_in_wd <= s_mu_out_mem_data when s_ctrl_mem_to_reg = '1' else s_eu_out_alu_res;
  s_id_in_reg_write <= s_mpg_out(0) and s_ctrl_reg_wr ;
  
  inst_cu : control_unit
  port map (
    op_code    => s_if_out_instruction(15 downto 13),
    reg_dst    => s_ctrl_reg_dst,
    ext_op     => s_ctrl_ext_op,
    alu_src    => s_ctrl_alu_src,
    branch     => s_ctrl_branch,
    jump       => s_ctrl_jump,
    alu_op     => s_ctrl_alu_op,
    mem_write  => s_ctrl_mem_write,
    mem_to_reg => s_ctrl_mem_to_reg,
    reg_write  => s_ctrl_reg_write
  );
  
    exec_unit_inst : exec_unit
  port map (
    ext_imm     => s_id_out_ext_imm ,
    func        => s_id_out_func,
    rd1         => s_id_out_rd1 ,
    rd2         => s_id_out_rd2,
    pc_plus_one => s_if_out_pc_plus_one ,
    sa          => s_id_out_sa ,
    alu_op      => s_ctrl_alu_op ,
    alu_src     => s_id_out_sa,
    alu_res     => s_eu_out_alu_res,
    bta         => s_eu_out_bta ,
    zero        => s_eu_out_zero
  );
  
  --mem unit inst
  s_mem_write <= s_ctrl_mem_write and s_mpg_out(0);
   mem_unit_inst : memory_unit
  port map (
    clk         => clk,
    alu_res_in  => s_eu_out_alu_res(3 downto 0),
    rd2         => s_id_out_rd2,
    mem_write   => s_mem_write,
    mem_data    => s_mu_out_mem_data
  );
  
      -- MUX for 7-segment display left side (31 downto 16)
  process (sw(11 downto 9), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_id_in_wd)
  begin
    case sw(11 downto 9) is
      when "000"  => s_digits_upper <= s_if_out_instruction;
      when "001"  => s_digits_upper <= s_if_out_pc_plus_one;
      when "010"  => s_digits_upper <= s_id_out_rd1;
      when "011"  => s_digits_upper <= s_id_out_rd2;
      when "100"  => s_digits_upper <= s_id_out_ext_imm;
      when "101"  => s_digits_upper <= s_eu_out_alu_res;
      when "110"  => s_digits_upper <= s_mu_out_mem_data;
      when "111"  => s_digits_upper <= s_wb_out_wd;
    end case;
  end process;

  -- MUX for 7-segment display right side (15 downto 0)
  process (sw(6 downto 4), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_id_in_wd)
  begin
    case sw(6 downto 4) is
      when "000"  => s_digits_lower <= s_if_out_instruction;
      when "001"  => s_digits_lower <= s_if_out_pc_plus_one;
      when "010"  => s_digits_lower <= s_id_out_rd1;
      when "011"  => s_digits_lower <= s_id_out_rd2;
      when "100"  => s_digits_lower <= s_id_out_ext_imm;
      when "101"  => s_digits_lower <= s_eu_out_alu_res;
      when "110"  => s_digits_lower <= s_mu_out_mem_data;
      when "111"  => s_digits_lower <= s_wb_out_wd;
    end case;
  end process;

  s_digits <= s_digits_upper & s_digits_lower;

  -- LED with signals from Main Control Unit
  led <= s_ctrl_alu_op     & -- ALU operation        15:13
         b"0000_0"         & -- Unused               12:8
         s_ctrl_reg_dst    & -- Register destination 7
         s_ctrl_ext_op     & -- Extend operation     6
         s_ctrl_alu_src    & -- ALU source           5
         s_ctrl_branch     & -- Branch               4
         s_ctrl_jump       & -- Jump                 3
         s_ctrl_mem_write  & -- Memory write         2
         s_ctrl_mem_to_reg & -- Memory to register   1
         s_ctrl_reg_write;   -- Register write       0
         
end behavioral; 
