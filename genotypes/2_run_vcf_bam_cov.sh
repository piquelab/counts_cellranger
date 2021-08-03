#!/bin/bash

set -v
set -e

## Reference genome fasta. It should match the one used for alignment. 
refGenome="/nfs/rprscratch/1Kgenomes/phase2_reference_assembly_sequence/hs37d5.fa.bgz"
## Initial genotype file vcf, Prefilter: MAF>0 to remove monomorphic SNPs. and to keep only snp and -m2 -M2

##gencoveVCF="/nfs/rprdata/scilab/endometrium/genotypes/HPL20289.vcf.gz"
gencoveVCF="./ref.vcf.gz"
bamcovFolder="./bamcov/"

mkdir -p ${bamcovFolder}
### Find SNPs coverage depth for all Bam files seprately
cat ../libList.txt | \
while read sample; do
    if [ ! -f "slurm.${sample}.out" ]; then  ## prevents job resubmission
	sbatch -q highmem --mem=110G -N 1-1 -n 3 -t 1000 -J ${sample} -o slurm.${sample}.out <<EOF
#!/bin/bash
module load samtools;
echo $sample;
samtools mpileup -f $refGenome -l <(bcftools query $gencoveVCF -f '%CHROM\t%POS\n') ../$sample/outs/possorted_genome_bam.bam -d 1000000 -g -t DP,AD,ADF,ADR > $bamcovFolder/$sample.merge.pileup.bcf; 
bcftools index $bamcovFolder/$sample.merge.pileup.bcf; 
bcftools query $bamcovFolder/$sample.merge.pileup.bcf -i 'INFO/DP>0' -f '%CHROM\t%POS\t%DP\n' | bgzip > $bamcovFolder/$sample.posG0.txt.gz
bcftools query $bamcovFolder/$sample.merge.pileup.bcf -i 'INFO/DP>9' -f '%CHROM\t%POS\n' | bgzip > $bamcovFolder/$sample.posG9.txt.gz
EOF
    fi 
done 
###########################
