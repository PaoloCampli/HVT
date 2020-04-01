
stata_dta = ../input/merge_connectivity_measures.dta
output = ../output/ind_reg_noagglo_firms.tex

all: dirs_symlinks $(output)

dirs_symlinks: create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh

$(output): indep_reg_times.do $(stata_dta)
	-bash run.sh
