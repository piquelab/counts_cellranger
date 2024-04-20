#!/bin/bash

set -v
set -e 

echo $PWD

##module load bcl2fastq
##module load cellranger

## Can use this one as an argument. 
##fastqfolder=../fastq/HV2LVBGXG/
##fastqfolder=../fastq/0H2JCYBGXG/
##fastqfolder=/nfs/prb/fe0105/preeclampsia/fastqs/
fastqfolder=`cd ../fastq/; pwd -P`

WF=`pwd -P`;


##transcriptome=/nfs/rprdata/refGenome10x/refdata-cellranger-hg19-1.2.0/
##transcriptome=/nfs/rprdata/refGenome10x/refdata-cellranger-GRCh38-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-GRCh38-3.0.0/
##wsu`transcriptome=/wsu/home/groups/piquelab/data/refGenome11x/refdata-cellranger-hg19-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome11x/refdata-gex-mm10-2020-A/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-hg19-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-gex-GRCh38-2020-A/

transcriptome=/wsu/el7/groups/piquelab/refData/refGenome10x/refdata-gex-GRCh38-2020-A/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-hg19-3.0.0/

##
if [ ! -f "libList.txt" ]; then
    find -L ${fastqfolder} -name '*fastq.gz' | sed 's/.*\///;s/_S[0-9].*//' | grep -v Undeter | sort | uniq > libList.txt
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
	fastqs=`find -L ${fastqfolder} -name "${sample}_*fastq.gz" | sed "s/\/${sample}_S[0-9].*//" | sort | uniq`
	fastqlist=`echo ${fastqs} | tr ' ' ,`
	echo $fastqlist
	sbatch -q primary -n 16 -N 1-1 --mem=110G -t 20000 -J $sample -o slurm.$sample.out  --wrap "
module load cellranger;
echo \$TMPDIR;
cd \$TMPDIR; \ 
time cellranger count \
      --id=$sample \
      --fastqs=$fastqlist \
      --sample=$sample \
      --transcriptome=$transcriptome \
      --localcores=15 --localmem=80 --localvmem=105;
mv $TMPDIR/$sample/outs $WF/$sample
"  
    fi
done

##      --chemistry=SC3Pv3 \
