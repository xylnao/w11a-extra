# $Id: generic_ghdl.mk 405 2011-08-14 08:16:28Z mueller $
#
#  Revision History: 
# Date         Rev Version Comment
# 2011-08-13   405   1.3    renamed, moved to rtl/make;
# 2007-11-04    95   1.2.2  fix find statement in ghdl_tmp_clean
# 2007-11-02    94   1.2.1  don't delete cext_*.o in ghdl_tmp_clean
# 2007-07-08    65   1.2    support now autobuilding of _fsim and _tsim models
# 2007-06-16    57   1.1    cleanup ghdl_clean handling 
# 2007-06-10    52   1.0    Initial version
#
GHDLIEEE = --ieee=synopsys
GHDLUNISIM = -P$(XILINX)/ghdl/unisim
GHDLSIMPRIM = -P$(XILINX)/ghdl/simprim
GHDL = ghdl
COMPILE.vhd = $(GHDL) -a $(GHDLIEEE)
LINK.vhd = $(GHDL) -e $(GHDLIEEE)
#
% : %.vbom
	vbomconv --ghdl_i $<
	vbomconv --ghdl_m $<
#
# rules for _[ft]sim to use 'virtual' [ft]sim vbom's  (derived from _ssim)
#
%_fsim : %_ssim.vbom
	vbomconv --ghdl_i $*_fsim.vbom
	vbomconv --ghdl_m $*_fsim.vbom
#
%_tsim : %_ssim.vbom
	vbomconv --ghdl_i $*_tsim.vbom
	vbomconv --ghdl_m $*_tsim.vbom
#
%.dep_ghdl: %.vbom
	vbomconv --dep_ghdl $< > $@
#
.PHONY: ghdl_clean ghdl_tmp_clean
#
ghdl_clean: ghdl_tmp_clean
	rm -f $(EXE_all)
	rm -f $(EXE_all:%=%_[sft]sim)
	rm -f $(EXE_all:%=%.exe)
	rm -f $(EXE_all:%=%_[sft]sim.exe)
	rm -f cext_*.o
#
ghdl_tmp_clean:
	find -maxdepth 1 -name "*.o" | grep -v "^\./cext_" | xargs rm -f
	rm -f work-obj93.cf
#
