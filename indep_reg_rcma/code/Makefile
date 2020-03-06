dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/merge_connectivity_measures.dta
output = ../output/ind_reg_try.tex

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): indep_reg_rcma.do $(stata_dta)
	-bash run.sh
