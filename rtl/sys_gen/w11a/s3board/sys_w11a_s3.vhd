-- $Id: sys_w11a_s3.vhd 442 2011-12-23 10:03:28Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    sys_w11a_s3 - syn
-- Description:    w11a test design for s3board
--
-- Dependencies:   vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2l4l_iob
--                 bplib/bpgen/sn_humanio
--                 vlib/rlink/rlink_sp1c
--                 vlib/rbus/rb_sres_or_2
--                 w11a/pdp11_core_rbus
--                 w11a/pdp11_core
--                 w11a/pdp11_bram
--                 vlib/s3board/s3_sram_dummy
--                 w11a/pdp11_cache
--                 w11a/pdp11_mem70
--                 bplib/s3board/s3_sram_memctl
--                 ibus/ib_sres_or_2
--                 ibus/ibdr_minisys
--                 ibus/ibdr_maxisys
--                 w11a/pdp11_tmu_sb           [sim only]
--
-- Test bench:     tb/tb_sys_w11a_s3
--
-- Target Devices: generic
-- Tool versions:  xst 8.2, 9.1, 9.2, 10.1, 11.4, 12.1, 13.1; ghdl 0.18-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2011-12-21   442 13.1    O40d xc3s1000-4  1301 4307  270 2613 OK: LP+PC+DL+II
-- 2011-11-19   427 13.1    O40d xc3s1000-4  1322 4298  242 2616 OK: LP+PC+DL+II
-- 2010-12-30   351 12.1    M53d xc3s1000-4  1316 4291  242 2609 OK: LP+PC+DL+II
-- 2010-11-06   336 12.1    M53d xc3s1000-4  1284 4253* 242 2575 OK: LP+PC+DL+II
-- 2010-10-24   335 12.1    M53d xc3s1000-4  1284 4495  242 2575 OK: LP+PC+DL+II
-- 2010-05-01   285 11.4    L68  xc3s1000-4  1239 4086  224 2471 OK: LP+PC+DL+II
-- 2010-04-26   283 11.4    L68  xc3s1000-4  1245 4083  224 2474 OK: LP+PC+DL+II
-- 2009-07-12   233 11.2    L46  xc3s1000-4  1245 4078  224 2472 OK: LP+PC+DL+II
-- 2009-07-12   233 10.1.03 K39  xc3s1000-4  1250 4097  224 2494 OK: LP+PC+DL+II
-- 2009-06-01   221 10.1.03 K39  xc3s1000-4  1209 3986  224 2425 OK: LP+PC+DL+II
-- 2009-05-17   216 10.1.03 K39  xc3s1000-4  1039 3542  224 2116 m+p; TIME OK
-- 2009-05-09   213 10.1.03 K39  xc3s1000-4  1037 3500  224 2100 m+p; TIME OK
-- 2009-04-26   209  8.2.03 I34  xc3s1000-4  1099 3557  224 2264 m+p; TIME OK
-- 2008-12-13   176  8.2.03 I34  xc3s1000-4  1116 3672  224 2280 m+p; TIME OK
-- 2008-12-06   174 10.1.02 K37  xc3s1000-4  1038 3503  224 2100 m+p; TIME OK
-- 2008-12-06   174  8.2.03 I34  xc3s1000-4  1116 3682  224 2281 m+p; TIME OK
-- 2008-08-22   161  8.2.03 I34  xc3s1000-4  1118 3677  224 2288 m+p; TIME OK
-- 2008-08-22   161 10.1.02 K37  xc3s1000-4  1035 3488  224 2086 m+p; TIME OK
-- 2008-05-01   140  8.2.03 I34  xc3s1000-4  1057 3344  224 2119 m+p; 21ns;BR-32
-- 2008-05-01   140  8.2.03 I34  xc3s1000-4  1057 3357  224 2128 m+p; 21ns;BR-16
-- 2008-05-01   140  8.2.03 I34  xc3s1000-4  1057 3509  224 2220 m+p; TIME OK
-- 2008-05-01   140  9.2.04 J40  xc3s200-4   1009 3195  224 1918 m+p; T-OK;BR-16
-- 2008-03-19   127  8.2.03 I34  xc3s1000-4  1077 3471  224 2207 m+p; TIME OK
-- 2008-03-02   122  8.2.03 I34  xc3s1000-4  1068 3448  224 2179 m+p; TIME OK
-- 2008-03-02   121  8.2.03 I34  xc3s1000-4  1064 3418  224 2148 m+p; TIME FAIL
-- 2008-02-24   119  8.2.03 I34  xc3s1000-4  1071 3372  224 2141 m+p; TIME OK
-- 2008-02-23   118  8.2.03 I34  xc3s1000-4  1035 3301  182 1996 m+p; TIME OK
-- 2008-01-06   111  8.2.03 I34  xc3s1000-4   971 2898  182 1831 m+p; TIME OK
-- 2007-12-30   107  8.2.03 I34  xc3s1000-4   891 2719  137 1515 s 18.8
-- 2007-12-30   107  8.2.03 I34  xc3s1000-4   891 2661  137 1654 m+p; TIME OK
--   Note: till 2010-10-24 lutm included 'route-thru', after only logic
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-21   442   1.4.4  use rlink_sp1c; hio led usage now a for n2/n3
-- 2011-11-19   427   1.4.3  now numeric_std clean
-- 2011-07-09   391   1.4.2  use now bp_rs232_2l4l_iob
-- 2011-07-08   390   1.4.1  use now sn_humanio
-- 2010-12-30   351   1.4    ported to rbv3
-- 2010-11-06   336   1.3.7  rename input pin CLK -> I_CLK50
-- 2010-10-23   335   1.3.3  rename RRI_LAM->RB_LAM;
-- 2010-06-26   309   1.3.2  use constants for rbus addresses (rbaddr_...)
-- 2010-06-18   306   1.3.1  rename RB_ADDR->RB_ADDR_CORE, add RB_ADDR_IBUS;
--                           remove pdp11_ibdr_rri
-- 2010-06-13   305   1.6.1  add CP_ADDR, wire up pdp11_core_rri->pdp11_core
-- 2010-06-11   303   1.6    use IB_MREQ.racc instead of RRI_REQ
-- 2010-06-03   300   1.5.6  use default FAWIDTH for rri_core_serport
-- 2010-05-28   295   1.5.5  rename sys_pdp11core -> sys_w11a_s3
-- 2010-05-21   292   1.5.4  rename _PM1_ -> _FUSP_
-- 2010-05-16   291   1.5.3  rename memctl_s3sram->s3_sram_memctl
-- 2010-05-05   288   1.5.2  add sys_conf_hio_debounce
-- 2010-05-02   287   1.5.1  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT from interfaces; drop RTSFLUSH generic
--                           add pm1 rs232 (usp) support
-- 2010-05-01   285   1.5    port to rri V2 interface, use rri_core_serport
-- 2010-04-17   278   1.4.5  rename sram_dummy -> s3_sram_dummy
-- 2010-04-10   275   1.4.4  use s3_humanio; invert DP(1,3)
-- 2009-07-12   233   1.4.3  adapt to ibdr_(mini|maxi)sys interface changes
-- 2009-06-01   221   1.4.2  support ibdr_maxisys as well as _minisys
-- 2009-05-10   214   1.4.1  use pdp11_tmu_sb instead of pdp11_tmu
-- 2008-08-22   161   1.4.0  use iblib, ibdlib; renames
-- 2008-05-03   143   1.3.6  rename _cpursta->_cpurust
-- 2008-05-01   142   1.3.5  reassign LED(cpugo,halt,rust) and DISP(dispreg)
-- 2008-04-19   137   1.3.4  add DM_STAT_(DP|VM|CO|SY) signals, add pdp11_tmu
-- 2008-04-18   136   1.3.3  add RESET for ibdr_minisys
-- 2008-04-13   135   1.3.2  add _mem70 also for _bram configs
-- 2008-02-23   118   1.3.1  add _mem70
-- 2008-02-17   117   1.3    use ext. memory interface of _core; 
--                           use _cache + memctl or _bram (configurable)
-- 2008-01-20   113   1.2.1  finalize AP_LAM handling (0=cpu,1=dl11;4=rk05)
-- 2008-01-20   112   1.2    rename clkgen->clkdivce; use ibdr_minisys, BRESET
--                           add _ib_mux2
-- 2008-01-06   111   1.1    use now iob_reg_*; remove rricp_pdp11core hack
--                           instanciate all parts directly
-- 2007-12-23   105   1.0.4  add rritb_cpmon_sb
-- 2007-12-16   101   1.0.3  use _N for active low; set IOB attribute to RI/RO
-- 2007-12-09   100   1.0.2  add sram memory signals, dummy handle them
-- 2007-10-19    90   1.0.1  init RI_RXD,RO_TXD=1 to avoid startup glitch
-- 2007-09-23    84   1.0    Initial version
------------------------------------------------------------------------------
--
-- w11a test design for s3board
--    w11a + rlink + serport
--
-- Usage of S3BOARD Switches, Buttons, LEDs:
--
--    SWI(7:2): no function (only connected to sn_humanio_rbus)
--    SWI(1):   1 enable XON
--    SWI(0):   0 -> main board RS232 port
--              1 -> Pmod B/top RS232 port
--    
--    LED(7)    MEM_ACT_W
--       (6)    MEM_ACT_R
--       (5)    cmdbusy (all rlink access, mostly rdma)
--       (4:0): if cpugo=1 show cpu mode activity
--                  (4) kernel mode, pri>0
--                  (3) kernel mode, pri=0
--                  (2) kernel mode, wait
--                  (1) supervisor mode
--                  (0) user mode
--              if cpugo=0 shows cpurust
--                (3:0) cpurust code
--                  (4) '1'
--
--    DP(3):    not SER_MONI.txok       (shows tx back preasure)
--    DP(2):    SER_MONI.txact          (shows tx activity)
--    DP(1):    not SER_MONI.rxok       (shows rx back preasure)
--    DP(0):    SER_MONI.rxact          (shows rx activity)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.serport.all;
use work.rblib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.s3boardlib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_s3 is                   -- top level
                                        -- implements s3board_fusp_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32;          -- sram: data lines
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_w11a_s3;

