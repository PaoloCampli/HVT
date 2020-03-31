dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/clean_tax_bases.dta\
						../input/make_panel_times.dta\
						../input/new_tax_data.dta
output = ../output/times_to_reg.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.txt
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): times_to_reg.do $(stata_dta)
	-bash run.sh
