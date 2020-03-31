#!/usr/bin/env bash

mkdir -p ../input/
mkdir -p ../output/

ln -sfn ../../clean_tax_bases/output/clean_tax_bases.dta ../input
ln -sfn ../../make_panel_top5/output/make_panel_top5.dta ../input
ln -sfn ../../new_tax_data/input/new_tax_data.dta ../input
