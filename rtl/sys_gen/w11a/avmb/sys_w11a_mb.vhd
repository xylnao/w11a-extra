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
-- Module Name:    sys_w11a_mb - syn
-- Description:    w11a test design for avmb
--
-- Dependencies:   vlib/xlib/dcm_sfs
--                 vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2l4l_iob
--                 bplib/bpgen/sn_humanio_rbus
--                 vlib/rlink/rlink_sp1c
--                 vlib/rri/rb_sres_or_3
--                 w11a/pdp11_core_rbus
--                 w11a/pdp11_core
--                 w11a/pdp11_bram
--                 w11a/pdp11_cache
--                 w11a/pdp11_mem70
--                 ibus/ib_sres_or_2
--                 ibus/ibdr_minisys
--                 ibus/ibdr_maxisys
--                 w11a/pdp11_tmu_sb           [sim only]
--
-- Test bench:     tb/tb_sys_w11a_mb
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
--
-- w11a test design for avmb
--    w11a + rlink + serport
--
-- Usage of Avnet MicroBoard Switches, Buttons, LEDs:
--
--    SWI(3:2): no function (only connected to mb_humanio_rbus)
--    SWI(1):   1 enable XON
--    SWI(0):   0 -> main board RS232 port
--              1 -> Pmod 2/top RS232 port
--    
--    LED(3)    MEM_ACT_W or MEM_ACT_R
--       (2)    cmdbusy (all rlink access, mostly rdma)
--       (1)    cpugo
--       (0)    user mode

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.serport.all;
use work.rblib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_mb is                   -- top level
                                        -- implements avmb_fusp_aif
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
end sys_w11a_mb;

