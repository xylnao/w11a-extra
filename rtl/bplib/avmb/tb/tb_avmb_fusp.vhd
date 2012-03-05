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
-- Module Name:    tb_avmb_fusp - sim
-- Description:    Test bench for avmb (base+fusp)
--
-- Dependencies:   vlib/rlink/tb/tbcore_rlink_dcm
--                 vlib/xlib/dcm_sfs
--                 tb_avmb_core
--                 vlib/serport/serport_uart_rxtx
--                 avmb_fusp_aif [UUT]
--
-- To test:        generic, any avmb_fusp_aif target
--
-- Target Devices: generic
-- Tool versions:  xst 13.4; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-02-24   ???   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.rlinklib.all;
use work.rlinktblib.all;
use work.serport.all;
use work.xlib.all;
use work.avmblib.all;
use work.simlib.all;
use work.simbus.all;
use work.sys_conf.all;

entity tb_avmb_fusp is
end tb_avmb_fusp;

architecture sim of tb_avmb_fusp is
  
  signal CLKOSC : slbit := '0';
  signal CLKSYS : slbit := '0';

  signal RESET : slbit := '0';
  signal CLKDIV : slv2 := "00";         -- run with 1 clocks / bit !!
  signal RXDATA : slv8 := (others=>'0');
  signal RXVAL : slbit := '0';
  signal RXERR : slbit := '0';
  signal RXACT : slbit := '0';
  signal TXDATA : slv8 := (others=>'0');
  signal TXENA : slbit := '0';
  signal TXBUSY : slbit := '0';

  signal RX_HOLD : slbit := '0';

  signal I_RXD : slbit := '1';
  signal O_TXD : slbit := '1';
  signal I_SWI : slv4 := (others=>'0');
  signal I_BTN : slv1 := (others=>'0');
  signal O_LED : slv4 := (others=>'0');

  signal O_FUSP_RTS_N : slbit := '0';
  signal I_FUSP_CTS_N : slbit := '0';
  signal I_FUSP_RXD : slbit := '1';
  signal O_FUSP_TXD : slbit := '1';

  signal UART_RESET : slbit := '0';
  signal UART_RXD : slbit := '1';
  signal UART_TXD : slbit := '1';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal R_PORTSEL : slbit := '0';

  constant sbaddr_portsel: slv8 := slv(to_unsigned( 8,8));

  constant clockosc_period : time :=  10 ns;
  constant clockosc_offset : time := 200 ns;
  constant setup_time : time :=  5 ns;
  constant c2out_time : time :=  9 ns;

begin
  
  TBCORE : tbcore_rlink_dcm
    generic map (
      CLKOSC_PERIOD => clockosc_period,
      CLKOSC_OFFSET => clockosc_offset,
      SETUP_TIME => setup_time,
      C2OUT_TIME => c2out_time)
    port map (
      CLKOSC  => CLKOSC,
      CLKSYS  => CLKSYS,
      RX_DATA => TXDATA,
      RX_VAL  => TXENA,
      RX_HOLD => RX_HOLD,
      TX_DATA => RXDATA,
      TX_ENA  => RXVAL
    );

  DCM_SYS : dcm_sfs
    generic map (
      CLKFX_DIVIDE   => sys_conf_clkfx_divide,
      CLKFX_MULTIPLY => sys_conf_clkfx_multiply,
      CLKIN_PERIOD   => 10.0)
    port map (
      CLKIN   => CLKOSC,
      CLKFX   => CLKSYS,
      LOCKED  => open
    );

  RX_HOLD <= TXBUSY or RTS_N;           -- back preasure for data flow to tb

  MBCORE : entity work.tb_avmb_core
    port map (
      I_SWI       => I_SWI,
      I_BTN       => I_BTN
    );

  UUT : avmb_fusp_aif
    port map (
      I_CLK40      => CLKOSC,
      I_RXD        => I_RXD,
      O_TXD        => O_TXD,
      I_SWI        => I_SWI,
      I_BTN        => I_BTN,
      O_LED        => O_LED,
      O_FUSP_RTS_N => O_FUSP_RTS_N,
      I_FUSP_CTS_N => I_FUSP_CTS_N,
      I_FUSP_RXD   => I_FUSP_RXD,
      O_FUSP_TXD   => O_FUSP_TXD
    );

  UART : serport_uart_rxtx
    generic map (
      CDWIDTH => CLKDIV'length)
    port map (
      CLK    => CLKSYS,
      RESET  => UART_RESET,
      CLKDIV => CLKDIV,
      RXSD   => UART_RXD,
      RXDATA => RXDATA,
      RXVAL  => RXVAL,
      RXERR  => RXERR,
      RXACT  => RXACT,
      TXSD   => UART_TXD,
      TXDATA => TXDATA,
      TXENA  => TXENA,
      TXBUSY => TXBUSY
    );

  proc_port_mux: process (R_PORTSEL, UART_TXD, CTS_N,
                          O_TXD, O_FUSP_TXD, O_FUSP_RTS_N)
  begin

    if R_PORTSEL = '0' then             -- use main board rs232, no flow cntl
      I_RXD        <= UART_TXD;           -- write port 0 inputs
      UART_RXD     <= O_TXD;              -- get port 0 outputs
      RTS_N        <= '0';
      I_FUSP_RXD   <= '1';                -- port 1 inputs to idle state
      I_FUSP_CTS_N <= '0';
    else                                -- otherwise use pmod 2 rs232
      I_FUSP_RXD   <= UART_TXD;           -- write port 1 inputs
      I_FUSP_CTS_N <= CTS_N;
      UART_RXD     <= O_FUSP_TXD;         -- get port 1 outputs
      RTS_N        <= O_FUSP_RTS_N;
      I_RXD        <= '1';                -- port 0 inputs to idle state
    end if;
    
  end process proc_port_mux;

  proc_moni: process
    variable oline : line;
  begin
    
    loop
      wait until rising_edge(CLKSYS);
      wait for c2out_time;

      if RXERR = '1' then
        writetimestamp(oline, SB_CLKCYCLE, " : seen RXERR=1");
        writeline(output, oline);
      end if;
      
    end loop;
    
  end process proc_moni;

  proc_simbus: process (SB_VAL)
  begin
    if SB_VAL'event and to_x01(SB_VAL)='1' then
      if SB_ADDR = sbaddr_portsel then
        R_PORTSEL <= to_x01(SB_DATA(0));
      end if;
    end if;
  end process proc_simbus;

end sim;
