#!/bin/bash

set -v
set -e

demuxFolder="./fdout/"
vcfFile="../genotypes/combined.posG9.reheader.vcf.gz"

ncpus=12

mkdir -p ${demuxFolder} 

cat ../libList.txt | \
while read sample;
do
    if [ ! -f "slurm.${sample}.out" ]; then 
	echo "#################"
	echo ${sample}
	sbatch -q express --mem=25G -N 1-1 -n ${ncpus} -t 20000 -J fd-${sample} -o slurm.${sample}.fd.out <<EOF
#!/bin/bash
set -v 
set -e
module load misc; 
echo "SLURM_JOB_ID:"\$SLURM_JOB_ID
echo "SLURM_JOB_NAME:"\$SLURM_JOB_NAME
time fastdemux -t ${ncpus} ../CITE_${sample}/possorted_genome_bam.bam ${vcfFile} ../CITE_${sample}/raw_feature_bc_matrix/barcodes.tsv.gz ${demuxFolder}/${sample}.fdout.raw 
sacct -j \$SLURM_JOB_ID --format=JobID,MaxRSS,CPUTime,AveRSS --parsable2
EOF
    fi
done

##| qsub -q wsuq -l mem=120gb -l ncpus=2 -N $sample${2}
###combined.posG9.reordered.vcf.gz
