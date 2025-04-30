----------------------------------------------------------------------------------
-- Implements a 4-bit Ripple-Carry adder from instantiated Full Adders
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ripple_adder is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           Cout : out STD_LOGIC);
end ripple_adder;

architecture Behavioral of ripple_adder is

    -- Declare components here
    component full_adder is
        port (
            A     : in std_logic;
            B     : in std_logic;
            Cin   : in std_logic;
            S     : out std_logic;
            Cout  : out std_logic
            );
        end component full_adder;
    
    -- Declare signals here
    signal w_carry  : STD_LOGIC_VECTOR(2 downto 0); -- for ripple between adders

begin

-- PORT MAPS --------------------
    full_adder_0: full_adder
    port map(
        A     => A(0),
        B     => B(0),
        Cin   => Cin,   -- Directly to input here
        S     => S(0),
        Cout  => w_carry(0)
    );

    full_adder_1: full_adder
    port map(
        A     => A(1),
        B     => B(1),
        Cin   => w_carry(0),
        S     => S(1),
        Cout  => w_carry(1)
    );
    
    full_adder_2: full_adder
    port map(
        A     => A(2),
        B     => B(2),
        Cin   => w_carry(1),
        S     => S(2),
        Cout  => w_carry(2)
    );

    full_adder_3: full_adder
    port map(
        A     => A(3),
        B     => B(3),
        Cin   => w_carry(2),
        S     => S(3),
        Cout  => Cout
    );

end Behavioral;
