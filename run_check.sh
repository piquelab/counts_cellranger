#!/bin/bash

set -v
set -e 

echo $PWD

fastqfolder=/nfs/prb/fe0105/preeclampsia/fastqs/



cat libList.txt | \
while read sample; 
do    
    if [ ! -f "check.${sample}.out" ]; then 
	echo "#################"
	echo $sample 
	fastqs=`find ${fastqfolder} -name "${sample}_*fastq.gz" | sed "s/\/${sample}_S.*//" | sort | uniq`
	fastqlist=`echo ${fastqs} | tr ' ' ,`
	echo $fastqlist
	sbatch -q primary -n 4 -N 1-1 --mem=20G -t 2000 -J $sample -o check.$sample.out  --wrap "
module load samtools; 
samtools view -c $sample/possorted_genome_bam.bam
md5sum $sample/possorted_genome_bam.bam 
"  
    fi
done

