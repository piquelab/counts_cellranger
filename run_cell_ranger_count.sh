#!/bin/bash

set -v
set -e 

echo $PWD

##module load bcl2fastq
##module load cellranger

## Can use this one as an argument. 
##fastqfolder=../fastq/HV2LVBGXG/
##fastqfolder=../fastq/0H2JCYBGXG/
fastqfolder=../fastqs/NYGC2/


##transcriptome=/nfs/rprdata/refGenome10x/refdata-cellranger-hg19-1.2.0/
##transcriptome=/nfs/rprdata/refGenome10x/refdata-cellranger-GRCh38-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-GRCh38-3.0.0/
transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-hg19-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-gex-mm10-2020-A/


if [ ! -f "libList.txt" ]; then
    find ${fastqfolder} -name '*fastq.gz' | sed 's/.*\///;s/_S.*//' | grep -v Undeter | sort | uniq > libList.txt
fi

##cat $samplefile | cut -d, -f2 | grep -v Sample | sort | uniq |\
##find ${fastqfolder} -name 'CC7*fastq.gz' | sed 's/.*CC7/CC7/;s/_S.*.fastq.gz//' | sort | uniq |\
##cat libList.txt | grep -v s[1-5] |

cat libList.txt | \
while read sample; 
do    
    if [ ! -f "slurm.${sample}.out" ]; then 
	echo "#################"
	echo $sample 
	fastqs=`find ${fastqfolder} -name "${sample}_*fastq.gz" | sed "s/\/${sample}_S.*//" | sort | uniq`
	fastqlist=`echo ${fastqs} | tr ' ' ,`
	echo $fastqlist
	sbatch -q express -n 16 -N 1-1 --mem=110G -t 2000 -J $sample -o slurm.$sample.out  --wrap "
module load bcl2fastq cellranger; 
time cellranger count \
      --id=$sample \
      --fastqs=$fastqlist \
      --sample=$sample \
      --chemistry=SC3Pv3 \
      --transcriptome=$transcriptome \
      --localcores=15 --localmem=80 --localvmem=105
"  
    fi
done

