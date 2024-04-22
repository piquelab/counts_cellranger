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
	sbatch -q primary --mem=25G -N 1-1 -n ${ncpus} -t 20000 -J fd-${sample} -o slurm.${sample}.fd.out <<EOF
#!/bin/bash
set -v 
set -e
module load misc; 
time fastdemux -t ${ncpus} ../${sample}/possorted_bam.bam ${vcfFile} ../${sample}/raw_peak_bc_matrix/barcodes.tsv ${demuxFolder}/${sample}.fdout.raw 
sacct -j \$SLURM_JOB_ID --format=JobID,MaxRSS,CPUTime,AveRSS --parsable2
EOF
    fi
done

##

##time ./fastdemux -t 16 /rs/rs_grp_schold/CZI/ATAC/counts_cellranger_atac/HOLD2-ATAC-CTRL/possorted_bam.bam  /rs/rs_grp_schold/CZI/ATAC/counts_cellranger_atac/genotypes/combined.posG9.reheader.vcf.gz /rs/rs_grp_schold/CZI/ATAC/counts_cellranger_atac/HOLD2-ATAC-CTRL/raw_peak_bc_matrix/barcodes.tsv out.HOLD2-ATAC-CTRL.full 
##| qsub -q wsuq -l mem=120gb -l ncpus=2 -N $sample${2}
###combined.posG9.reordered.vcf.gz
