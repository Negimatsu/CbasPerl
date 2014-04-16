#!/bin/bash
 
files=$(find . -name "*.fna")
create="cat $files > xx.fna"
eval $create
#cmd="makeblastdb -in \"$files\" -dbtype nucl -title \"Bacterial Genomes\" -out bacteria";
#eval $cmd;
#find . -type f -name '*.fna' -exec makeblastdb -in {} -dbtype nucl -parse_seqids \;

