dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/
output = ../output/make_panel_top5.dta

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): make_panel_top5.do $(stata_dta)
	-bash run.sh
