dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/clean_tax_bases.dta\
						../input/make_panel_top5.dta\
						../input/new_tax_data.dta
output = ../output/top5times_to_reg.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): top5times_to_reg.do $(stata_dta)
	stata-mp -b do $<
