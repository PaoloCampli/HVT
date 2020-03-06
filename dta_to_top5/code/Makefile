dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/merge_towns_adj_update_bfsplz_commuting1950clean.dta \
						../input/output/*
output = ../output/times_top5_{1955..2015}.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): dta_to_top5.do $(stata_dta)
	-bash run.sh
