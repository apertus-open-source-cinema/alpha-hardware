----------------------------------------------------------------------------
--  divider.vhd
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

entity divider is
    generic (
	RATIO : integer := 10000000
    );
    port (
	clk_in	: in std_logic;		-- input clock
	--
	enable	: in std_logic;		-- enable divider
	--
	clk_out : out std_logic		-- output clk_in
    );

    attribute buffer_type : string;	-- buffer type

    attribute buffer_type of clk_out : signal is "bufg";

end entity divider;

architecture RTL of divider is
begin
    divide_proc : process(clk_in, enable)
    variable count : integer range 0 to RATIO - 1;
    begin
	if enable = '0' then		-- reset
	    count := 0;
	elsif rising_edge(clk_in) then	-- clk
	    if count = RATIO - 1 then
		count := 0;
	    else
		count := count + 1;
	    end if;
	end if;
	
	if count < RATIO / 2 then
	    clk_out <= '0';
	else
	    clk_out <= '1';
	end if;
    end process;
end RTL;
