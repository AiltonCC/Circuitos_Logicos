library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ejercicio1 is
    Port (
        clk        : in  STD_LOGIC;      -- Reloj principal del sistema
        reset      : in  STD_LOGIC;      -- Señal de reset
        dip_sw     : in  STD_LOGIC_VECTOR(3 downto 0); -- DIP switch de selección
        pwm_out    : out STD_LOGIC       -- Salida PWM
    );
end ejercicio1;

architecture PWM of ejercicio1 is
    constant clk_frec : integer := 50000000; 					-- Frecuencia del reloj 
    constant pwm_frec   : integer := 4000;    					-- Frecuencia de PWM 
    constant frec  : integer := clk_frec / pwm_frec; 			-- Cuenta máxima para 4 kHz

    signal contador      : integer range 0 to frec-1 := 0; -- Contador
    signal duty_cycle   : integer range 0 to frec := 0;   	-- Ciclo de trabajo
    signal pwm_level    : integer range 0 to 10 := 0;          -- Nivel de PWM (0-10)
begin
    -- Proceso para manejar el contador y generar la señal PWM
    process(clk, reset)
    begin
        if reset = '1' then
            contador <= 0;
            pwm_out <= '0';
        elsif rising_edge(clk) then
            if contador < frec - 1 then	--Cuenta los ciclos de reloj para completar un periodo del PWM.
                contador <= contador + 1;
            else
                contador <= 0;
            end if;

            -- Generación de la señal PWM
            if contador < duty_cycle then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;
        end if;
    end process;

    -- Seleccion del ancho de pulso
    process(dip_sw)
    begin
        case dip_sw is
            when "0000" => pwm_level <= 0;  -- 0%
            when "0001" => pwm_level <= 1;  -- 10%
            when "0010" => pwm_level <= 2;  -- 20%
            when "0011" => pwm_level <= 3;  -- 30%
            when "0100" => pwm_level <= 4;  -- 40%
            when "0101" => pwm_level <= 5;  -- 50%
            when "0110" => pwm_level <= 6;  -- 60%
            when "0111" => pwm_level <= 7;  -- 70%
            when "1000" => pwm_level <= 8;  -- 80%
            when "1001" => pwm_level <= 9;  -- 90%
            when "1010" => pwm_level <= 10; -- 100%
            when others => pwm_level <= 0;  -- 0%
        end case;

        -- Calcular el valor del ciclo de trabajo de acuerdo con el nivel de PWM
        duty_cycle <= (pwm_level * frec) / 10;
    end process;

end architecture;