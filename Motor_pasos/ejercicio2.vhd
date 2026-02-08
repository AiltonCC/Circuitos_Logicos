library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ejercicio2 is
    Port (
        clk         : in  STD_LOGIC;      -- Reloj principal (50 MHz)
        reset       : in  STD_LOGIC;      -- Señal de reset
        sentido   : in  STD_LOGIC;      -- Dirección del motor (0: horario, 1: antihorario)
        selecc   : in  STD_LOGIC_VECTOR(2 downto 0); -- Selección de velocidad (DIP switches)
        rpm : out STD_LOGIC_VECTOR(3 downto 0)  -- Salida para el motor (4 fases)
    );
end ejercicio2;

architecture control_rpm of ejercicio2 is
    -- Constantes para velocidades (en pasos/segundo)
    constant CLOCK  : integer := 50000000; -- Frecuencia del reloj principal (50 MHz)
    constant STEPS_PER_REV   : integer := 2048;     -- Pasos por revolución del motor

    -- Estados del motor (secuencia para 4 fases)
    type motor_states is (A, AB, B, BC, C, CD, D, DA);
    signal state         : motor_states := A;

    -- Señales internas
    signal contador       : integer range 0 to CLOCK := 0; -- Divisor de reloj
    signal pulso      : STD_LOGIC := '0';                  -- Pulso para el motor
    signal frec     : integer := 136;         -- Frecuencia seleccionada
begin
    -- Selección de velocidad basada en DIP switches
    process(selecc)
    begin
        case selecc is
            when "000" => frec <= (4*5*STEPS_PER_REV)/60; -- 1 RPM
            when "001" => frec <= (4*10*STEPS_PER_REV)/60; -- 3 RPM
            when "010" => frec <= (4*15*STEPS_PER_REV)/60; -- 5 RPM
            when "011" => frec <= (4*20*STEPS_PER_REV)/60; -- 10 RPM
            when "100" => frec <= (4*25*STEPS_PER_REV)/60; -- 15 RPM
            when "101" => frec <= (4*30*STEPS_PER_REV)/60; -- 20 RPM
            when others => frec <= (4*5*STEPS_PER_REV)/60; -- Default: 1 RPM
        end case;
    end process;

    -- Generación de pulsos
    process(clk, reset)
    begin
        if reset = '1' then
            contador <= 0;
            pulso <= '0';
        elsif rising_edge(clk) then
            if contador < CLOCK / frec then
                contador <= contador + 1;
            else
                contador <= 0;
                pulso <= not pulso; -- Generar pulso para el motor
            end if;
        end if;
    end process;

    -- Secuencia de pasos para el motor
    process(pulso, reset)
    begin
        if reset = '1' then
            state <= A;
        elsif rising_edge(pulso) then
            if sentido = '0' then -- Horario
                case state is
                    when A  => state <= AB;
                    when AB => state <= B;
                    when B  => state <= BC;
                    when BC => state <= C;
                    when C  => state <= CD;
                    when CD => state <= D;
                    when D  => state <= DA;
                    when DA => state <= A;
                end case;
            else -- Antihorario
                case state is
                    when A  => state <= DA;
                    when DA => state <= D;
                    when D  => state <= CD;
                    when CD => state <= C;
                    when C  => state <= BC;
                    when BC => state <= B;
                    when B  => state <= AB;
                    when AB => state <= A;
                end case;
            end if;
        end if;
    end process;

    -- Salida para las fases del motor
    process(state)
    begin
        case state is
            when A  => rpm <= "1000";
            when AB => rpm <= "1100";
            when B  => rpm <= "0100";
            when BC => rpm <= "0110";
            when C  => rpm <= "0010";
            when CD => rpm <= "0011";
            when D  => rpm <= "0001";
            when DA => rpm <= "1001";
            when others => rpm <= "0000";
        end case;
    end process;

end architecture;