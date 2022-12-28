#!/usr/bin/csh

setenv PRJ_ROOT ~/pwr_prj/123-main

verdi   +v2k \
        -sverilog \
        -nologo \
        -2009 \
        -ssv \
        -ssy \
        -ssz \
        -f ../lv_top/lv_top.f \
        -f ../hv_top/hv_top.f \
        -f ../verification/tb.f \
        -l verdi_cmp.log \
        -top tb

