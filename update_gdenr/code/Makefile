


outuput = ../output/merge_towns_adj_update_bfsplz_commuting1950clean.dta

all: $(output)

$(output): \
			update_gdenr.do \
			gemeinde_merge.dta \
			merge_townsbfsplz_commuting1950clean.dta
			stata-mp -b do update_gdenr.do
