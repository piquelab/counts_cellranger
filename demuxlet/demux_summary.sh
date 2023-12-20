#!/bin/bash



cat ../libList.txt | \
while read f; do 
    cat demuxlet/${f}.out.best \
	| grep 'SNG' \
	| awk '$3>20 && $4>20 && NR>1{print $13}' \
	| sort | uniq -c | sort -k1,1 -n \
	| awk -v ff=$f -v OFS='\t' '$1>100{print ff,$2,$1}'; 
done > demux.summary.tsv

cat  demux.summary.tsv

##bash summary.sh | awk '{print $2,$1}' | sed 's/-RNA-.*//g' | sort | uniq -c
