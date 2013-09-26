----------------------------------------------------------------------------
--  top.vhd
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
--  Vivado 2013.2:
--    mkdir -p build.vivado
--    (cd build.vivado; vivado -mode tcl -source ../vivado.tcl)
--    (cd build.vivado; promgen -w -b -p bin -o cmv_io.bin -u 0 cmv_io.bit -data_width 32)
--
--  0xf8000900 rw	ps7::slcr::LVL_SHFTR_EN
--  devmem 0x600001FC 16 0x03AE ~ 42.0/43.0
--  devmem 0x600001FC 16 0x03A6 ~ 40.5/41.5
--  devmem 0x600001FC 16 0x0377 ~ 26.5/27.0
--			 0x0386 ~ 30.5/31.0
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

entity top is
    port (
	DDR_Addr : inout std_logic_vector(14 downto 0);
	DDR_BankAddr : inout std_logic_vector(2 downto 0);
	DDR_Clk : inout std_ulogic;
	DDR_Clk_n : inout std_ulogic;
	DDR_CAS_n : inout std_ulogic;
	DDR_RAS_n : inout std_ulogic;
	DDR_CKE : inout std_ulogic;
	DDR_CS_n : inout std_ulogic;
	DDR_DM : inout std_logic_vector(3 downto 0);
	DDR_DQ : inout std_logic_vector(31 downto 0);
	DDR_DQS_n : inout std_logic_vector(3 downto 0);
	DDR_DQS : inout std_logic_vector(3 downto 0);
	DDR_DRSTB : inout std_ulogic;
	DDR_ODT : inout std_ulogic;
	DDR_VR_n : inout std_ulogic;
	DDR_VR : inout std_ulogic;
	DDR_WEB : inout std_ulogic;
	--
	MIO : inout std_logic_vector(53 downto 0);
	--
	PS_CLK : inout std_ulogic;
	PS_PORB : inout std_ulogic;
	PS_SRSTB : inout std_ulogic;
	--
	clk_100 : in std_logic;				-- input clock to FPGA
	--
	i2c0_sda : inout std_ulogic;
	i2c0_scl : inout std_ulogic;
	--
	i2c1_sda : inout std_ulogic;
	i2c1_scl : inout std_ulogic;
	--
	spi_en : out std_ulogic;
	spi_clk : out std_ulogic;
	spi_in : out std_ulogic;
	spi_out : in std_ulogic;
	--
	cmv_clk : out std_ulogic;
	cmv_t_exp1 : out std_ulogic;
	cmv_t_exp2 : out std_ulogic;
	cmv_frame_req : out std_ulogic;
	--
	cmv_lvds_clk_p : out std_logic;
	cmv_lvds_clk_n : out std_logic;
	--
	cmv_lvds_outclk_p : in std_logic;
	cmv_lvds_outclk_n : in std_logic;
	--
	pmod_jcm : out std_logic_vector(3 downto 0);
	pmod_jca : out std_logic_vector(3 downto 0);
	--
	pmod_jdm : out std_logic_vector(3 downto 0);
	pmod_jda : out std_logic_vector(3 downto 0);
	--
	led : out std_logic_vector(7 downto 0)
    );

end entity top;


