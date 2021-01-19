#!/bin/bash

##-q express -t 10000 -N 1-1 -n 28 --mem=110G

#SBATCH --job-name 3_filter_vcf
#SBATCH -q express
#SBATCH -N 1-1
#SBATCH -n 28
#SBATCH --mem=110G
#SBATCH -o slurm_3_filter_vcf_%j.out
#SBATCH -t 10000

set -v
set -e

module load samtools
module load bcftools;

ncpus=$SLURM_CPUS_ON_NODE

## Reference genome fasta. It should match the one used for alignment. 
refGenome="/nfs/rprscratch/1Kgenomes/phase2_reference_assembly_sequence/hs37d5.fa.bgz"

## Initial genotype file vcf, Prefilter: MAF>0 to remove monomorphic SNPs. and to keep only snp and -m2 -M2
## See 1_make_basic_ref_vcf.sh script
gencoveVCF="./ref.vcf.gz"
bamcovFolder="./bamcov/"


## Second run 2_run_vcf_bam_cov.sh to make the pileups for each library.  

## Third get a sufficeintly large node to merge all pileup locations with sufficient coverage. 

prefix="combined"

zcat bamcov/*.posG9.txt.gz | cut -f1,2 | sort -k1,1 -k2,2 -n | uniq | bgzip > ${prefix}.posG9.txt.gz 


## subset Original vcf file at well covered positions. 
bcftools view -T <(zcat ${prefix}.posG9.txt.gz) ${gencoveVCF} --threads ${ncpus} -Oz -o ${prefix}.posG9.AL.vcf.gz

## MAF Calculator. (RPR I need AF and MAF, this can be comented if in orginal REF file..???)
bcftools plugin fill-tags ${prefix}.posG9.AL.vcf.gz -- -t 'AN,AC,AF,MAF' \
  | bcftools view --threads $ncpus -Oz -o ${prefix}.posG9.AF.vcf.gz

### (3). transfer the format required by demuxlet
# reorder VCF lexicographically by chromosome number
bcftools index ${prefix}.posG9.AF.vcf.gz --threads $ncpus
bcftools view -r 1,10,11,12,13,14,15,16,17,18,19,2,20,21,22,3,4,5,6,7,8,9 ${prefix}.posG9.AF.vcf.gz --threads ${ncpus} -Oz -o ${prefix}.posG9.reordered.vcf.gz 
bcftools index ${prefix}.posG9.reordered.vcf.gz --threads ${ncpus}

bcftools view -h ${prefix}.posG9.reordered.vcf.gz | grep -v contig > my1.vcf.header
bcftools reheader -h my1.vcf.header ${prefix}.posG9.reordered.vcf.gz --threads ${ncpus} -o ${prefix}.posG9.reheader.vcf.gz 

bcftools index ${prefix}.posG9.reheader.vcf.gz 



