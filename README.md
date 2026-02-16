# counts_cellranger
General script to run cellranger counts at the Wayne State University High Performance Computing Grid. 

# Quick start for a new single cell project. 

We assume that `fastq.gz` files are in the `./fastq` folder following the conventional 10 cellranger standard. Files can be organized in folders from multiple runs, or merged.   

```
git clone git@github.com:piquelab/counts_cellranger.git
bash run_cell_ranger_count.sh
```
Modify the `run_cell_ranger_count.sh` script if more memory, or resources are necessary. This script script submits a local job to a node to process one 10X library at a time. 

For demultiplexing pooled samples, you need to put a `ref.vcf.gz` in the `./genotyping` folder and then use `2_run_vcf_bam_cov.sh` to filter SNPs with low coverage, and `3_run_filtered_vcf.sh` to create the final filtered and merged `vcf.gz` file. Then run the `demuxOne.sh` in demuxlet and fastdemux folders.  
