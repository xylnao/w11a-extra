# $Id: Makefile 442 2011-12-23 10:03:28Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2011-12-11   438   1.0.1  added tb_tst_serloop1_n3
# 2011-11-27   433   1.0    Initial version
#
EXE_all  = tb_tst_serloop1_n3 
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
