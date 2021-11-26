#!/bin/bash
set -v
set -e


## NOT USED FOR THE BRAIN PROJECT,  JUST creat a link with the right vcf file wiht a name ref.vcf.gz 
exit


##ln -s /nfs/rprdata/scilab/labor2/PRB_Geno_UofM/RP/outvcf/split/imputed/trimerge.vcf.gz
##ln -s /wsu/home/groups/prbgenomics/genotyping-data/PRB_Geno_UofM/Prjt_359_Pique-Regi_20201217_2535-RP/imputed.UM/2021-01-12_merge.vcf.gz

#ln -s /wsu/home/groups/prbgenomics/genotyping-data/PRB_Geno_UofM/mergeAll.2021-07-29/2021-07-29_merge.vcf.gz 
#ln -s /wsu/home/groups/prbgenomics/genotyping-data/PRB_Geno_UofM/mergeAll.2021-07-29/2021-07-29_merge.vcf.gz.csi


module load samtools misc


## Keeping only Covid-19 samples from the vcf file. 


## Selects bi-allelic SNPs with MAF>0 and from the samples that are present, and renames to HPL-F/M 
## This creates the master reference genotype file. 
bcftools view -S <(tail -n +2 Covid19GenotypeTable.txt | cut -f2) -v snps -m2 -M2 -i 'INFO/MAF>0' 2021-07-29_merge.vcf.gz --threads 4 \
  | bcftools reheader -s <(tail -n +2 Covid19GenotypeTable.txt | cut -f5) --threads 4 \
  | bcftools view -Oz -o ref.vcf.gz --threads 4

bcftools index ref.vcf.gz

##  | bcftools plugin fill-tags ${prefix}.posG9.AL.vcf.gz -- -t 'AN,AC,AF,MAF' \
plink2 --make-king-table --vcf ref.vcf.gz 
less plink2.kin0 | awk '$6>0.1'
