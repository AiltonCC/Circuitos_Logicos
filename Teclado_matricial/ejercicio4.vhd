library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ejercicio4 is
	port ( clk :in std_logic;
			reset : in std_logic;
			col :in std_logic_vector(3 downto 0);		--Columnas
			fila :out std_logic_vector(3 downto 0);	--Filas
			contar : in std_logic;							--Iniciar conteo
			cargar : in std_logic;
			d: out std_logic_vector (7 downto 0);		--Display
			numdisp: out std_logic_vector(1 downto 0);	--Numero de display
			dav :out STD_LOGIC );							--Indicador de tecla presionada
end ejercicio4;

architecture teclado of ejercicio4 is
	--Variables para el teclado matricial
	signal detener : STD_LOGIC;
	signal datos :STD_LOGIC_VECTOR (3 downto 0);
	signal siguiente : STD_LOGIC;
	signal num : STD_LOGIC_VECTOR(7 downto 0);
	--Variables para el contador
	signal conteo : unsigned(7 downto 0);
	signal actcont : std_logic;
	--Variables para display
	signal num0: std_logic_vector(3 downto 0);--Numero de cada display
	signal disp : std_logic;
	--Variables para las frecuencias
    signal contador_0_5Hz  : unsigned(25 downto 0) := (others => '0'); -- Contador para 0.5 Hz
	 signal contador_60Hz   : unsigned(18 downto 0) := (others => '0'); -- Contador para 60 Hz
    signal clk_0_5Hz  : std_logic := '0';
	 signal clk_60Hz   : std_logic := '0'; 
begin
	--Obtencion del numero presionado
	process (clk)
		variable anillo :STD_LOGIC_VECTOR (3 downto 0);
	begin
		if rising_edge(clk) then
			if detener = '0' then	--Ciclo inifito mientras detener sea 0
				case anillo is
					when "1110" => anillo := "1101";
					when "1101" => anillo := "1011";
					when "1011" => anillo := "0111";
					when "0111" => anillo := "1110";
					when others => anillo := "1110";
				end case;
			end if;
			dav <= detener;
		end if;
		fila <= anillo;
 
		case anillo is		--Se analiza en que parte del ciclo se quedo parado
			when "1110" => datos(3 downto 2) <= "00";
			when "1101" => datos(3 downto 2) <= "01";
			when "1011" => datos(3 downto 2) <= "10";
			when "0111" => datos(3 downto 2) <= "11";
			when others => datos(3 downto 2) <= "00";
		end case;
 
		case col is		--Analiza la salida y detiene el ciclo
			when "1110" => datos(1 downto 0) <= "00"; detener <= '1';
			when "1101" => datos(1 downto 0) <= "01"; detener <= '1';
			when "1011" => datos(1 downto 0) <= "10"; detener <= '1';
			when "0111" => datos(1 downto 0) <= "11"; detener <= '1';
			when others => datos(1 downto 0) <= "00"; detener <= '0';
		end case;
		
		if reset = '1' then
			siguiente <= '0';
			num <= X"00";
		elsif detener = '1' and siguiente = '0' then 
			num(3 downto 0) <= datos;
			siguiente <= '1';
		elsif detener = '1' and siguiente = '1' then
			num(7 downto 4) <= datos;
		end if;
	end process;
	
	--Obtencion de frecuencias
	process(clk)
	begin
		if rising_edge(clk) then
				--Divisor para 60 Hz
			if contador_60Hz = 208333 - 1 then
             contador_60Hz <= (others => '0'); 		-- Reinicia el contador
             clk_60Hz <= not clk_60Hz;     -- Cambia el estado de la señal de salida
         else
             contador_60Hz <= contador_60Hz + 1; 	-- Incrementa el contador
         end if;
			
			-- Divisor para 0.5 Hz
         if contador_0_5Hz = 50000000 - 1 then
                contador_0_5Hz <= (others => '0');
                clk_0_5Hz <= not clk_0_5Hz;
         else
                contador_0_5Hz <= contador_0_5Hz + 1;
         end if;
		end if;
	end process;
	
	--Contador
	process(reset, clk_0_5Hz)
		begin
			if reset = '1' then 
				conteo <= X"00";			--Resetear valor
				actcont <= '0';
			elsif contar = '1' then
					actcont <= '1';
			elsif cargar = '1' then
					conteo <= unsigned(num);	--Asigna el valor inicial al conteo
			elsif rising_edge(clk_0_5Hz) then
				if actcont = '1' then 
				      conteo <= conteo + 1;				--Incremento
						if conteo = X"FF" then conteo <= X"00";
						end if;
				end if;
			end if;
	end process;
	
	--Multiplexor
	process (clk_60Hz) 
	  begin
		if rising_edge(clk_60Hz) then
			disp <= not disp;
		end if;
	end process;

	--Seleccionar display
	process(disp,num0)
	begin
		if disp = '0' then
			num0 <= std_logic_vector(conteo(3 downto 0));
			numdisp <= "01";
		else
			num0 <= std_logic_vector(conteo(7 downto 4));
			numdisp <= "10";
		end if;
	end process;
	
	--Display
	process (num0) begin 
		case num0 is
			when  X"0"  =>  d  <=  X"3F";  --0111111  gfedcba
			when  X"1"  =>  d  <=  X"06";  --0000110
			when  X"2"  =>  d  <=  X"5B";
			when  X"3"  =>  d  <=  X"4F";
			when  X"4"  =>  d  <=  X"66";
			when  X"5"  =>  d  <=  X"6D";
			when  X"6"  =>  d  <=  X"7D";
			when  X"7"  =>  d  <=  X"07";
			when  X"8"  =>  d  <=  X"7F";
			when  X"9"  =>  d  <=  X"6F";
			when  X"A"  =>  d  <=  X"77";
			when  X"B"  =>  d  <=  X"7C";
			when  X"C"  =>  d  <=  X"39";
			when  X"D"  =>  d  <=  X"5E";
			when  X"E"  =>  d  <=  X"79";
			when  others  =>  d  <=  X"71";
		end case;
	end process;
end architecture;