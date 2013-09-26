----------------------------------------------------------------------------
--  reg_spi.vhd
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


entity reg_spi is
    port (
	m_axi_aclk : in std_logic;
	--
	m_axi_aresetn : in std_logic;
	--	read address
	m_axi_arid : in std_logic_vector(11 downto 0);
	m_axi_araddr : in std_logic_vector(31 downto 0);
	m_axi_arvalid : in std_ulogic;
	m_axi_arready : out std_ulogic;
	--	read data
	m_axi_rid : out std_logic_vector(11 downto 0);
	m_axi_rdata : out std_logic_vector(31 downto 0);
	m_axi_rresp : out std_logic_vector(1 downto 0);
	m_axi_rvalid : out std_ulogic;
	m_axi_rready : in std_ulogic;
	--	write address
	m_axi_awid : in std_logic_vector(11 downto 0);
	m_axi_awaddr : in std_logic_vector(31 downto 0);
	m_axi_awvalid : in std_ulogic;
	m_axi_awready : out std_ulogic;
	--	write data
	m_axi_wdata : in std_logic_vector(31 downto 0);
	m_axi_wstrb : in std_logic_vector(3 downto 0);
	m_axi_wlast : in std_ulogic;
	m_axi_wvalid : in std_ulogic;
	m_axi_wready : out std_ulogic;
	--	write response
	m_axi_bid : out std_logic_vector(11 downto 0);
	m_axi_bresp : out std_logic_vector(1 downto 0);
	m_axi_bvalid : out std_ulogic;
	m_axi_bready : in std_ulogic;
	--
	spi_clk : out std_logic;
	spi_en : out std_logic;
	spi_in : out std_logic;
	spi_out : in std_logic
    );
end entity reg_spi;


architecture RTL of reg_spi is

    signal spi_clk_in : std_logic;

    signal spi_write : std_logic;
    signal spi_addr : std_logic_vector(6 downto 0);
    signal spi_din : std_logic_vector(15 downto 0);
    signal spi_dout : std_logic_vector(15 downto 0);

    signal spi_go : std_logic;
    signal spi_done : std_logic;

begin

    div_inst : entity work.divider
    generic map (
	RATIO => 8 )
    port map (
	clk_in => m_axi_aclk,
	enable => '1',
	clk_out => spi_clk_in );

    spi_inst : entity work.cmv_spi
    port map (
	spi_clk_in => spi_clk_in,

	spi_write => spi_write,
	spi_addr => spi_addr,
	spi_din => spi_din,
	spi_dout => spi_dout,
	spi_go => spi_go,
	spi_done => spi_done,

	spi_clk => spi_clk,
	spi_en => spi_en,
	spi_in => spi_in,
	spi_out => spi_out );

    reg_rwseq_proc : process (
	m_axi_aclk, m_axi_aresetn,
	m_axi_araddr, m_axi_arvalid, m_axi_rready,
	m_axi_awaddr, m_axi_awvalid, m_axi_wdata,
	m_axi_wstrb, m_axi_wvalid, m_axi_bready,
	spi_dout )

	variable rwid_v : std_logic_vector(11 downto 0);
	variable addr_v : std_logic_vector(31 downto 0);

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable rresp_v : std_logic_vector(1 downto 0) := "00";
	variable bresp_v : std_logic_vector(1 downto 0) := "00";

	variable spi_write_v : std_logic := '1';
	variable spi_go_v : std_logic := '0';

	type rw_state is (
	    idle,
	    r_addr, r_spi, r_data, r_done,
	    w_addr, w_data, w_spi, w_resp, w_done);

	variable state : rw_state := idle;

	variable cdown : natural;

    begin
	if rising_edge(m_axi_aclk) then
	    if m_axi_aresetn = '0' then
		rwid_v := (others => '0');
		addr_v := (others => '0');

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		spi_go_v := '0';

		state := idle;

	    else
		case state is
		    when idle =>
			if m_axi_arvalid = '1' then	-- address _is_ valid
			    arready_v := '1';		-- we are ready for transfer
			    state := r_addr;

			elsif m_axi_awvalid = '1' then	-- address _is_ valid
			    awready_v := '1';		-- we are ready for transfer
			    state := w_addr;

			end if;

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		    when r_addr =>
			if m_axi_arvalid = '1' then	-- actual transfer
			    rwid_v := m_axi_arid;
			    addr_v := m_axi_araddr;

			    spi_write_v := '0';
			    spi_go_v := '1';
			    cdown := 31*8;

			    state := r_spi;
			else
			    state := idle;
			end if;

		    when r_spi =>
			if cdown = 0 then
			    spi_go_v := '0';

			    state := r_data;
			else
			    cdown := cdown - 1;
			end if;

		    when r_data =>

			spi_go_v := '0';

			rresp_v := "00";
			rvalid_v := '1';			-- data is valid

			if m_axi_rready = '1' then
			    state := r_done;
			end if;

		    when r_done =>
			arready_v := '0';
			rvalid_v := '0';

			state := idle;

		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		    when w_addr =>
			if m_axi_awvalid = '1' then	-- address transfer
			    rwid_v := m_axi_awid;
			    addr_v := m_axi_awaddr;

			    wready_v := '1';		-- we are ready for data
			    state := w_data;
			else
			    state := idle;
			end if;

		    when w_data =>
			if m_axi_wvalid = '1' then	-- data transfer
			    bresp_v := "00";		-- transfer OK

			    spi_write_v := '1';
			    spi_go_v := '1';

			    if m_axi_wlast = '1' then	-- last write
				cdown := 31*8;

				state := w_spi;
			    end if;
			end if;

		    when w_spi =>
			if cdown = 0 then
			    spi_go_v := '0';

			    bvalid_v := '1';		-- response valid
			    state := w_resp;
			else
			    cdown := cdown - 1;
			end if;

		    when w_resp =>
			if m_axi_bready = '1' then	-- master ready
			    state := w_done;
			end if;

		    when w_done =>
			awready_v := '0';
			wready_v := '0';
			bvalid_v := '0';

			state := idle;

		end case;
	    end if;
	end if;

	m_axi_rid <= rwid_v;
	m_axi_bid <= rwid_v;

	m_axi_arready <= arready_v;
	m_axi_rvalid <= rvalid_v;

	m_axi_awready <= awready_v;
	m_axi_wready <= wready_v;
	m_axi_bvalid <= bvalid_v;

	m_axi_rresp <= rresp_v;
	m_axi_bresp <= bresp_v;

	spi_addr <= addr_v(8 downto 2);
	spi_din <= m_axi_wdata(15 downto 0);
	m_axi_rdata(15 downto 0) <= spi_dout;

	spi_write <= spi_write_v;
	spi_go <= spi_go_v;

    end process;

end RTL;
