#!/usr/bin/env bash

mkdir -p ../input/
mkdir -p ../output/

ln -s ../../rcmacut_to_reg/output/rcmacut_to_reg.dta ../input
ln -s ../../times_to_reg/output/times_to_reg.dta ../input
ln -s ../../top5times_to_reg/output/top5times_to_reg.dta ../input
