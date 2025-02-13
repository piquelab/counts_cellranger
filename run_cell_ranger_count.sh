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
fastqfolder=`cd ../fastqs/; pwd -P`

WF=`pwd -P`;


##transcriptome=/nfs/rprdata/refGenome10x/refdata-cellranger-hg19-1.2.0/
##transcriptome=/nfs/rprdata/refGenome10x/refdata-cellranger-GRCh38-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-GRCh38-3.0.0/
##wsu`transcriptome=/wsu/home/groups/piquelab/data/refGenome11x/refdata-cellranger-hg19-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome11x/refdata-gex-mm10-2020-A/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-hg19-3.0.0/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-gex-GRCh38-2020-A/

##transcriptome=/wsu/el7/groups/piquelab/refData/refGenome10x/refdata-gex-GRCh38-2020-A/
##transcriptome=/wsu/home/groups/piquelab/data/refGenome10x/refdata-cellranger-hg19-3.0.0/
transcriptome=/wsu/el7/groups/piquelab/refData/refGenome10x/refdata-gex-GRCh38-2024-A/

abFile=/wsu/home/groups/prbgenomics/prbgenomics/yixuciteseq/antibody.csv

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
        sbatch -q express -n 14 -N 1-1 --mem=110G -t 20000 -J $sample -o slurm.$sample.out  --wrap "
module load cellranger;
echo \$TMPDIR;
cd \$TMPDIR; \
echo 'fastqs,sample,library_type,' > $sample.library.csv; \
echo ${fastqfolder},CITE-GE-$sample,Gene Expression, >> $sample.library.csv; \
echo ${fastqfolder},CITE-CSP-$sample,Antibody Capture, >> $sample.library.csv; \
time cellranger count \
      --id=CITE_$sample \
      --libraries=$sample.library.csv \
      --feature-ref=$abFile \
      --transcriptome=$transcriptome \
      --create-bam true \
      --localcores=12 --localmem=80 --localvmem=105;
mv \$TMPDIR/CITE_$sample/outs $WF/CITE_$sample
"
    fi
done

##      --chemistry=SC3Pv3 \
