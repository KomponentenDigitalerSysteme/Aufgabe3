
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY core IS
   GENERIC(RSTDEF: std_logic := '0');
   PORT(rst:   IN  std_logic;                      -- reset,          RSTDEF active
        clk:   IN  std_logic;                      -- clock,          rising edge
        swrst: IN  std_logic;                      -- software reset, RSTDEF active
        strt:  IN  std_logic;                      -- start,          high active
        sw:    IN  std_logic_vector( 7 DOWNTO 0);  -- length counter, input
        res:   OUT std_logic_vector(43 DOWNTO 0);  -- result
        done:  OUT std_logic);                     -- done,           high active
END core;


architecture structure of core is
    signal sum : std_logic_vector(43 DOWNTO 0);
    signal addr_a : std_logic_VECTOR(9 DOWNTO 0);
    signal addr_b : std_logic_VECTOR(9 DOWNTO 0);

    signal dout_a : std_logic_VECTOR(15 DOWNTO 0);
    signal dout_b : std_logic_VECTOR(15 DOWNTO 0);

    
component ram_block is
   PORT(addra: IN std_logic_VECTOR(9 DOWNTO 0);
         addrb: IN std_logic_VECTOR(9 DOWNTO 0);
         clka:  IN std_logic;
         clkb:  IN std_logic;
         douta: OUT std_logic_VECTOR(15 DOWNTO 0);
         doutb: OUT std_logic_VECTOR(15 DOWNTO 0);
         ena:   IN std_logic;
         enb:   IN std_logic);
   end component;
   component MULT18X18
      port (P : out STD_LOGIC_VECTOR (35 downto 0);
            A : in STD_LOGIC_VECTOR (17 downto 0);
            B : in STD_LOGIC_VECTOR (17 downto 0));
end component;
begin

   
   
   
   process(clk, rst) begin
      
      for i in 0 to sw(7 DOWNTO 0) loop
         addra <= i * 16;
         addrb <= (256 + i) * 16;
         user_A <= "00" & douta;
         user_B <= "00" & doutb;
         
         sum <= sum + user_P;
      end loop;
       
   end process;
   
   m0 : MULT18X18
      port map (P => user_P,
                A => user_A,
                B => user_B);
   
    
   u0: ram_block
        PORT MAP(addra => addr_a,
         addrb => addr_b,
         clka => clk,
         clkb => clk,
         douta => dout_a,
         doutb => dout_b,
         ena => '0',
         enb => '0');
    
end;