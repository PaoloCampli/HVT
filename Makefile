task_1 = update_gdenr/code
task_2 = distance_cutoff/code
task_3 = dta_to_top5/code
...

full_version:
					$(MAKE) -C $(task_1)
					$(MAKE) -C $(task_2)
					$(MAKE) -C $(task_3)					
