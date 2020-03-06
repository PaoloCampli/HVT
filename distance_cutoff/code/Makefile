dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/merge_towns_adj_update_bfsplz_commuting1950clean.dta
output = ../output/dist_cutoff_1955_40.dta ../output/dist_cutoff_1955_80.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): distance_cutoff.do $(stata_dta)
	-bash stata-mp -b do distance_cutoff.do &
