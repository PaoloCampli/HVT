dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/rcmacut_to_reg.dta\
						../input/times_to_reg.dta\
						../input/top5times_to_reg.dta
output = ../output/merge_connectivity_measures.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): merge_connectivity_measures.do $(stata_dta)
	stata-mp -b do $<

#clean:
#	rm -f create_dirs_symlinks.txt
