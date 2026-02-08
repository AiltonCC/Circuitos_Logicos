library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ejercicio5 is
    Port (
        clk        : in  STD_LOGIC;      -- Reloj principal del sistema
		  clk_in		 : in  STD_LOGIC;		  -- Frecuencia a detectar
        reset      : in  STD_LOGIC;      -- Señal de reset
		  medir		 : in  STD_LOGIC;
		  display  	 : out std_logic_vector(7 downto 0);		--Display 7 segmentos
		  numdisp	 : out std_logic_vector(1 downto 0));		--Numero de display
    
end ejercicio5;

architecture frecuenciometro of ejercicio5 is
    --Variables para el frecuenciometro
	 signal contador_1s  : unsigned(25 downto 0) := (others => '0'); -- Contador para 0.5 Hz
    signal pulsos 		: integer range 0 to 99 := 0;       -- Contador de pulsos de la señal
    signal actmed   		: STD_LOGIC := '0';                 -- Indicador de medición activa
	 signal freq_result  : integer range 0 to 99 := 0;       -- Resultado de la frecuencia
	 signal clk_in_2 	: STD_LOGIC := '0';               -- Almacena el estado previo de `signal_in`
	 
	 --Variables para display
	 signal contador_60Hz   : unsigned(18 downto 0) := (others => '0'); -- Contador para 60 Hz
	 signal clk_60Hz   : std_logic := '0';
	 signal num0 : integer range 0 to 9 := 0;--Numero de cada display
	 signal disp : std_logic := '0';
	 signal dis : unsigned(7 downto 0);	
begin

	-- Proceso para medir la frecuencia
    process(clk, reset, clk_in)
    begin	
        if reset = '1' then
            contador_1s <= (others => '0');
            pulsos <= 0;
            freq_result <= 0;
            actmed <= '0';
				clk_in_2 <= '0';
        elsif rising_edge(clk) then
				-- Actualizar el estado previo de `clk_in`
            clk_in_2 <= clk_in;
				
				--Divisor para 60 Hz
				if contador_60Hz = 208333 - 1 then
                contador_60Hz <= (others => '0'); 		-- Reinicia el contador
                clk_60Hz <= not clk_60Hz;     -- Cambia el estado de la señal de salida
            else
                contador_60Hz <= contador_60Hz + 1; 	-- Incrementa el contador
            end if;
				
				--Contador
				if medir = '1' and actmed = '0' then
                -- Iniciar medición al presionar el botón
                actmed <= '1';
                contador_1s <= (others => '0');
                pulsos <= 0;
            elsif actmed = '1' then
                if contador_1s < 50000000 - 1 then
                    contador_1s <= contador_1s + 1;
                    -- Contar pulsos de la señal de entrada
                    if clk_in = '1' and clk_in_2 = '0' then
                        pulsos <= pulsos + 1;
                    end if;
                else
                    -- Terminar medición y almacenar el resultado
                    actmed <= '0';
                    freq_result <= pulsos;
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
	process(disp,freq_result)
	begin
		if disp = '0' then
			num0 <= freq_result mod 10;
			numdisp <= "01";
		else
			num0 <= freq_result / 10;
			numdisp <= "10";
		end if;
	end process;
	
	--Display 7 segmentos
	process (num0) 
	  begin
		case num0 is
			when  0  =>  dis  <=  X"3F";  --0111111  gfedcba
			when  1  =>  dis  <=  X"06";  --0000110
			when  2  =>  dis  <=  X"5B";
			when  3  =>  dis  <=  X"4F";
			when  4  =>  dis	<=  X"66";
			when  5  =>  dis  <=  X"6D";
			when  6  =>  dis  <=  X"7D";
			when  7  =>  dis  <=  X"07";
			when  8  =>  dis  <=  X"7F";
			when  9  =>  dis  <=  X"6F";
			when  others  =>  dis  <=  X"00";
		end case;
	end process;
		display <= std_logic_vector(dis);
end architecture;

