#!/usr/bin/env bash
set -euo pipefail

mkdir -p sim_build

iverilog -g2012 \
  -s tb_top_full \
  -o sim_build/tb_top.vvp \
  rtl/*.v tb/tb_top.v

vvp sim_build/tb_top.vvp
