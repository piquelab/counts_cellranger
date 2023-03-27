#!/bin/bash
set -v
set -e


##ln -s /wsu/home/groups/prbgenomics/genotyping-data/PRB_Geno_UofM/mergeAll.2022-11-16/merge.vcf.gz

##ln -s /wsu/home/groups/prbgenomics/genotyping-data/PRB_Geno_UofM/mergeAll.2021-07-29/2021-07-29_merge.vcf.gz 
#ln -s /wsu/home/groups/prbgenomics/genotyping-data/PRB_Geno_UofM/mergeAll.2021-07-29/2021-07-29_merge.vcf.gz.csi


module load samtools misc


## Keeping only Covid-19 samples from the vcf file. 


## Selects bi-allelic SNPs with MAF>0 and from the samples that are present, and renames to HPL-F/M 
## This creates the master reference genotype file. 
bcftools view -S <(cat selectedSamples4.txt | cut -f1) -v snps -m2 -M2 -i 'INFO/MAF>0' merge.vcf.gz --threads 4 \
  | bcftools reheader -s <(cat selectedSamples4.txt | cut -f2) --threads 4 \
  | bcftools view -Oz -o ref.vcf.gz --threads 4

bcftools index ref.vcf.gz

##  | bcftools plugin fill-tags ${prefix}.posG9.AL.vcf.gz -- -t 'AN,AC,AF,MAF' \
plink2 --make-king-table --vcf ref.vcf.gz 
less plink2.kin0 | awk '$6>0.1'

## ln -s ../../genotype_merge/ref.vcf.gz
## ln -s ../../genotype_merge/ref.vcf.gz.csi 
