# $Id: Makefile 442 2011-12-23 10:03:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-08-13   405   1.4    use includes from rtl/make
# 2010-12-05   343   1.3    rri->rlink renames
# 2009-11-21   252   1.2    add ISim support
# 2007-11-03    95   1.1.2  use .log rather .dat output in check_dsim
# 2007-09-16    83   1.1.1  add include *.o.dep_ghdl
# 2007-06-29    61   1.1    add clean and all
# 2007-06-10    51   1.0    Initial version
#
EXE_all  = tb_rlink_direct 
EXE_all += tb_rlink_sp1c
#
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean isim_clean
#
#-----
#
include $(RETROBASE)/rtl/make/generic_ghdl.mk
include $(RETROBASE)/rtl/make/generic_isim.mk
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(VBOM_all:.vbom=.dep_isim)
include $(wildcard *.o.dep_ghdl)
#