architecture RTL of top is

    --------------------------------------------------------------------
    -- PS7 Signals
    --------------------------------------------------------------------

    signal m_axi_aclk : std_logic;
    signal m_axi_aresetn : std_logic;

    signal m_axi_arid : std_logic_vector(11 downto 0);
    signal m_axi_araddr : std_logic_vector(31 downto 0);
    signal m_axi_arvalid : std_logic;
    signal m_axi_arready : std_logic;

    signal m_axi_rid : std_logic_vector(11 downto 0);
    signal m_axi_rdata : std_logic_vector(31 downto 0);
    signal m_axi_rresp : std_logic_vector(1 downto 0);
    signal m_axi_rvalid : std_logic;
    signal m_axi_rready : std_logic;

    signal m_axi_awid : std_logic_vector(11 downto 0);
    signal m_axi_awaddr : std_logic_vector(31 downto 0);
    signal m_axi_awvalid : std_logic;
    signal m_axi_awready : std_logic;

    signal m_axi_wdata : std_logic_vector(31 downto 0);
    signal m_axi_wstrb : std_logic_vector(3 downto 0);
    signal m_axi_wlast : std_logic;
    signal m_axi_wvalid : std_logic;
    signal m_axi_wready : std_logic;

    signal m_axi_bid : std_logic_vector(11 downto 0);
    signal m_axi_bresp : std_logic_vector(1 downto 0);
    signal m_axi_bvalid : std_logic;
    signal m_axi_bready : std_logic;

    --------------------------------------------------------------------
    -- CMV SPI Signals
    --------------------------------------------------------------------

    signal axi_state : std_logic_vector(3 downto 0);

    signal cmv_spi_clk : std_ulogic;

    --------------------------------------------------------------------
    -- I2C0 Signals
    --------------------------------------------------------------------

    signal i2c0_sda_i : std_ulogic;
    signal i2c0_sda_o : std_ulogic;
    signal i2c0_sda_t : std_ulogic;
    signal i2c0_sda_t_n : std_ulogic;

    signal i2c0_scl_i : std_ulogic;
    signal i2c0_scl_o : std_ulogic;
    signal i2c0_scl_t : std_ulogic;
    signal i2c0_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- I2C1 Signals
    --------------------------------------------------------------------

    signal i2c1_sda_i : std_ulogic;
    signal i2c1_sda_o : std_ulogic;
    signal i2c1_sda_t : std_ulogic;
    signal i2c1_sda_t_n : std_ulogic;

    signal i2c1_scl_i : std_ulogic;
    signal i2c1_scl_o : std_ulogic;
    signal i2c1_scl_t : std_ulogic;
    signal i2c1_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- CMV PLL Signals
    --------------------------------------------------------------------

    signal cmv_pll : std_logic_vector(5 downto 0);
    signal cmv_pll_locked : std_ulogic;

    signal cmv_clk_300 : std_ulogic;
    signal cmv_clk_150 : std_ulogic;
    signal cmv_clk_100 : std_ulogic;
    signal cmv_clk_60 : std_ulogic;
    signal cmv_clk_30 : std_ulogic;
    signal cmv_clk_10 : std_ulogic;

    signal cmv_outclk : std_ulogic;

    --------------------------------------------------------------------
    -- Debug Signals
    --------------------------------------------------------------------

    signal pmod_clk : std_ulogic;

    signal pmod_v0 : std_logic_vector(63 downto 0);
    signal pmod_v0_update : std_logic;

    signal pmod_v1 : std_logic_vector(63 downto 0);
    signal pmod_v1_update : std_logic;

