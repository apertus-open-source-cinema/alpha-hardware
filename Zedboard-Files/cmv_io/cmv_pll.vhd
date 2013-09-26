----------------------------------------------------------------------------
--  cmv_pll.vhd
--	ZedBoard simple VHDL example
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

entity cmv_pll is
    port (
	clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_clk : out std_logic_vector(5 downto 0);
	--
	pll_locked : out std_logic	-- PLL locked
    );

end entity cmv_pll;


architecture RTL of cmv_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_clk_out : std_logic_vector(5 downto 0);

begin
    cmv_pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT => 9,
	CLKOUT0_DIVIDE => 900/300,	-- 300MHz LVDS clock
	CLKOUT1_DIVIDE => 900/150,	-- 150MHz LVDS clock
	CLKOUT2_DIVIDE => 900/100,	-- 100MHz LVDS clock
	CLKOUT3_DIVIDE => 900/60,	--  60MHz CMV Clock
	CLKOUT4_DIVIDE => 900/30,	--  30MHz CMV Input Clock
	CLKOUT5_DIVIDE => 900/10,	--  10MHz CMV SPI Clock
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_clk_out(0),
	CLKOUT1 => pll_clk_out(1),
	CLKOUT2 => pll_clk_out(2),
	CLKOUT3 => pll_clk_out(3),
	CLKOUT4 => pll_clk_out(4),
	CLKOUT5 => pll_clk_out(5),

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    BUFG_inst : BUFG
	port map (
	    I => pll_fbout,
	    O => pll_fbin );

    GEN_BUF : for N in 0 to 5 generate
	BUFG_inst : BUFG
	    port map (
		I => pll_clk_out(N),
		O => pll_clk(N) );
    end generate GEN_BUF;

end RTL;
