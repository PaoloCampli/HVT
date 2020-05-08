dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/merge_connectivity_measures.dta
output = ../output/ind_reg_std_sample_ln_rmca.tex \
				../output/ind_reg_std_sample_ln_rmca_in_zugang_p_5.tex \
				../output/ind_reg_std_sample_rcma_in_zugang_p_5.tex

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): indep_reg_rcma.do $(stata_dta)
	stata-mp -b do $<
