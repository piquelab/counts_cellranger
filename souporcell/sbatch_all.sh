#!/bin/bash

##refvcf="all.1kg.reorder.v2.vcf.gz"

##[[ ! -f ${refvcf} ]] && ln -s /nfs/rprdata/scilab/novogene/counts/${refvcf}
##[[ ! -f hs37d5.fa.bgz ]] && ln -s /nfs/rprscratch/1Kgenomes/phase2_reference_assembly_sequence/hs37d5.fa.bgz

cat ../poolSize.txt | \
while read f K; do 
    echo $f K=$K;
    sbatch -q primary -J SoC_$f -o slurm.SoC_$f.out --export=sample="${f}",K=${K} run_souporcell_one.sh; 
done

