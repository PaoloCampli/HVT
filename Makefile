task_1=update_gdenr/code
task_2=distance_cutoff/code
task_3=dta_to_top5/code
task_4=dta_to_times_fixed_sample/code
task_5=dta_to_rcma/code
task_6=make_panel_top5/code
task_7=make_panel_rcmacut/code
task_8=make_panel_times/code
task_9=top5times_to_reg/code
task_10=rcmacut_to_reg/code
task_11=times_to_reg/code
task_12=merge_connectivity_measures/code
task_13=indep_reg_top5/code
task_14=indep_reg_rcma/code
task_15=indep_reg_times/code
task_16=sureg_times/code

task_17=grapher/code



full_version:
					# $(MAKE) -C $(task_1)
					# $(MAKE) -C $(task_2)
					# $(MAKE) -C $(task_3)
					# $(MAKE) -C $(task_4)
					# $(MAKE) -C $(task_5)
					# $(MAKE) -C $(task_6)
					# $(MAKE) -C $(task_7)
					# $(MAKE) -C $(task_8)
					$(MAKE) -C $(task_9)
					$(MAKE) -C $(task_10)
					$(MAKE) -C $(task_11)
					$(MAKE) -C $(task_12)
					$(MAKE) -C $(task_13)
					$(MAKE) -C $(task_14)
					$(MAKE) -C $(task_15)
					$(MAKE) -C $(task_16)
					$(MAKE) -C $(task_17)
