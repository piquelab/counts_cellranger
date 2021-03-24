#!/bin/bash

destfolder=/nfs/rprscratch/wwwShare/genome.grid.wayne.edu/sc-brain/${PWD##*/}

mkdir -p $destfolder


cat libList.txt | while read f; 
do 
    echo $f 
    cp $f/outs/web_summary.html $destfolder/$f.html 
done




cp summary.tsv $destfolder/
cp all_summary.csv $destfolder/
