dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/merge_connectivity_measures.dta
output = ../output/tt40_sumstats.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): tt40_sumstats.do $(stata_dta)
	stata-mp -b do $<
