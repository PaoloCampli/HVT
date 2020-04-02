dirs_symlinks = create_dirs_symlinks.txt

stata_dta = ../input/merge_connectivity_measures.dta
output = ../output/...

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): event_studies.do $(stata_dta) event_study_intensity_program.do
	stata-mp -b do $<
