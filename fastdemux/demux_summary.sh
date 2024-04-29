#!/bin/bash

cat ../libList.txt | \
while read f; do 
    zcat fdout/${f}.fdout.raw.info.2nd.txt.gz \
	| awk '$3>100 && $4>100 && $5==1 && NR>1{print $8}' \
	| sort | uniq -c | sort -k1,1 -n \
	| awk -v ff=$f -v OFS='\t' '$1>100{print ff,$2,$1}'; 
done > demux.summary.tsv

cat  demux.summary.tsv

##less fdout/HOLD11-RNA-CTRL.fdout.raw.info.txt.gz | awk '$4>100 && $5==1' | cut -f8 | sort | uniq -c | awk '$1>100'
##bash summary.sh | awk '{print $2,$1}' | sed 's/-RNA-.*//g' | sort | uniq -c
