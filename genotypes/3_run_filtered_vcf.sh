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

module load samtools/1.11

ncpus=4  ##$SLURM_CPUS_ON_NODE

## Reference genome fasta. It should match the one used for alignment. 
#refGenome="/nfs/rprscratch/1Kgenomes/phase2_reference_assembly_sequence/hs37d5.fa.bgz"
##refGenome="/wsu/el7/groups/piquelab/refData/refGenome10x/refdata-cellranger-arc-GRCh38-2020-A-2.0.0/fasta/genome.fa"
##refGenome="/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-hg19-3.0.0/fasta/genome.fa"
## not used in this script.


## Initial genotype file vcf, Prefilter: MAF>0 to remove monomorphic SNPs. and to keep only snp and -m2 -M2
## See 1_make_basic_ref_vcf.sh script
gencoveVCF="./ref.vcf.gz"
bamcovFolder="./bamcov/"


## Second run 2_run_vcf_bam_cov.sh to make the pileups for each library.  

## Third get a sufficeintly large node to merge all pileup locations with sufficient coverage. 

prefix="combined"

if [ ! -f ${prefix}.posG9.txt.gz ]; then
    zcat bamcov/*.posG9.txt.gz | cut -f1,2 | sort -k1,1 -k2,2 -n | uniq | bgzip > ${prefix}.posG9.txt.gz 
fi


## subset Original vcf file at well covered positions.
if [ ! -f ${prefix}.posG9.AL.vcf.gz ]; then 
    bcftools view -T <(zcat ${prefix}.posG9.txt.gz) ${gencoveVCF} --threads ${ncpus} -Oz -o ${prefix}.posG9.AL.vcf.gz
fi

## MAF Calculator. (RPR I need AF and MAF, this can be comented if in orginal REF file..???)
if [ ! -f ${prefix}.posG9.AF.vcf.gz ]; then
    bcftools plugin fill-tags ${prefix}.posG9.AL.vcf.gz -- -t 'AN,AC,AF,MAF' \
	| bcftools view --threads $ncpus -Oz -o ${prefix}.posG9.AF.vcf.gz
    bcftools index ${prefix}.posG9.AF.vcf.gz --threads $ncpus
fi

### (3). transfer the format required by demuxlet
# reorder VCF lexicographically by chromosome number

if [ ! -f ${prefix}.posG9.reordered.vcf.gz ]; then
##    bcftools view -r `echo "chr"{1,10,11,12,13,14,15,16,17,18,19,2,20,21,22,3,4,5,6,7,8,9} | tr ' ' ,` ${prefix}.posG9.AF.vcf.gz --threads ${ncpus} -Oz -o ${prefix}.posG9.reordered.vcf.gz

    bcftools view -r `echo chr{1,10,11,12,13,14,15,16,17,18,19,2,20,21,22,3,4,5,6,7,8,9} | tr ' ' ,` ${prefix}.posG9.AF.vcf.gz --threads ${ncpus} -Oz -o ${prefix}.posG9.reordered.vcf.gz 
    bcftools index ${prefix}.posG9.reordered.vcf.gz --threads ${ncpus}
fi

if [ ! -f ${prefix}.posG9.reheader.vcf.gz ]; then
    bcftools view -h ${prefix}.posG9.reordered.vcf.gz | grep -v contig > my1.vcf.header
    bcftools reheader -h my1.vcf.header ${prefix}.posG9.reordered.vcf.gz --threads ${ncpus} -o ${prefix}.posG9.reheader.vcf.gz 
    bcftools index ${prefix}.posG9.reheader.vcf.gz 
fi




plink2 --make-king-table --vcf combined.posG9.reheader.vcf.gz 
 cat plink2.kin0 | awk '$6>0.1'
