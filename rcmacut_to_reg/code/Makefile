dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/clean_tax_bases.dta\
						../input/make_panel_rcmacut.dta\
						../input/new_tax_data.dta
output = ../output/rcmacut_to_reg.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): rcmacut_to_reg.do $(stata_dta)
	stata-mp -b do $<
