----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port (
        i_clk   : in STD_LOGIC;
        i_reset : in STD_LOGIC;
        i_adv   : in STD_LOGIC;
        o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
    );
end controller_fsm;


architecture FSM of controller_fsm is
    signal w_cycle     : std_logic_vector(3 downto 0) := "1000";
    signal w_adv_prev  : std_logic := '0';
begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                w_cycle <= "1000";
            else
                -- detect rising edge on i_adv
                if i_adv = '1' and w_adv_prev = '0' then
                    case w_cycle is
                        when "1000" => w_cycle <= "0001";
                        when "0001" => w_cycle <= "0010";
                        when "0010" => w_cycle <= "0100";
                        when "0100" => w_cycle <= "1000";
                        when others => w_cycle <= "1000";
                    end case;
                end if;
            end if;

            w_adv_prev <= i_adv;
        end if;
    end process;

    o_cycle <= w_cycle;

end FSM;

