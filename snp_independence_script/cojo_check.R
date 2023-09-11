args <- commandArgs(trailingOnly=TRUE)
folder_in <- args[1]

# eps is the standard deviation 
problem_SNPs <- function(folder_in, eps=1.0){
    file_list <- list.files(folder_in)
    cojos <- paste0(folder_in,'/',file_list[grep('.jma.cojo',file_list,fixed=T)])
    
    nothing_found <- TRUE
    for(file in cojos){
        df <- read.table(file, header=T)
        df$diff <- abs(df$b - df$bJ)
        df$std_diff <- df$diff/df$se
        problematic_snps <- subset(df, std_diff>eps)
        if(nrow(problematic_snps)>0){
            nothing_found <- FALSE
            print(paste('SNPs to look into from',file))
            for(snp in problematic_snps$SNP){
                print(snp)
            }}
    }
    if(nothing_found){
        print('No problematic SNPs highlighted')
    }
}

problem_SNPs(folder_in)