begin
    --------------------------------------------------------------------
    -- PS7 Interface
    --------------------------------------------------------------------

    ps7_stub_inst : entity work.ps7_stub
	port map (
	    ddr_addr => DDR_Addr,
	    ddr_bankaddr => DDR_BankAddr,
	    ddr_cas_n => DDR_CAS_n,
	    ddr_cke => DDR_CKE,
	    ddr_clk => DDR_Clk,
	    ddr_clk_n => DDR_Clk_n,
	    ddr_cs_n => DDR_CS_n,
	    ddr_dm => DDR_DM,
	    ddr_dq => DDR_DQ,
	    ddr_dqs_n => DDR_DQS_n,
	    ddr_dqs => DDR_DQS,
	    ddr_drstb => DDR_DRSTB,
	    ddr_odt => DDR_ODT,
	    ddr_ras_n => DDR_RAS_n,
	    ddr_vr_n => DDR_VR_n,
	    ddr_vr => DDR_VR,
	    ddr_web => DDR_WEB,
	    --
	    ps_mio => MIO,
	    ps_clk => PS_CLK,
	    ps_porb => PS_PORB,
	    ps_srstb => PS_SRSTB,
	    --
	    i2c0_sda_i => i2c0_sda_i,
	    i2c0_sda_o => i2c0_sda_o,
	    i2c0_sda_t_n => i2c0_sda_t_n,
	    --
	    i2c0_scl_i => i2c0_scl_i,
	    i2c0_scl_o => i2c0_scl_o,
	    i2c0_scl_t_n => i2c0_scl_t_n,
	    --
	    i2c1_sda_i => i2c1_sda_i,
	    i2c1_sda_o => i2c1_sda_o,
	    i2c1_sda_t_n => i2c1_sda_t_n,
	    --
	    i2c1_scl_i => i2c1_scl_i,
	    i2c1_scl_o => i2c1_scl_o,
	    i2c1_scl_t_n => i2c1_scl_t_n,
	    --
	    m_axi_aclk => m_axi_aclk,
	    --
	    m_axi_aresetn => m_axi_aresetn,
	    --
	    m_axi_arid => m_axi_arid,
	    m_axi_araddr => m_axi_araddr,
	    m_axi_arvalid => m_axi_arvalid,
	    m_axi_arready => m_axi_arready,
	    --
	    m_axi_rid => m_axi_rid,
	    m_axi_rdata => m_axi_rdata,
	    m_axi_rresp => m_axi_rresp,
	    m_axi_rvalid => m_axi_rvalid,
	    m_axi_rready => m_axi_rready,
	    --
	    m_axi_awid => m_axi_awid,
	    m_axi_awaddr => m_axi_awaddr,
	    m_axi_awvalid => m_axi_awvalid,
	    m_axi_awready => m_axi_awready,
	    --
	    m_axi_wdata => m_axi_wdata,
	    m_axi_wstrb => m_axi_wstrb,
	    m_axi_wlast => m_axi_wlast,
	    m_axi_wvalid => m_axi_wvalid,
	    m_axi_wready => m_axi_wready,
	    --
	    m_axi_bid => m_axi_bid,
	    m_axi_bresp => m_axi_bresp,
	    m_axi_bvalid => m_axi_bvalid,
	    m_axi_bready => m_axi_bready );

    --------------------------------------------------------------------
    -- CMV PLL
    --------------------------------------------------------------------

    cmv_pll_inst : entity work.cmv_pll
	port map (
	    clk_in => clk_100,
	    --
	    pll_clk => cmv_pll,
	    --
	    pll_locked => cmv_pll_locked );

	    cmv_clk_300 <= cmv_pll(0);
	    cmv_clk_150 <= cmv_pll(1);
	    cmv_clk_100 <= cmv_pll(2);
	    cmv_clk_60 <= cmv_pll(3);
	    cmv_clk_30 <= cmv_pll(4);
	    cmv_clk_10 <= cmv_pll(5);

    --------------------------------------------------------------------
    -- CMV SPI Interface
    --------------------------------------------------------------------

    reg_spi_inst : entity work.reg_spi
	port map (
	    m_axi_aclk => m_axi_aclk,
	    m_axi_aresetn => m_axi_aresetn,
	    --
	    m_axi_arid => m_axi_arid,
	    m_axi_araddr => m_axi_araddr,
	    m_axi_arvalid => m_axi_arvalid,
	    m_axi_arready => m_axi_arready,
	    --
	    m_axi_rid => m_axi_rid,
	    m_axi_rdata => m_axi_rdata,
	    m_axi_rresp => m_axi_rresp,
	    m_axi_rvalid => m_axi_rvalid,
	    m_axi_rready => m_axi_rready,
	    --
	    m_axi_awid => m_axi_awid,
	    m_axi_awaddr => m_axi_awaddr,
	    m_axi_awvalid => m_axi_awvalid,
	    m_axi_awready => m_axi_awready,
	    --
	    m_axi_wdata => m_axi_wdata,
	    m_axi_wstrb => m_axi_wstrb,
	    m_axi_wlast => m_axi_wlast,
	    m_axi_wvalid => m_axi_wvalid,
	    m_axi_wready => m_axi_wready,
	    --
	    m_axi_bid => m_axi_bid,
	    m_axi_bresp => m_axi_bresp,
	    m_axi_bvalid => m_axi_bvalid,
	    m_axi_bready => m_axi_bready,
	    --
	    axi_state => axi_state,
	    --
	    spi_bclk => cmv_spi_clk,
	    --
	    spi_clk => spi_clk,
	    spi_in => spi_in,
	    spi_out => spi_out,
	    spi_en => spi_en );

    m_axi_aclk <= cmv_clk_100;

    cmv_spi_clk <= cmv_clk_10;

    --------------------------------------------------------------------
    -- I2C bus #0
    --------------------------------------------------------------------

    i2c0_sda_t <= not i2c0_sda_t_n;

    IOBUF_sda_inst0 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c0_sda_o, O => i2c0_sda_i,
	    T => i2c0_sda_t, IO => i2c0_sda );

    i2c0_scl_t <= not i2c0_scl_t_n;

    IOBUF_scl_inst0 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c0_scl_o, O => i2c0_scl_i,
	    T => i2c0_scl_t, IO => i2c0_scl );

    --------------------------------------------------------------------
    -- I2C bus #1
    --------------------------------------------------------------------

    i2c1_sda_t <= not i2c1_sda_t_n;

    IOBUF_sda_inst1 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c1_sda_o, O => i2c1_sda_i,
	    T => i2c1_sda_t, IO => i2c1_sda );

    i2c1_scl_t <= not i2c1_scl_t_n;

    IOBUF_scl_inst1 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c1_scl_o, O => i2c1_scl_i,
	    T => i2c1_scl_t, IO => i2c1_scl );

    --------------------------------------------------------------------
    -- CMV12K Related
    --------------------------------------------------------------------

    cmv_clk <= cmv_clk_30;

    cmv_frame_req <= '0';
    cmv_t_exp1 <= '0';
    cmv_t_exp2 <= '0';

    OBUFDS_inst : OBUFDS
	generic map (
	    IOSTANDARD => "LVDS_25",
	    SLEW => "SLOW" )
	port map (
	    O => cmv_lvds_clk_p,
	    OB => cmv_lvds_clk_n,
	    I => cmv_clk_300 );

    IBUFDS_inst : IBUFDS
	generic map (
	    DIFF_TERM => TRUE,
	    IBUF_LOW_PWR => TRUE,
	    IOSTANDARD => "LVDS_25" )
	port map (
	    O => cmv_outclk,
	    I => cmv_lvds_outclk_p,
	    IB => cmv_lvds_outclk_n );


    --------------------------------------------------------------------
    -- LED Status output
    --------------------------------------------------------------------

    led(0) <= cmv_pll_locked;
    led(7 downto 4) <= axi_state;
    led(3) <= '0';

    div_lvds_inst0 : entity work.divider
	generic map (
	    RATIO => 300_000_000 )
	port map (
	    clk_in => cmv_clk_300,
	    enable => '1',
	    clk_out => led(1) );

    div_lvds_inst1 : entity work.divider
	generic map (
	    RATIO => 300_000_000 )
	port map (
	    clk_in => cmv_outclk,
	    enable => '1',
	    clk_out => led(2) );

    --------------------------------------------------------------------
    -- PMOD Debug
    --------------------------------------------------------------------

    div_pmod_inst : entity work.divider
	generic map (
	    RATIO => 1024*4 )
	port map (
	    clk_in => clk_100,
	    enable => '1',
	    clk_out => pmod_clk );

    pmod_dbg_inst0 : entity work.pmod_debug
	port map (
	    clk => pmod_clk,
	    --
	    value => pmod_v0,
	    update => pmod_v0_update,
	    --
	    jxm => pmod_jcm,
	    jxa => pmod_jca );

    pmod_dbg_inst1 : entity work.pmod_debug
	port map (
	    clk => pmod_clk,
	    --
	    value => pmod_v1,
	    update => pmod_v1_update,
	    --
	    jxm => pmod_jdm,
	    jxa => pmod_jda );

    pmod_v0(63 downto 48) <= m_axi_awaddr(15 downto 0);
    pmod_v0(47 downto 32) <= m_axi_awvalid & m_axi_awready & m_axi_wvalid & m_axi_wready & m_axi_awid;
    pmod_v0(31 downto 16) <= m_axi_wdata(15 downto 0);
    pmod_v0(15 downto 0) <= m_axi_bvalid & m_axi_bready & m_axi_bresp & m_axi_bid;
    pmod_v0_update <= pmod_clk;

    pmod_v1(63 downto 48) <= m_axi_araddr(15 downto 0);
    pmod_v1(47 downto 32) <= m_axi_arvalid & m_axi_arready & "00" & m_axi_arid;
    pmod_v1(31 downto 16) <= m_axi_rdata(15 downto 0);
    pmod_v1(15 downto 0) <= m_axi_rvalid & m_axi_rready & m_axi_rresp & m_axi_rid;
    pmod_v1_update <= pmod_clk;

end RTL;
