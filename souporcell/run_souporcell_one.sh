#!/bin/bash
#SBATCH -N 1-1
#SBATCH -q primary
#SBATCH -n 4
#SBATCH --mem=40G
#SBATCH -t 2000
#SBATCH --job-name SoC

module load singularity

##sample="s1W"

# if [ -z ${PBS_O_WORKDIR+x} ]; then 
#     echo "Working in current folder"; 
# else 
#     cd $PBS_O_WORKDIR
# fi


##refvcf="all.1kg.reorder.v2.vcf.gz"

if [ -z ${sample+x} ]; then 
    exit;
else
    echo "Processing ${sample}"
fi

if [ -z ${K+x} ]; then 
    exit;
else
    echo "Using K=${K}"
fi

mkdir -p ./${sample}

zcat ../${sample}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz > ${sample}/barcodes.tsv

##K=4

##socFolder=/nfs/rprdata/scilab/novogene/counts.hg19/souporcell/
socFolder=/wsu/home/groups/piquelab/data/souporcell/


singularity exec -B /nfs,/wsu ${socFolder}/souporcell.sif souporcell_pipeline.py \
    -i ../${sample}/outs/possorted_genome_bam.bam -b ${sample}/barcodes.tsv \
    -f ${socFolder}/genome.fa -t ${SLURM_CPUS_ON_NODE} -k $K \
    -o ${sample}

module load samtools 
module load misc
cd ${sample}

refvcf="../../genotypes/ref.vcf.gz"

bcftools query -l cluster_genotypes.vcf | awk '{print "'$sample'_"$1}' > clusterNames.txt
cat cluster_genotypes.vcf | grep -v -w BACKGROUND | bcftools reheader  -s clusterNames.txt - |  bcftools view -Oz -o cgeno.vcf.gz
bcftools index cgeno.vcf.gz
bcftools merge -R cgeno.vcf.gz cgeno.vcf.gz ${refvcf} -Oz --threads 4 -o cgeno.merge.vcf.gz
plink2 --make-king-table --vcf cgeno.merge.vcf.gz  --allow-extra-chr







