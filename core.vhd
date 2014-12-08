
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
   
	-- RAM
	signal ram_en : std_logic := '0';
	signal addr_a : std_logic_vector(9 DOWNTO 0);
	signal addr_b : std_logic_vector(9 DOWNTO 0);
	signal offset : std_logic_VECTOR(7 DOWNTO 0);
   signal dout_a : std_logic_VECTOR(15 DOWNTO 0);
   signal dout_b : std_logic_VECTOR(15 DOWNTO 0);
	 
	 
	-- Multiplizierer Stuff
	signal prod : std_logic_vector(35 DOWNTO 0);
	signal op1 : std_logic_vector(17 DOWNTO 0);
	signal op2 : std_logic_vector(17 DOWNTO 0);
	
	signal prod_tmp : std_logic_vector(31 DOWNTO 0);
	
	-- Steuerwerk
	signal start_tmp : std_logic := '0';

    
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
	
	

	addr_a <= "00" & offset;
	addr_b <= "01" & offset;
	
	op1 <= std_logic_vector(resize(signed(dout_a),18));--"00" & dout_a;--std_logic_vector(resize(signed(dout_a),18));
	op2 <= std_logic_vector(resize(signed(dout_b),18));--"00" & dout_b;
	--"00" & x"0007";
	
	prod_tmp <= std_logic_vector(resize(signed(prod),32));

	
	res <= std_logic_vector(sum);

	u0: ram_block
        PORT MAP(addra => addr_a,
         addrb => addr_b,
         clka => clk,
         clkb => clk,
         douta => dout_a,
         doutb => dout_b,
         ena => ram_en,
         enb => ram_en);

    
   -- Steuerwerk
   process(clk, rst) begin
      if rst = RSTDEF then
			offset <= (OTHERS => '0');
			done <= '0';
			acc_en <= '0';
			ram_en <= '0';
			start_tmp <= '0';
		elsif rising_edge(clk) then
			if swrst = RSTDEF then
				offset <= (OTHERS => '0');
				done <= '0';
				acc_en <= '0';
				ram_en <= '0';
				start_tmp <= '0';
			else
				if start_tmp = '0' then
					done <= '1';
					if strt = '1' then
						done <= '0';
						start_tmp <= '1';
						if sw /= x"00" then
							offset <= std_logic_vector(unsigned(sw) - 1);
							ram_en <= '1';
						end if;
					end if;
					
				else --start_tmp = '1'
					acc_en <= ram_en;

					if ram_en = '1' then
						if offset = x"00" then
							ram_en <= '0';
							--start_tmp <= '0';
							--done <= '1';
						else
							offset <= std_logic_vector(unsigned(offset) - 1);
						end if;
					elsif acc_en = '0' then
						start_tmp <= '0';--strt;
						done <= '1';--NOT strt;
					end if;
				end if;
			
			end if;
		end if; 
   end process;
   

	
   m0 : MULT18X18S
      port map (P => prod,
                A => op1,
                B => op2,
					 C => clk, -- clk
					 CE => '1',
					 R => '0'); -- clk enable
   
	


   -- Accumulator
   process(clk,rst) begin
		if rst = RSTDEF then
			sum <= (OTHERS => '0');
		elsif rising_edge(clk) then
			if swrst = RSTDEF then
				sum <= (OTHERS => '0');
			elsif acc_en = '1' then
				sum <= sum + signed(prod_tmp); --+ signed(prod_tmp);--resize(signed(prod),44);


				--REPORT "-----a: " & integer'image(to_integer(signed(dout_a)));
				--REPORT "-----b: " & integer'image(to_integer(signed(dout_b)));
				--REPORT "-----offset: " & integer'image(to_integer(signed(offset)));
				
				--REPORT "-----op1: " & integer'image(to_integer(signed(op1)));
				--REPORT "-----op2: " & integer'image(to_integer(signed(op2)));
				--REPORT "-----PROD: " & integer'image(to_integer(signed(prod_tmp)));

				--REPORT "-----addr_a: " & integer'image(to_integer(signed(addr_a)));
				--REPORT "-----addr_b: " & integer'image(to_integer(signed(addr_b)));
				--REPORT "----------------------------------------------------------";
				
				-- for i in 0 to prod'LENGTH-1 loop
            --report "prod_tmp("&integer'image(i)&") value is" &   
            --      std_logic'image(prod(i));
				--end loop;
				--REPORT "-----a: " & integer'image(to_integer(signed(dout_a)));
				--REPORT "-----b: " & integer'image(to_integer(signed(dout_b)));
				--REPORT "-----offset: " & integer'image(to_integer(signed(offset)));
				--REPORT "-----op1: " & integer'image(to_integer(signed(op1)));
				--REPORT "-----op2: " & integer'image(to_integer(signed(op2)));
				--REPORT "-----PROD: " & integer'image(to_integer(signed(prod_tmp)));

				--REPORT "-----addr_a: " & integer'image(to_integer(signed(addr_a)));
				--REPORT "-----addr_b: " & integer'image(to_integer(signed(addr_b)));

				--REPORT "-----RESULT:" & integer'image(to_integer(sum));
			end if;
		end if;
	end process;
   
	
	
	
	

    
end;