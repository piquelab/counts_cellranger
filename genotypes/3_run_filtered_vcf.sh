#!/bin/bash

set -v
set -e

## Reference genome fasta. It should match the one used for alignment. 
refGenome="/nfs/rprscratch/1Kgenomes/phase2_reference_assembly_sequence/hs37d5.fa.bgz"

## Initial genotype file vcf, Prefilter: MAF>0 to remove monomorphic SNPs. and to keep only snp and -m2 -M2
gencoveVCF="./ref.vcf.gz"
bamcovFolder="./bamcov/"


## Second run run_vcf_bam_cov.sh to make the pileups for each library.  

## Third get a sufficeintly large node to merge the bcf files once completed.
##merge bcf files 
####bcftools merge ${bamcovFolder}/*.bcf --threads 10  -Oz -o ${prefix}.merge.vcf.gz &
## we are going to get positions individually and not merge... 
## this part has been moved to the other script for individual library processing. 

prefix="combined"

### (2). extract SNP acoording to position keeping only those with more than a certain depth of coverage. 
## user-defined format to keep positions. 
## moved to the individual script. 
####bcftools query ${prefix}.merge.vcf.gz -i 'INFO/DP>100' -f '%CHROM\t%POS\n' | bgzip > ${prefix}.posG100.txt.gz &

##keep
#zcat bamcov/*.posG9.txt.gz | cut -f1,2 | sort -k1,1 -k2,2 -n | uniq | bgzip > ${prefix}.posG9.txt.gz 


## subset Original vcf file at well covered positions. 
#bcftools view -T <(zcat ${prefix}.posG9.txt.gz) ${gencoveVCF} --threads 10 -Oz -o ${prefix}.posG9.AL.vcf.gz
#keep

## MAF Calculator. (RPR I need AF and MAF, this can be comented if in orginal REF file..???)
#bcftools plugin fill-tags ${prefix}.posG9.AL.vcf.gz -- -t 'AN,AC,AF,MAF' \
#  | bcftools view --threads 10 -Oz -o ${prefix}.posG9.AF.vcf.gz

### (3). transfer the format required by demuxlet
# reorder VCF lexicographically by chromosome number
#bcftools index ${prefix}.posG9.AF.vcf.gz --threads 10
#bcftools view -r 1,10,11,12,13,14,15,16,17,18,19,2,20,21,22,3,4,5,6,7,8,9 ${prefix}.posG9.AF.vcf.gz --threads 10 -Oz -o ${prefix}.posG9.reordered.vcf.gz 
#bcftools index ${prefix}.posG9.reordered.vcf.gz --threads 10

bcftools view -h ${prefix}.posG9.reordered.vcf.gz --threads 10 | grep -v contig > my1.vcf.header
bcftools reheader -h my1.vcf.header ${prefix}.posG9.reordered.vcf.gz --threads 10 -o ${prefix}.posG9.reheader.vcf.gz 

## NOT SURE IF ANYTHING AFTER THIS IS NECESSARY

##filter by MAF (RPR not necessary for my problem here. )
#bcftools view ${prefix}.posG100.reheader.vcf.gz -i 'INFO/MAF>0.05' --threads 10 -Oz -o ${prefix}.posG100.reheaderMAF.vcf.gz &


##zcat SCAIP1-6.merge.posG40.reheader.vcf.gz|head -n 1
#bcftools query ${prefix}.reordered.vcf.gz -i 'INFO/MAF>0' -f '%CHROM\t%POS\n')|wc -l &


#cat <(bcftools query SCAIP1-6.filtered2.vcf.gz -f '%CHROM\t%POS\t%INFO/AF\n')|wc -l &
#cat <(bcftools query SCAIP1-6.filtered5.vcf.gz -f '%CHROM\t%POS\n' --threads 5)|wc -l &
#bcftools query SCAIP.ALL-1-6.merge.posG4.reordered.vcf.gz -f '%CHROM\t%POS\t%INFO/AN\t%INFO/AC\t%INFO/AF\n') > zzz.posG4.txt
#bcftools view SCAIP-ALL.vcf.gz -h >zzz.header
#cat <(bcftools query SCAIP-ALL.vcf.gz -f '%CHROM\t%POS\t%INFO/AN\t%INFO/AC\n') > zzz.txt
#bcftools query -l SCAIP-ALL.1-6.vcf.gz |head
#zcat SCAIP-ALL.1-6.posG4.txt.gz|wc -l
#bcftools query SCAIP-ALL.1-6.reordered.vcf.gz -f '%CHROM\t%POS\n'|wc -l &
#bcftools query SCAIP-ALL.1-6.AL.vcf.gz -f '%CHROM\t%POS\n'|wc -l &
#bcftools query SCAIP-ALL.1-6.reheader.vcf.gz -i 'INFO/MAF>0.05' -f '%CHROM\t%POS\n'|wc -l &
#bcftools query SCAIP-ALL.1-6.reheader.vcf.gz -f '%CHROM\t%POS\n'|wc -l &
#bcftools query SCAIP-ALL.1-6.merge.vcf.gz -f '%CHROM\t%POS\t%INFO/DP\n'|bgzip > zzz.infor.txt.gz &
#bcftools query SCAIP-ALL.1-6.reheader.vcf.gz -f '%CHROM\t%POS\t%INFO/MAF\n'|bgzip > zzz.infor.txt.gz &
#zcat SCAIP-ALL.1-6.reheader.vcf.gz|sed '2p'

#bcftools query SCAIP-ALL.1-6.posG100.reheaderMAF.vcf.gz -f '%CHROM\t%POS\n'|wc -l &









