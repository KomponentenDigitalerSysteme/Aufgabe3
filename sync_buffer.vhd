
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_buffer IS
   GENERIC(RSTDEF:  std_logic := '1');
   PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
        clk:    IN  std_logic;  -- clock, rising edge
        en:     IN  std_logic;  -- enable, high active
        swrst:  IN  std_logic;  -- software reset, RSTDEF active
        din:    IN  std_logic;  -- data bit, input
        dout:   OUT std_logic;  -- data bit, output
        redge:  OUT std_logic;  -- rising  edge on din detected
        fedge:  OUT std_logic); -- falling edge on din detected
END sync_buffer;

--
-- Im Rahmen der 2. Aufgabe soll hier die Architekturbeschreibung
-- zur Entity sync_buffer implementiert werden.
--
ARCHITECTURE structure OF sync_buffer IS
    
    constant N_hysterese: natural := 32; -- 46???
    
    
    --signal clk_hysterese: std_logic;
    signal cnt_hysterese : integer range 0 to N_hysterese - 1;
    signal f1 : std_logic;
	 signal f2 : std_logic;
	 
	 signal state : std_logic;
	 signal f3 : boolean;
	 
BEGIN
	
	f3 <= cnt_hysterese < N_hysterese - 1;
	
   process(rst, clk) begin
		if rst = RSTDEF then
			state <= '0';
			cnt_hysterese <= 0;
			fedge <= '0';
			redge <= '0';
		elsif rising_edge(clk) then
			f1 <= din;
			
			if f1 = din then
				f2 <= f1;
			end if;
			
			if en = '1' then
				--redge <= '0';
				--fedge <= '0';
				
				if state = '0' then
					--if din = '0' and cnt_hysterese = '0' then
						--cnt_hysterese = cnt_hysterese;
					--end if;
					if f2 = '0' then
						if cnt_hysterese > 0 then
							cnt_hysterese <= cnt_hysterese - 1;
						end if;
					else
						if f3 then
							cnt_hysterese <= cnt_hysterese + 1;
						end if;
						if cnt_hysterese = N_hysterese - 1 then
							state <= '1';
							redge <= '1';
						end if;
					end if;
					--dout <= state;
					
				else -- state = '1'
					
					if f2 = '1' then
						--if cnt_hysterese = N_hysterese - 1 then
							--cnt_hysterese = cnt_hysterese;
						--end if;
						if f3 then
							cnt_hysterese <= cnt_hysterese + 1;
						end if;
					else
						if cnt_hysterese > 0 then
							cnt_hysterese <= cnt_hysterese - 1;
						end if;
						if cnt_hysterese = 0 then
							state <= '0';
							fedge <= '1';
						end if;
					end if;
				--dout <= state;
				end if;
			end if;
		end if;
   end process;
  
	
   --process(state) begin
	--	if falling_edge(state) then
--			fedge <= '1';
--		end if;
--		if rising_edge(state) then
--			redge <= '1';
--		end if;
--	end process;
   
END;