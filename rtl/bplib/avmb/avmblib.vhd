-- $Id$
--
------------------------------------------------------------------------------
-- Package Name:   avmblib
-- Description:    Avnet MicroBoard components
-- 
-- Dependencies:   -
-- Tool versions:  xst 13.4; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-02-24   ???   1.0      Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package avmblib is

component avmb_aif is                 -- Avnet MicroBoard, abstract iface, base
  port (
    I_CLK40 : in slbit;                 -- 40 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- avmb switches
    I_BTN : in slv1;                    -- avmb button
    O_LED : out slv4                    -- avmb leds
  );
end component;

component avmb_fusp_aif is           -- Avnet MicroBoard, abstract iface, base+fusp
  port (
    I_CLK40 : in slbit;                 -- 40 MHz clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv4;                    -- avmb switches
    I_BTN : in slv1;                    -- avmb button
    O_LED : out slv4;                   -- avmb leds
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end component;

end package avmblib;
