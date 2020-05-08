dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/firms_count_raw.dta
output = ../output/firms_count.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt

$(output): firms_count.do $(stata_dta)
	stata-mp -b do $<
