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
	axi_state : out std_logic_vector(3 downto 0);
	--
	spi_bclk : in std_logic;
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
    signal spi_go : std_logic;

    signal spi_dout : std_logic_vector(15 downto 0);
    signal spi_active : std_logic;

begin

    spi_inst : entity work.cmv_spi
	port map (
	    spi_clk_in => spi_bclk,

	    spi_write => spi_write,
	    spi_addr => spi_addr,
	    spi_din => spi_din,
	    spi_go => spi_go,

	    spi_dout => spi_dout,
	    spi_active => spi_active,

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
	    r_addr, r_go, r_spi, r_data, r_done,
	    w_addr, w_data, w_go, w_spi, w_resp, w_done);

	variable state : rw_state := idle;

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

			    state := r_go;
			else
			    state := idle;
			end if;

		    when r_go =>			-- wait for spi to start
			if spi_active = '1' then
			    spi_go_v := '0';

			    state := r_spi;
			end if;

		    when r_spi =>			-- wait for spi to finish
			if spi_active = '0' then
			    state := r_data;
			end if;

		    when r_data =>
			rresp_v := "00";
			rvalid_v := '1';		-- data is valid

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
				state := w_go;
			    end if;
			end if;

		    when w_go =>
			if spi_active = '1' then	-- wait for spi to start
			    spi_go_v := '0';

			    state := w_spi;
			end if;

		    when w_spi =>
			if spi_active = '0' then	-- wait for spi to finish
			    bvalid_v := '1';		-- response valid
			    state := w_resp;
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

	case state is
	    when idle	=> axi_state <= "0000";

	    when r_addr => axi_state <= "0001";
	    when r_go	=> axi_state <= "0011";
	    when r_spi	=> axi_state <= "0100";
	    when r_data => axi_state <= "0110";
	    when r_done => axi_state <= "0111";

	    when w_addr => axi_state <= "1001";
	    when w_data => axi_state <= "1010";
	    when w_go	=> axi_state <= "1011";
	    when w_spi	=> axi_state <= "1100";
	    when w_resp => axi_state <= "1101";
	    when w_done => axi_state <= "1111";
	end case;

    end process;

end RTL;
