#!/bin/bash

set -v
set -e 

echo $PWD

##fastqfolder=/nfs/prb/fe0105/preeclampsia/fastqs/

mkdir -p ./dbgap

cat libList.txt | \
while read sample; 
do    
    if [ ! -f "check.${sample}.out" ]; then 
	echo "#################"
	echo $sample 
##	fastqs=`find ${fastqfolder} -name "${sample}_*fastq.gz" | sed "s/\/${sample}_S.*//" | sort | uniq`
##	fastqlist=`echo ${fastqs} | tr ' ' ,`
##	echo $fastqlist
	sbatch -q primary -n 4 -N 1-1 --mem=20G -t 2000 -J $sample -o check.$sample.out  --wrap "
module load samtools; 
samtools view -c $sample/possorted_genome_bam.bam
ln -s $sample/possorted_genome_bam.bam  ./dbgap/${sample}.bam
ln -s $sample/possorted_genome_bam.bam.bai  ./dbgap/${sample}.bam.bai
md5sum ./dbgap/${sample}.bam > ./dbgap/${sample}.bam.md5 
"  
    fi
done

