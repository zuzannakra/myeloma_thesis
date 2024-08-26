library(DiffBind)
library(tidyverse)

# Read in sample metadata, skipping one row based on the metadata format, may not be necessary
samples <- read.csv("file_name", skip = 1)
print("Samples loaded")

# Create DBA object
expData <- dba(sampleSheet = samples, scoreCol = 5)
print("DBA object created")

# Count reads
expData.sumOverlaps <- dba.count(expData, bUseSummarizeOverlaps = TRUE)
print("Counts calculated")

# Set up contrast, change categories to the desired option (eg DBA_TISSUE, DBA_CONDITION)
comp.sumOverlaps <- dba.contrast(expData.sumOverlaps, categories = DBA_TISSUE, minMembers = 2)
print("Contrasts set up")

# Perform differential analysis
DE <- dba.analyze(comp.sumOverlaps, bGreylist = FALSE, bBlacklist = FALSE)
print("Differential analysis performed")

# Show contrast numbers
contrast.numbers <- dba.show(DE, bContrasts = TRUE)
print(contrast.numbers)

# Debugging: Check the structure of DE object
print(str(DE))

# Create report
DE_report <- as.data.frame(dba.report(DE, method = DBA_DESEQ2, contrast = 1, th = 1, bUsePval = TRUE))
write_tsv(DE_report, "report_name")
print("Report generated")