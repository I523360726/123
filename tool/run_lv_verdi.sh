#!/usr/bin/csh

setenv PRJ_ROOT ~/pwr_prj/123-main

verdi +v2k \
      -sverilog \
      -nologo \
      -2009 \
      -ssv \
      -ssy \
      -ssz \
      -f ../lv_top/lv_top.f \
      -l verdi_cmp.log \
      -top dig_lv_top

