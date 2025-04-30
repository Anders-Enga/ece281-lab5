--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        btnL    :   in std_logic;
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
    component ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
    end component ALU;
    
    component controller_fsm is
        Port (
            i_clk   : in STD_LOGIC;
            i_reset : in STD_LOGIC;
            i_adv   : in STD_LOGIC;
            o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component controller_fsm;

    
    component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
    end component twos_comp;
    
    component clock_divider is
	generic ( constant k_DIV : natural := 2	);
	port ( 	i_clk    : in std_logic;
			i_reset  : in std_logic;		   
			o_clk    : out std_logic		  
	);
    end component clock_divider;
    
    component TDM4 is
	generic ( constant k_WIDTH : natural  := 4);
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC;
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
    end component TDM4;
    
    component sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
    end component sevenseg_decoder;
    
    signal w_clk : std_logic := '0';
    -- signal w_clk_slow : std_logic := '0';
    signal w_A   : std_logic_vector (7 downto 0) := x"00";
    signal w_B   : std_logic_vector (7 downto 0) := x"00";
    
    signal w_sign : std_logic := '0';
    signal w_hund : std_logic_vector (3 downto 0) := x"0";
    signal w_tens : std_logic_vector (3 downto 0) := x"0";
    signal w_ones : std_logic_vector (3 downto 0) := x"0";
    
    signal w_Hex : std_logic_vector (3 downto 0) := x"0";
    signal w_seg : std_logic_vector (6 downto 0) := "0000000";
    signal w_sel : std_logic_vector (3 downto 0) := x"0";
    
    signal w_cycle : std_logic_vector (3 downto 0) := x"0";
    signal w_adv : std_logic := '0';
    
    signal w_flags : std_logic_vector (3 downto 0) := x"0";
    signal w_result : std_logic_vector (7 downto 0) := x"00";
    
    signal w_bin : std_logic_vector (7 downto 0) := x"00";
    
    signal w_reset : std_logic := '0';
    
    signal w_btnC_prev : std_logic := '0';
    -- signal w_btnC_debounced : std_logic := '0';
    -- signal w_btnC_sync     : std_logic_vector(7 downto 0) := x"00";
  
begin
	-- PORT MAPS ----------------------------------------
    controller_inst: controller_fsm port map (
        i_clk => w_clk,
        i_reset => w_reset,
        i_adv => w_adv,
        o_cycle => w_cycle
    );   
    
    ALU_inst: ALU port map (
        i_A => w_A,
        i_B => w_B,
        i_op => sw(2 downto 0),
        o_result => w_result,
        o_flags => w_flags
    );  
    
    twos_comp_inst:  twos_comp port map (
        i_bin => w_bin,
        o_sign => w_sign,
        o_hund => w_hund,
        o_tens => w_tens,
        o_ones => w_ones
    );
    
    TDM4_inst: TDM4 port map (
        i_clk => w_clk,
        i_reset => w_reset,
        i_D0 => w_ones,
        i_D1 => w_tens,
        i_D2 => w_hund,
        i_D3 => x"0",
        o_data => w_Hex,
        o_sel => w_sel
    );      
    
    clkdiv_inst : clock_divider 		--instantiation of clock_divider to take 
        generic map ( k_DIV => 100000 ) -- 500 Hz clock from 100 MHz
        port map (						  
            i_clk   => clk,
            i_reset => btnL,
            o_clk   => w_clk
    );
    
--    clkdiv_inst_test : clock_divider 		--instantiation of clock_divider to take 
--        generic map ( k_DIV => 250000000 ) -- 0.2 Hz clock from 100 MHz
--        port map (						  
--            i_clk   => clk,
--            i_reset => w_reset,
--            o_clk   => w_clk_slow
--    );
    
    sevenseg_decoder_inst : sevenseg_decoder port map (
        i_Hex => w_Hex,
        o_seg_n => w_seg
    );
	
	
	-- CONCURRENT STATEMENTS ----------------------------
	w_bin <= w_A when w_cycle = "0001" else
	         w_B when w_cycle = "0010" else
	         w_result when w_cycle = "0100" else
	         x"00";
	         
    seg <= w_seg when (w_sel = "1110" or w_sel = "1101" or w_sel = "1011") else
           "1111111" when w_sign = '0' else  -- assumes 0 = positive
           "0111111";                        -- negative sign
	       
	an <= "1111" when w_cycle(3) = '1' else
	      w_sel;
	
	led(3 downto 0) <= w_cycle;
	led(15 downto 12) <= w_flags;
	
	led(11 downto 4) <= (others => '0');
	
	w_reset <= btnU;
	
--	test_proc : process (w_clk_slow)
--    begin
--        if (rising_edge(w_clk_slow)) then
--            w_adv <= (not w_adv);    -- next state becomes current state
--        end if;
--    end process test_proc;
	  
--	process(w_clk)
--        begin
--            if rising_edge(w_clk) then
--                -- Keep track of button on last 8 clock cycles
--                w_btnC_sync(7 downto 1) <= w_btnC_sync(6 downto 0);
--                w_btnC_sync(0) <= btnC;
                
--                if w_btnC_sync = x"FF" then -- Wait for button to be stable to count a press
--                    w_btnC_debounced <= '1';
--                elsif w_btnC_sync = x"00" then 
--                    w_btnC_debounced <= '0';
--                end if;
--            end if;
--        end process;  
	
    process(w_clk)
        begin
            if rising_edge(w_clk) then
                if btnC = '1' and w_btnC_prev = '0' then
                    w_adv <= '1';  -- Rising edge of button detected
                else
                    w_adv <= '0';  -- Clear after one clock cycle
                end if;
                w_btnC_prev <= btnC;
            end if;
    end process;
	
	-- Registers ----------------------------------------
	register_A : process (w_clk, w_cycle(0), w_reset)
    begin
        if w_reset = '1' then
            w_A <= x"00";
        elsif (rising_edge(w_clk)) then
            if (w_cycle(0) = '1') then
                w_A <= sw(7 downto 0);    -- next state becomes current state
            end if;
        end if;
    end process register_A;
    
	register_B : process (w_clk, w_cycle(1), w_reset)
    begin
        if w_reset = '1' then
            w_B <= x"00";
        elsif (rising_edge(w_clk)) then
            if (w_cycle(1) = '1') then
                w_B <= sw(7 downto 0);    -- next state becomes current state
            end if;
        end if;
    end process register_B;
	
end top_basys3_arch;
