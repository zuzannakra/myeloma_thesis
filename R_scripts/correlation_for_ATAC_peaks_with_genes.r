#Load the libraries
library(tidyverse)

#Read in the data for ATAC peaks that overlap with enhancers 
ATAC <- read_tsv("/rds/general/user/zwk22/home/diffbind_analysis/Ju_20_diffbind_ATAC_peaks_overlapping_enhancers.txt")

#Make a list of all ATAC peak IDs
ATAC_peaks <- ATAC %>%
select(peakID) 

#Read in the RNA-seq data
RNA <- read_tsv("/rds/general/user/zwk22/home/data/Ju_20_RNAseq_data_shortened.txt")


#Make a list to store the output of the loop 
RNA_ATAC_correlation <- list()

#Run a loop that will produce a data frame with correlation coefficients between gene expression values and ATAC tag values for each ATAC peak. 
#The gene expression values are for each gene assigned to each enhancer that overlaps with the ATAC peak. 

data_frame <- data.frame(geneid = c("x"), peakID = c("x"), correlation = c("x"), p_value = c("x")) %>% 
    filter(peakID != "x")

write_tsv(data_frame, "Tag_ATAC_gene_expression_correlations_all_enhancer_peaks.txt")

for (i in 1:dim(ATAC_peaks)[1]) {
  
  ATAC_peak <- ATAC_peaks$peakID[i]
  ATAC_tag_values <- ATAC %>%
    filter(peakID == ATAC_peak) %>%
    select(5:19) %>%
    unique() %>%
    t() %>%
    as.data.frame() %>%
    set_names("tag") %>%
    rownames_to_column("Patient") 
  
  associated_gene <- ATAC %>%
    filter(peakID == ATAC_peak) 
  gene <- associated_gene$Geneid[1]
  
  gene_expression <- RNA %>%
    filter(Geneid == gene) %>%
    select(2:16) %>%
    unique() %>%
    slice_max(rowSums(.)) %>%
    t() %>%
    as.data.frame() %>%
    set_names("expression") %>%
    rownames_to_column("Patient") 
  
  joined_list <- full_join(ATAC_tag_values, gene_expression, by = "Patient")
    
  
  correlation <- cor.test(joined_list$tag, joined_list$expression, method = "spearman")
  
  RNA_ATAC_correlation <- data.frame(geneid = gene, peakID = ATAC_peak, correlation = correlation$estimate, p_value = correlation$p.value)

  write_tsv(RNA_ATAC_correlation, "Tag_ATAC_gene_expression_correlations_all_enhancer_peaks.txt", append = TRUE)
}

#correlations_combined <- purrr::reduce(RNA_ATAC_correlation, rbind)

#write_tsv(correlations_combined, "Tag_ATAC_gene_expression_correlations_all_enhancer_peaks.txt")