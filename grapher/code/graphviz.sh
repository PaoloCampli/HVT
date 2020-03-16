#!/usr/bin/env bash
#Graph the task input-output relationships based on symbolic links

mkdir -p ../output/
echo -e 'digraph G {' > ../output/graphviz.txt #Start graph
find ../.. -type l -ls | awk '{print $13 " -> " $11}' | #List symbolic links
sed 's/\.\.\///g' | sed 's/\.\///g' | #Drop relative paths
sed 's/\/\(input\)\/[a-zA-Z0-9_\.]*//g' | #Retain only task names; drop filenames
sed 's/\/\(output\)\/[a-zA-Z0-9_\.]*//g' >> ../output/graphviz.txt #Ditto; write to file
echo '}' >> ../output/graphviz.txt #Close graph

dot -Grankdir=LR -Tpng ../output/graphviz.txt -o ../output/task_flow.png
