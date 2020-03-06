#!/usr/bin/env bash

cd /Users/paolocampli/hw

stata-mp -b do make_panel_rcma/code/make_panel_rcma.do &
stata-mp -b do make_panel_times/code/make_panel_times.do &
stata-mp -b do make_panel_top5/code/make_panel_top5.do &

stata-mp -b do rcmacut_to_reg/code/rcmacut_to_reg.do &
stata-mp -b do top5times_to_reg/code/top5times_to_reg.do &
stata-mp -b do times_to_reg/code/times_to_reg.do &

stata-mp -b do merge_connectivity_measures/code/merge_connectivity_measures.do &

stata-mp -b do indep_reg_rcma/code/indep_reg_rcma.do &
stata-mp -b do indep_reg_times/code/indep_reg_times.do &
stata-mp -b do indep_reg_top5/code/indep_reg_top5.do &

stata-mp -b do sureg_times/code/sureg_times.do &

stata-mp -b do event_studies/code/event_studies.do &



bash graphviz.sh

rm *.log
