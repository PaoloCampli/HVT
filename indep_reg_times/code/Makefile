
stata_dta = ../input/merge_connectivity_measures.dta
output = ../output/ind_reg_std_sample_firms_tt40.tex \
				../output/ind_reg_std_sample_tt40.tex \
				../output/ind_reg_std_sample_noaccess_tt40.tex \


all: dirs_symlinks $(output)

dirs_symlinks: create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh

$(output): indep_reg_times.do $(stata_dta)
	stata-mp -b do $<
