#!/bin/bash

set -v
set -e

demuxFolder="./demuxlet/"
vcfFile="../genotypes/combined.posG9.reheader.vcf.gz"

mkdir -p ${demuxFolder} 

cat ../libList.txt | \
while read sample;
do
    if [ ! -f "slurm.${sample}.out" ]; then 
	echo "#################"
	echo ${sample}
	sbatch -q highmem --mem=250G -N 1-1 -n 2 -t 5000 -J ${sample} -o slurm.${sample}.out <<EOF
#!/bin/bash
set -v 
set -e
module load demuxlet; 
popscle.2021-01-18  dsc-pileup \
         --sam ../${sample}/outs/possorted_genome_bam.bam \
         --vcf ${vcfFile} \
         --out ${demuxFolder}/${sample}.d > ${demuxFolder}/${sample}.errout.txt;
popscle.2021-01-18  demuxlet --plp ${demuxFolder}/${sample}.d \
         --vcf ${vcfFile} \
         --out ${demuxFolder}/${sample}.out --field GT --alpha 0.0 --alpha 0.5 --doublet-prior 0.1
EOF
    fi
done



##| qsub -q wsuq -l mem=120gb -l ncpus=2 -N $sample${2}
###combined.posG9.reordered.vcf.gz
