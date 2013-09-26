----------------------------------------------------------------------------
--  pmod_debug.vhd
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

entity pmod_debug is
    port (
	clk	: in std_logic;				-- base clock
	--
	value	: in std_logic_vector(63 downto 0);	-- '1' on '0' off
	update	: in std_logic;				-- load
	--
	jxm	: out std_logic_vector(3 downto 0);	-- mask '0' = on
	jxa	: out std_logic_vector(3 downto 0)	-- address (inv)
    );

end entity pmod_debug;

architecture RTL of pmod_debug is
begin

    pmod_vis: process(clk, value, update)
	variable vis_addr : natural range 0 to 15 := 15;
	variable vis_cnt : natural range 0 to 15 := 0;
	
	variable mem : std_logic_vector(63 downto 0);
    begin
	if rising_edge(update) then
	    mem := value;
	end if;

	if rising_edge(clk) then
	    if vis_cnt = 0 then		-- setup address
		jxa <= std_logic_vector(to_unsigned(vis_addr, 4));
	    elsif vis_cnt = 15 then	-- unload/restart
		jxm <= "1111";

		if vis_addr = 0 then
		    vis_addr := 15;
		else
		    vis_addr := vis_addr - 1;
		end if;
	    else
		jxm(0) <= not mem(vis_addr);
		jxm(1) <= not mem(vis_addr + 16);
		jxm(2) <= not mem(vis_addr + 32);
		jxm(3) <= not mem(vis_addr + 48);
	    end if;

	    if vis_cnt = 63 then
		vis_cnt := 0;
	    else
		vis_cnt := vis_cnt + 1;
	    end if;
	end if;
    end process;

end RTL;
