#!/bin/bash
 
files=$(find . -name "*.fna")
create="cat $files > all.fna"
eval $create

