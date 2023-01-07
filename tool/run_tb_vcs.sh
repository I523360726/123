#!/usr/bin/csh

setenv PRJ_ROOT /home/Data/hw32/ZXJ/123-main

vcs -sverilog \
    +v2k \
    +plusarg_save \
    +nospecify \
    +notimeingcheck \
    +libext+.svh+.v+.sv+.vh \
    -full64 \
    -debug_acc+all \
    -kdb \
    -f ../lv_top/lv_top.f \
    -f ../hv_top/hv_top.f \
    -f ../verification/tb.f \
    -timescale=1ns/100ps \
    -l ./vcs_cmp.log \
    -o test_simv
