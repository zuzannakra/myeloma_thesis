# myeloma_thesis

This repository contains scripts used during MSc project on differential enhancer usage in multiple myeloma. This provides a record of file processing and performed analysis, although the analysis was not limited to the scripts provided here and these constitute the scripts most vital for the project.

The directory `mapping_scripts` contains shell scripts used to map sequencing data (ChIP-seq and ATAC-seq).

The directory `enhancer_calling` contains R scripts used to call enhancers in cell lines and in patients.

The directory `R_scripts` contains R scripts used for any other analysis such as, but not limited to, DiffBind, EdgeR, enhancer identification in patients, and data visualization.

## Dependency Installation

Dependencies are listed in the `rnaseq.yml` file, which can be used to build a conda environment:

```bash
conda env create -f rnaseq.yml
```

## Running shell scripts

The scripts can be run as long as fastq files are placed in the working directory. Path to `blacklist`, `hg38` and url for BigWigs should be adjusted prior to execution of each script. 

## Enhancer calling pipeline

Enhancer calling in this work was performed on unpublished cell line data (generated in the Crump lab) therefore the data is not available. However, the pipeline will accept for input any `H3K27ac peak file` and `ATAC-seq peak file` as long as they contain only "PeakID", "chr", "start" and "end" columns. Relevant `TT-seq` or `RNA-seq` data is required and columns shouls be adjusted to match "chrom", "strand", "txStart", "txEnd", "name2". The pipeline also required annotations performed with Homer (included in the dependencies). 

## Other R scripts
All remaining R scripts can be run locally with exception of diffbind and correlation analyses which were run on HPC cluster due to increased computing power requirements. These scripts are provided as R scripts as opposed to Rmd scripts which can be run locally. Each script requires data with different specifications and therefore might not be reproducible on any dataset format given. Nevertheless, all scripts provide an insight into the performed analysis with relevant functions and data visualisation tools. 

