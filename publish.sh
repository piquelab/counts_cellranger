#!/bin/bash

destfolder=/nfs/rprscratch/wwwShare/labor2/cite-seq2/${PWD##*/}

mkdir -p $destfolder


cat libList.txt | while read f; 
do 
    echo $f 
    cp CITE_$f/web_summary.html $destfolder/CITE_$f.html 
done




cp summary.tsv $destfolder/
cp all_summary.csv $destfolder/
