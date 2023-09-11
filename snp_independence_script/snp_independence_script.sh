#!/bin/bash
## -------------------------------##
# Script to check if SNPs are independent
# Uses the GCTA stepwise model selection to check for independence
# GCTA like to have a specific file input, .ma files
# The script additionally formats a csv to the appropriate .ma file
# The final check should be done manually as well, as it simply applies a threshodl for SNPs to remove

# Example file taken from Teumer et al GWAS of TSH: doi.org/10.1038/s41467-018-06356-1

## -----Parameters to Change -----##

# A tab delimited file of chr, pos, allele1, allele2
snps_to_check=example_file.csv

# A plink folder containing formatted reference chromosome-specific files
ref_folder=/projects/Ref_Datasets/1000_genomes

# The name of the output file
output_folder=outputs
mkdir $output_folder

## -------------------------------##

# Format the csv appropriately
Rscript make_ma_file.R ${snps_to_check} tmp

# Run GCTA cojo-slct
module load GCTA

for FILE in $(ls *.ma); do
    TMP=${FILE##*chr}
    CHR=${TMP%%.ma*}
        
    # Get the locations of the bed files
    BEDFILE=$(ls ${ref_folder}/*chr${CHR}.*.bed)
    BEDFILE=${BEDFILE%%.bed*}

    gcta64 --bfile ${BEDFILE} --chr ${CHR} --cojo-file ${FILE} --cojo-slct --out ${output_folder}/chr${CHR}
done

rm tmp_chr*.ma

Rscript cojo_check.R ${output_folder}