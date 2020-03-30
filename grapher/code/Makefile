dirs_symlinks = create_dirs_symlinks.txt

output = ../output/graphviz.txt\
					../output/task_flow.png

all: $(dirs_symlinks) $(output)

$(dirs_symlinks): create_dirs_symlinks.sh
	-bash create_dirs_symlinks.sh
	@echo "" > create_dirs_symlinks.txt


$(output): graphviz.sh
	-bash graphviz.sh
