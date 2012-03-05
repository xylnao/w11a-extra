# $Id$
#
#  Revision History: 
# Date         Rev Version  Comment
# 2012-02-24   ???   1.0    Initial version
#
EXE_all = tb_w11a_mb
#
ISE_PATH  = xc6slx9-csg324-2
#
XFLOWOPT_SYN = syn_s6_speed.opt
XFLOWOPT_IMP = imp_s6_speed.opt
#
#
.PHONY : all all_ssim all_tsim clean
#
all      : $(EXE_all)
all_ssim : $(EXE_all:=_ssim)
all_tsim : $(EXE_all:=_tsim)
#
clean : ise_clean ghdl_clean
#
#-----
#
include $(RETROBASE)/rtl/make/generic_ghdl.mk
include $(RETROBASE)/rtl/make/generic_xflow.mk
#
VBOM_all = $(wildcard *.vbom)
#
include $(VBOM_all:.vbom=.dep_xst)
include $(VBOM_all:.vbom=.dep_ghdl)
include $(wildcard *.o.dep_ghdl)
#
