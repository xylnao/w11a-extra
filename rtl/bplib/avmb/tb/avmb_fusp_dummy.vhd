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
-- Module Name:    avmb_dummy - syn
-- Description:    avmb minimal target (base; serport loopback)
--
-- Dependencies:   -
-- To test:        tb_avmb
-- Target Devices: generic
-- Tool versions:  xst 13.4; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-02-24   ??? Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

entity avmb_fusp_dummy is               -- AvnetMB dummy (base+fusp; loopback)
                                        -- implements avmb_fusp_aif
  port (
    I_CLK40 : in slbit;                 -- 40 MHz board clock
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
end avmb_fusp_dummy;

architecture syn of avmb_fusp_dummy is
  
begin

  O_TXD    <= I_RXD;                    -- loop back
  O_FUSP_TXD   <= I_FUSP_RXD;
  O_FUSP_RTS_N <= I_FUSP_CTS_N;

end syn;
