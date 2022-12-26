#!/usr/bin/csh

setenv PRJ_ROOT ~/pwr_prj/123-main

verdi +v2k \
      -sverilog \
      -nologo \
      -2009 \
      -ssv \
      -ssy \
      -ssz \
      -f ../hv_top/hv_top.f \
      -l verdi_cmp.log \
      -top dig_hv_top

