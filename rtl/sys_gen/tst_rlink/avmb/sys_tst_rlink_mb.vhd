-- $Id$
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_rlink_mb - syn
-- Description:    rlink tester design for avmb
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2l4l_iob
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rlink/rlink_sp1c
--                 rbd_tst_rlink
--                 vlib/rbus/rb_sres_or_2
--
-- Test bench:     tb/tb_tst_rlink_mb
--
-- Target Devices: generic
-- Tool versions:  xst 13.4; ghdl 0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-02-24   ???   1.0    Initial version
------------------------------------------------------------------------------
-- Usage of Avnet Spartan-6 MicroBoard Switches, Buttons, LEDs:
--
--    SWI(3:2): no function (only connected to sn_humanio_rbus)
--    SWI(1):   1 enable XON
--    SWI(0):   0 -> main board RS232 port  - implemented in bp_rs232_2l4l_iob
--              1 -> Pmod 2/top RS232 port  /
--
--    LED(3:2): no function (only connected to sn_humanio_rbus)
--    LED(0):   timer 0 busy 
--    LED(1):   timer 1 busy 
--

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.serport.all;
use work.rblib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_rlink_mb is              -- top level
                                        -- implements avmb_fusp_aif
  port (
    I_CLK40 : in slbit;                 -- 100 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- mb switches
    I_BTN : in slv1;                    -- mb button
    O_LED : out slv4;                   -- mb leds
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_tst_rlink_mb;

architecture syn of sys_tst_rlink_mb is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal SWI     : slv4  := (others=>'0');
  signal BTN     : slv1  := (others=>'0');
  signal LED     : slv4  := (others=>'0');

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO : rb_sres_type := rb_sres_init;
  signal RB_SRES_TST : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv3  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;
  signal STAT    : slv8  := (others=>'0');

  constant rbaddr_hio   : slv8 := "11000000"; -- 110000xx

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;

  RESET <= '0';                         -- so far not used
  
  DCM : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => sys_conf_clkfx_divide,
      CLKFX_MULTIPLY => sys_conf_clkfx_multiply,
      CLKIN_PERIOD   => 10.0)
    port map (
      CLKIN   => I_CLK40,
      CLKFX   => CLK,
      LOCKED  => open
    );

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 7,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2l4l_iob
    port map (
      CLK      => CLK,
      RESET    => '0',
      SEL      => SWI(0),
      RXD      => RXD,
      TXD      => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      I_RXD0   => I_RXD,
      O_TXD0   => O_TXD,
      I_RXD1   => I_FUSP_RXD,
      O_TXD1   => O_FUSP_TXD,
      I_CTS1_N => I_FUSP_CTS_N,
      O_RTS1_N => O_FUSP_RTS_N
    );

  HIO : sn_humanio_rbus
    generic map (
      SWIDTH   => 4,
      BWIDTH   => 1,
      LWIDTH   => 4,
      DEBOUNCE => sys_conf_hio_debounce,
      RB_ADDR  => rbaddr_hio)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_HIO,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      DSP_DAT => (others=>'0'),
      DSP_DP  => (others=>'0'),
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED
    );

  RLINK : rlink_sp1c
    generic map (
      ATOWIDTH     => 6,
      ITOWIDTH     => 6,
      CPREF        => c_rlink_cpref,
      IFAWIDTH     => 5,
      OFAWIDTH     => 5,
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 15,
      CDINIT       => sys_conf_ser2rri_cdinit)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      ENAXON   => SWI(1),
      ENAESC   => SWI(1),
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      SER_MONI => SER_MONI
    );

  RBDTST : entity work.rbd_tst_rlink
    port map (
      CLK         => CLK,
      RESET       => RESET,
      CE_USEC     => CE_USEC,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TST,
      RB_LAM      => RB_LAM,
      RB_STAT     => RB_STAT,
      RB_SRES_TOP => RB_SRES,
      RXSD        => RXD,
      RXACT       => SER_MONI.rxact,
      STAT        => STAT
    );

  RB_SRES_OR1 : rb_sres_or_2
    port map (
      RB_SRES_1  => RB_SRES_HIO,
      RB_SRES_2  => RB_SRES_TST,
      RB_SRES_OR => RB_SRES
    );

  LED(3 downto 2) <= (others=>'0');
  LED(1) <= STAT(1);
  LED(0) <= STAT(0);
   
end syn;
