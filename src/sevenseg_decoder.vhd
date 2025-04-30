----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2025 09:31:30 PM
-- Design Name: 
-- Module Name: sevenseg_decoder - Behavioral
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

entity sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end sevenseg_decoder;

architecture Behavioral of sevenseg_decoder is

signal w_seg : std_logic_vector(6 downto 0) := "0000000";

begin

    -- LUT for w_seg based on prelab truth table
    with i_Hex select
    w_seg   <=  "1111110" when x"0",
                "0110000" when x"1",
                "1101101" when x"2",
                "1111001" when x"3",
                "0110011" when x"4",
                "1011011" when x"5",
                "1011111" when x"6",
                "1110000" when x"7",
                "1111111" when x"8",
                "1110011" when x"9",
                "1110111" when x"A",
                "0011111" when x"B",
                "0001101" when x"C",
                "0111101" when x"D",
                "1001111" when x"E",
                "1000111" when x"F",
                "0000000" when others;
        
    -- Flipped mapping to o_seg_n to match constraints file
    -- Invert w_seg because the cathodes are active LOW
    o_seg_n(0) <= not w_seg(6); -- Sa
    o_seg_n(1) <= not w_seg(5); -- Sb
    o_seg_n(2) <= not w_seg(4); -- Sc
    o_seg_n(3) <= not w_seg(3); -- Sd
    o_seg_n(4) <= not w_seg(2); -- Se
    o_seg_n(5) <= not w_seg(1); -- Sf
    o_seg_n(6) <= not w_seg(0); -- Sg


end Behavioral;
