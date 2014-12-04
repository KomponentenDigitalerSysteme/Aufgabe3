LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF:  std_logic := '0');
   PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
        clk:   IN  std_logic;                       -- clock,           rising edge
        en:    IN  std_logic;                       -- enable,          active high
        swrst: IN  std_logic;                       -- software reset,  active RSTDEF
        data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      positiv logic
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
        an:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable (anode control) signals,      active low
        dp:    OUT std_logic;                       -- 1 decimal point output,                      active low
        seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 FPGA connections to seven-segment display, active low
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS
  -- hier sind benutzerdefinierte Konstanten und Signale einzutragen
  -- Modulo 2**14 Zaehler
  constant N: natural := 14;
  signal cnt: std_logic_vector (N-1 DOWNTO 0);
  
  signal clk_en: std_logic;
  
  -- Modulo 4 Zaehler
  constant N4: natural := 2;
  signal cnt4: std_logic_vector (N4-1 DOWNTO 0);
  signal an_tmp: std_logic_vector(3 DOWNTO 0);
   
   -- 1-aus-4 Multiplexer fuer 7-aus-4 Decoder
   signal sel_number: std_logic_vector(3 DOWNTO 0);
    
BEGIN
   -- Modulo-2**14-Zaehler als Prozess
   process(rst, clk) begin
      if rst = RSTDEF then
         cnt <= (OTHERS => '0');
         clk_en <= '0';
      elsif rising_edge(clk) then
         clk_en <= '0';
         if en='1' then
            if cnt=N-1 then
               clk_en <= '1';
            end if;
				cnt <= cnt + 1;
         end if;
      end if;
   end process;
   
   -- Modulo-4-Zaehler als Prozess
   process(rst, clk, clk_en) begin
      if rst=RSTDEF then
         cnt4 <= (OTHERS => '0');
      elsif rising_edge(clk) then
         if clk_en='1' then
               cnt4 <= cnt4 + 1;
         end if;
      end if;
   end process;

   -- 1-aus-4-Dekoder als selektierte Signalzuweisung
   with cnt4 select
      an_tmp <= "1110" when "00",
                "1101" when "01",
                "1011" when "10",
                "0111" when "11",
					 "0000" when others;
   
   an <= an_tmp when rst /= RSTDEF and swrst /= RSTDEF else (others => '1');

   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung SW
   with cnt4 select
      sel_number  <= data(3 DOWNTO 0) when "00",
                     data(7 DOWNTO 4) when "01",
                     data(11 DOWNTO 8) when "10",
                     data(15 DOWNTO 12) when "11",
							"0000" when others;
   
   -- 7-aus-4-Dekoder als selektierte Signalzuweisung
   with sel_number select
      seg <=   "0000001" when "0000",
               "1001111" when "0001",
               "0010010" when "0010",
               "0000110" when "0011",
               "1001100" when "0100",
               "0100100" when "0101",
               "0100000" when "0110",
               "0001111" when "0111",
               "0000000" when "1000",
               "0000100" when "1001",
               "0001000" when "1010",
               "1100000" when "1011",
               "0110001" when "1100",
               "1000010" when "1101",
               "0110000" when "1110",
               "0111000" when "1111",
               "1111111" when others;
   
   
   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung
   with cnt4 select
      dp <= not dpin(0) when "00",
            not dpin(1) when "01",
            not dpin(2) when "10",
            not dpin(3) when "11",
				'0' when others;

END struktur;