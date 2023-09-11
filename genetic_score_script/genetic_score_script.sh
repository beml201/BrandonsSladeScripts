#!/bin/bash
## -------------------------------##
# Script to generate genetic scores
# Change the parameters below to the appropriate file names
# Generates the extracted GRS results
# Additionally creates a snps_all file with the raw data in a human-readable format

## -----Parameters to Change -----##

# A tab delimited file of chr, pos, allele1, allele2
snps_to_extract=files/snps_to_extract.txt

# A tab delimited file containing the snp names, allele1, allele2 and the weighting (eg effect size)
snps_weights=file/snps_weights.txt

# The name of the output file
output_file=file/output.txt

## Script to make the GRS from the raw data. Available within the Exeter GoCT Team
PERL_SCRIPT=Dataset_Code/generate_GRS.pl

## Folder containing the raw bgen files
BGEN=/server/projects/Genetics/HRC_imputed

## -------------------------------##

## Load required modules
module load index_bgen/1.0-gompi-2020a

## Extract the required SNPs from the data
for i in {1..22}; do
    index_bgen -bgen ${BGEN}/chr${i}.bgen \
    -sample ${BGEN}/chr${i}.sample \
    -index-file ${BGEN}/chr${i}.bgen.index \
    -snps ${snps_to_extract} \
    -out snps_chr$i -chr $i
done

## Put all the data together (with effect of SNP in each column)
cut -f2- snps_chr2 > tmp
paste snps_chr1 tmp > tmp2
mv tmp2 snps_all

## This loops around all chromosomes that are there
for i in {3..22}; do
    if [ $(head -n 1 snps_chr$i | awk '{print NF}') != 1 ]; then
        cut -f2- snps_chr$i > tmp
        paste snps_all tmp > tmp2
        mv tmp2 snps_all
    fi
done

## Remove unnecessary files
rm snps_chr* tmp

## Run the GRS script
${PERL_SCRIPT} --weights ${snps_weights} --dosages snps_all --grs ${output_file}