
LIBRARY ieee;
LIBRARY unisim;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE unisim.vcomponents.ALL;

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


	-- Akkumulator Stuff
	signal acc_en : std_logic := '0';
   signal sum : signed(43 DOWNTO 0);
   
	-- RAM--
	signal ram_en : std_logic := '0';
	signal addr_a : std_logic_vector(9 DOWNTO 0);
	signal addr_b : std_logic_vector(9 DOWNTO 0);

   signal dout_a : std_logic_VECTOR(15 DOWNTO 0);
   signal dout_b : std_logic_VECTOR(15 DOWNTO 0);
	 
	 
	-- Multiplizierer Stuff
	signal mul_en : std_logic := '0';
	signal prod : std_logic_vector(35 DOWNTO 0);
	signal op1 : std_logic_vector(17 DOWNTO 0);
	signal op2 : std_logic_vector(17 DOWNTO 0);
	
	signal prod_tmp : std_logic_vector(43 DOWNTO 0);
	
	-- Steuerwerk
	type TState is (S0, S1, S2, S3, S4, S5);
	signal state : TState;

    
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
   
component MULT18X18S
   port (P : out STD_LOGIC_VECTOR (35 downto 0);
            A : in STD_LOGIC_VECTOR (17 downto 0);
            B : in STD_LOGIC_VECTOR (17 downto 0);
				C : in std_logic;
				CE : in std_logic;
				R : in std_logic);
end component;
begin

	res <= std_logic_vector(sum);
	
	addr_b <= "01" & addr_a(7 DOWNTO 0);
	
	op1 <= std_logic_vector(resize(signed(dout_a),18));
	op2 <= std_logic_vector(resize(signed(dout_b),18));
		
	prod_tmp <= std_logic_vector(resize(signed(prod),44));

	

	u0: ram_block
        PORT MAP(addra => addr_a,
         addrb => addr_b,
         clka => clk,
         clkb => clk,
         douta => dout_a,
         doutb => dout_b,
         ena => ram_en,
         enb => ram_en);

    m0 : MULT18X18S
    port map (P => prod,
				  A => op1,
				  B => op2,
				  C => clk,
				  CE => mul_en,
				  R => rst);
			
	


   -- Accumulator
   process(clk,rst) begin
		if rst = RSTDEF then
			sum <= (OTHERS => '0');
		elsif rising_edge(clk) then
			if swrst = RSTDEF then
				sum <= (OTHERS => '0');
			elsif acc_en = '1' then
				sum <= sum + signed(prod_tmp); --+ signed(prod_tmp);--resize(signed(prod),44);
				--REPORT "-----op1: " & integer'image(to_integer(signed(op1)));
				--REPORT "-----op2: " & integer'image(to_integer(signed(op2)));
				--REPORT "-----PROD: " & integer'image(to_integer(signed(prod_tmp)));
			elsif strt = '1' then
				sum <= (OTHERS => '0');
			end if;
		end if;
	end process;
   
	 
   -- Steuerwerk
   process(clk, rst) begin
      if rst = RSTDEF then
			done <= '0';
			acc_en <= '0';
			ram_en <= '0';
			mul_en <= '0';
			state <= S0;
			addr_a <= (OTHERS => '0');
		elsif rising_edge(clk) then
			if swrst = RSTDEF then
				done <= '0';
				acc_en <= '0';
				ram_en <= '0';
				mul_en <= '0';
				state <= S0;
				addr_a <= (OTHERS => '0');
			else
				case state is
				when S0 =>
					if strt = '1' then
						addr_a <= "00" & sw;
						state <= S1;
						done <= '0';
					end if;
				when S1 =>
					if addr_a(7 DOWNTO 0) > "00000000" then
						state <= S2;
						ram_en <= '1';
						addr_a <= std_logic_vector(signed(addr_a) - 1);
					else
						state <= S5;
					end if;
				when S2 =>
					if addr_a(7 DOWNTO 0) > "00000000" then
						state <= S3;
						mul_en <= '1';
						addr_a <= std_logic_vector(signed(addr_a) - 1);
					else
						state <= S4;
						ram_en <= '0';
						mul_en <= '1';
					end if;
				when S3 =>
					if addr_a(7 DOWNTO 0) > "00000000" then
						addr_a <= std_logic_vector(signed(addr_a) - 1);
						acc_en <= '1';
					else
						state <= S4;
						acc_en <= '1';
						ram_en <= '0';
					end if;
				when S4 =>
					state <= S5;
					acc_en <= '1';
					mul_en <= '0';
				when S5 =>
					state <= S0;
					acc_en <= '0';
					done <= '1';
				end case;
			end if;
		end if; 
   end process;
   

	

   

	
	
	
	

    
end;