architecture syn of sys_w11a_mb is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal SWI     : slv4  := (others=>'0');
  signal BTN     : slv1  := (others=>'0');
  signal LED     : slv4  := (others=>'0');  

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv3  := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal RB_MREQ     : rb_mreq_type := rb_mreq_init;
  signal RB_SRES     : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU : rb_sres_type := rb_sres_init;
  signal RB_SRES_IBD : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO : rb_sres_type := rb_sres_init;

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CPU_RESET : slbit := '0';
  signal CP_CNTL : cp_cntl_type := cp_cntl_init;
  signal CP_ADDR : cp_addr_type := cp_addr_init;
  signal CP_DIN  : slv16 := (others=>'0');
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal CP_DOUT : slv16 := (others=>'0');

  signal EI_PRI  : slv3   := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit  := '0';
  
  signal EM_MREQ : em_mreq_type := em_mreq_init;
  signal EM_SRES : em_sres_type := em_sres_init;
  
  signal HM_ENA      : slbit := '0';
  signal MEM70_FMISS : slbit := '0';
  signal CACHE_FMISS : slbit := '0';
  signal CACHE_CHIT  : slbit := '0';

  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv20 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  signal MEM_ADDR_EXT : slv22 := (others=>'0');

  signal BRESET  : slbit := '0';
  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES : ib_sres_type := ib_sres_init;

  signal IB_SRES_MEM70 : ib_sres_type := ib_sres_init;
  signal IB_SRES_IBDR  : ib_sres_type := ib_sres_init;

  signal DM_STAT_DP : dm_stat_dp_type := dm_stat_dp_init;
  signal DM_STAT_VM : dm_stat_vm_type := dm_stat_vm_init;
  signal DM_STAT_CO : dm_stat_co_type := dm_stat_co_init;
  signal DM_STAT_SY : dm_stat_sy_type := dm_stat_sy_init;

  signal DISPREG : slv16 := (others=>'0');

  constant rbaddr_core0 : slv8 := "00000000";
  constant rbaddr_ibus  : slv8 := "10000000";
  constant rbaddr_hio   : slv8 := "11000000";

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
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
      SWI => SWI,
      BTN => BTN,
      LED => LED,
      DSP_DAT => (others => '0'),
      DSP_DP  => (others => '0'),
      I_SWI => I_SWI,
      I_BTN => I_BTN,
      O_LED => O_LED,
      O_ANO_N => open,
      O_SEG_N => open
    );

  RLINK : rlink_sp1c
    generic map (
      ATOWIDTH     => 7,                -- 128 cycles access timeout
      ITOWIDTH     => 6,                --  64 periods max idle timeout
      CPREF        => c_rlink_cpref,
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 13,
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

  RB_SRES_OR : rb_sres_or_3
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_IBD,
      RB_SRES_3  => RB_SRES_HIO,
      RB_SRES_OR => RB_SRES
    );
  
  RB2CP : pdp11_core_rbus
    generic map (
      RB_ADDR_CORE => rbaddr_core0,
      RB_ADDR_IBUS => rbaddr_ibus)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_CPU,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM(0),
      CPU_RESET => CPU_RESET,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT,
      CP_DOUT   => CP_DOUT      
    );

  CORE : pdp11_core
    port map (
      CLK       => CLK,
      RESET     => CPU_RESET,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT,
      CP_DOUT   => CP_DOUT,
      EI_PRI    => EI_PRI,
      EI_VECT   => EI_VECT,
      EI_ACKM   => EI_ACKM,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      BRESET    => BRESET,
      IB_MREQ_M => IB_MREQ,
      IB_SRES_M => IB_SRES,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO
    );  

  MEM_BRAM: if true generate
    signal HM_VAL_BRAM : slbit := '0';
  begin
    
    MEM : pdp11_bram
      generic map (
        AWIDTH => sys_conf_bram_awidth)
      port map (
        CLK     => CLK,
        GRESET  => CPU_RESET,
        EM_MREQ => EM_MREQ,
        EM_SRES => EM_SRES
      );

    HM_VAL_BRAM <= not EM_MREQ.we;        -- assume hit if read, miss if write
      
    MEM70: pdp11_mem70
      port map (
        CLK         => CLK,
        CRESET      => BRESET,
        HM_ENA      => EM_MREQ.req,
        HM_VAL      => HM_VAL_BRAM,
        CACHE_FMISS => MEM70_FMISS,
        IB_MREQ     => IB_MREQ,
        IB_SRES     => IB_SRES_MEM70
      );

  end generate MEM_BRAM;

  IB_SRES_OR : ib_sres_or_2
    port map (
      IB_SRES_1  => IB_SRES_MEM70,
      IB_SRES_2  => IB_SRES_IBDR,
      IB_SRES_OR => IB_SRES
    );

  IBD_MINI : if false generate
  begin
    IBDR_SYS : ibdr_minisys
      port map (
        CLK      => CLK,
        CE_USEC  => CE_USEC,
        CE_MSEC  => CE_MSEC,
        RESET    => CPU_RESET,
        BRESET   => BRESET,
        RB_LAM   => RB_LAM(15 downto 1),
        IB_MREQ  => IB_MREQ,
        IB_SRES  => IB_SRES_IBDR,
        EI_ACKM  => EI_ACKM,
        EI_PRI   => EI_PRI,
        EI_VECT  => EI_VECT,
        DISPREG  => DISPREG
      );
  end generate IBD_MINI;
  
  IBD_MAXI : if true generate
  begin
    IBDR_SYS : ibdr_maxisys
      port map (
        CLK      => CLK,
        CE_USEC  => CE_USEC,
        CE_MSEC  => CE_MSEC,
        RESET    => CPU_RESET,
        BRESET   => BRESET,
        RB_LAM   => RB_LAM(15 downto 1),
        IB_MREQ  => IB_MREQ,
        IB_SRES  => IB_SRES_IBDR,
        EI_ACKM  => EI_ACKM,
        EI_PRI   => EI_PRI,
        EI_VECT  => EI_VECT,
        DISPREG  => DISPREG
      );
  end generate IBD_MAXI;
    
  proc_led: process (MEM_ACT_W, MEM_ACT_R, CP_STAT, DM_STAT_DP.psw)
    variable iled : slv4 := (others=>'0');
  begin
    iled := (others=>'0');
    iled(3) := MEM_ACT_W or MEM_ACT_R;
    iled(2) := CP_STAT.cmdbusy;
    iled(1) := CP_STAT.cpugo;
    if CP_STAT.cpugo = '1' then
      case DM_STAT_DP.psw.cmode is
        when c_psw_umode =>
          iled(0) := '1';
        when others => null;
      end case;
    else
      null;
    end if;
    LED <= iled;
  end process;
      
-- synthesis translate_off
  DM_STAT_SY.emmreq <= EM_MREQ;
  DM_STAT_SY.emsres <= EM_SRES;
  DM_STAT_SY.chit   <= CACHE_CHIT;
  
  TMU : pdp11_tmu_sb
    generic map (
      ENAPIN => 13)
    port map (
      CLK        => CLK,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_SY => DM_STAT_SY
    );
-- synthesis translate_on
  
end syn;
