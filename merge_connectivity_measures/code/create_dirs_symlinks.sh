#!/usr/bin/env bash

mkdir -p ../input/
mkdir -p ../output/

ln -sfn ../../rcmacut_to_reg/output/rcmacut_to_reg.dta ../input
ln -sfn ../../times_to_reg/output/times_to_reg.dta ../input
ln -sfn ../../top5times_to_reg/output/top5times_to_reg.dta ../input
