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
-- Module Name:    tb_w11a_mb
-- Description:    Configuration for tb_w11a_mb for tb_avmb_fusp
--
-- Dependencies:   sys_w11a_mb
--
-- To test:        sys_w11a_mb
--
-- XXXVerified (with (#1) ../../tb/tb_rritba_pdp11core_stim.dat
--                (#2) ../../tb/tb_pdp11_core_stim.dat):
-- Date         Rev  Code  ghdl  ise          Target     Comment
-- 
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-02-24   ???   1.0    Initial version
------------------------------------------------------------------------------

configuration tb_w11a_mb of tb_avmb_fusp is

  for sim
    for all : avmb_fusp_aif
      use entity work.sys_w11a_mb;
    end for;
  end for;

end tb_w11a_mb;