architecture syn of sys_w11a_s3 is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv3  := (others=>'0');

  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal RB_MREQ     : rb_mreq_type := rb_mreq_init;
  signal RB_SRES     : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU : rb_sres_type := rb_sres_init;
  signal RB_SRES_IBD : rb_sres_type := rb_sres_init;

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

  CLK <= I_CLK50;                       -- use 50MHz as system clock

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => 50,
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

  HIO : sn_humanio
    generic map (
      DEBOUNCE => sys_conf_hio_debounce)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      SWI     => SWI,                   
      BTN     => BTN,                   
      LED     => LED,                   
      DSP_DAT => DSP_DAT,               
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI,                 
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  RLINK : rlink_sp1c
    generic map (
      ATOWIDTH     => 6,                --  64 cycles access timeout
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
   
  RB_SRES_OR : rb_sres_or_2
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_IBD,
      RB_SRES_OR => RB_SRES
    );
  
  RP2CP : pdp11_core_rbus
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

  MEM_BRAM: if sys_conf_bram > 0 generate
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

    SRAM_PROT : s3_sram_dummy             -- connect SRAM to protection dummy
      port map (
        O_MEM_CE_N  => O_MEM_CE_N,
        O_MEM_BE_N  => O_MEM_BE_N,
        O_MEM_WE_N  => O_MEM_WE_N,
        O_MEM_OE_N  => O_MEM_OE_N,
        O_MEM_ADDR  => O_MEM_ADDR,
        IO_MEM_DATA => IO_MEM_DATA
      );  

  end generate MEM_BRAM;

  MEM_SRAM: if sys_conf_bram = 0 generate
    
    CACHE: pdp11_cache
      port map (
        CLK       => CLK,
        GRESET    => CPU_RESET,
        EM_MREQ   => EM_MREQ,
        EM_SRES   => EM_SRES,
        FMISS     => CACHE_FMISS,
        CHIT      => CACHE_CHIT,
        MEM_REQ   => MEM_REQ,
        MEM_WE    => MEM_WE,
        MEM_BUSY  => MEM_BUSY,
        MEM_ACK_R => MEM_ACK_R,
        MEM_ADDR  => MEM_ADDR,
        MEM_BE    => MEM_BE,
        MEM_DI    => MEM_DI,
        MEM_DO    => MEM_DO
      );

    MEM70: pdp11_mem70
      port map (
        CLK         => CLK,
        CRESET      => BRESET,
        HM_ENA      => HM_ENA,
        HM_VAL      => CACHE_CHIT,
        CACHE_FMISS => MEM70_FMISS,
        IB_MREQ     => IB_MREQ,
        IB_SRES     => IB_SRES_MEM70
      );

    HM_ENA      <= EM_SRES.ack_r or EM_SRES.ack_w;
    CACHE_FMISS <= MEM70_FMISS or sys_conf_cache_fmiss;
      
    SRAM_CTL: s3_sram_memctl
      port map (
        CLK         => CLK,
        RESET       => CPU_RESET,
        REQ         => MEM_REQ,
        WE          => MEM_WE,
        BUSY        => MEM_BUSY,
        ACK_R       => MEM_ACK_R,
        ACK_W       => open,
        ACT_R       => MEM_ACT_R,
        ACT_W       => MEM_ACT_W,
        ADDR        => MEM_ADDR(17 downto 0),
        BE          => MEM_BE,
        DI          => MEM_DI,
        DO          => MEM_DO,
        O_MEM_CE_N  => O_MEM_CE_N,
        O_MEM_BE_N  => O_MEM_BE_N,
        O_MEM_WE_N  => O_MEM_WE_N,
        O_MEM_OE_N  => O_MEM_OE_N,
        O_MEM_ADDR  => O_MEM_ADDR,
        IO_MEM_DATA => IO_MEM_DATA
      );
    
  end generate MEM_SRAM;
  
  IB_SRES_OR : ib_sres_or_2
    port map (
      IB_SRES_1  => IB_SRES_MEM70,
      IB_SRES_2  => IB_SRES_IBDR,
      IB_SRES_OR => IB_SRES);

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
        DISPREG  => DISPREG);
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
        DISPREG  => DISPREG);
  end generate IBD_MAXI;
    
  DSP_DAT(15 downto 0) <= DISPREG;

  DSP_DP(3) <= not SER_MONI.txok;
  DSP_DP(2) <= SER_MONI.txact;
  DSP_DP(1) <= not SER_MONI.rxok;
  DSP_DP(0) <= SER_MONI.rxact;
  
  proc_led: process (MEM_ACT_W, MEM_ACT_R, CP_STAT, DM_STAT_DP.psw)
    variable iled : slv8 := (others=>'0');
  begin
    iled := (others=>'0');
    iled(7) := MEM_ACT_W;
    iled(6) := MEM_ACT_R;
    iled(5) := CP_STAT.cmdbusy;
    if CP_STAT.cpugo = '1' then
      case DM_STAT_DP.psw.cmode is
        when c_psw_kmode =>
          if CP_STAT.cpuwait = '1' then
            iled(2) := '1';
          elsif unsigned(DM_STAT_DP.psw.pri) = 0 then
            iled(3) := '1';
          else
            iled(4) := '1';
          end if;
        when c_psw_smode =>
          iled(1) := '1';
        when c_psw_umode =>
          iled(0) := '1';
        when others => null;
      end case;
    else
      iled(4) := '1';
      iled(3 downto 0) := CP_STAT.cpurust;
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
