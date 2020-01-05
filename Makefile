all: \
#	need to understand how to include locals from stata in filename
	# event_study/output/graph_lndt_8_cut.pdf
	# event_study/output/ev_sty_ln_stpf_norm_p90_8_cut.pdf
	# event_study/output/graph_log_tax90_8_cut.pdf


event_study/output/graph_lndt_8_cut.pdf: \
	times_to_reg/output/times_to_reg.dta \
	event_study/code/event_study.do

	StataMP -b do rcma_to_reg/code/rcma_to_reg.do &
