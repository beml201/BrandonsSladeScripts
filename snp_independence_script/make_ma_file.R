args <- commandArgs(trailingOnly=TRUE)
csv_in <- args[1]
output_prefix <- args[2]

## Read in csv files
format.to.ma <- function(csv_file,
                         output_prefix,
                         chr_col='CHR',
                         snp_col='SNP',
                         effect_allele_col='A1',
                         other_allele_col='A2',
                         freq_col='AF1',
                         beta_col='Beta',
                         se_col='SE',
                         p_value_col='P',
                         N_col='N'){
    
  df <- read.csv(csv_file)
  ## Set column names to standardise with .ma files
  df <- df[,c(chr_col,
              snp_col,
              effect_allele_col,
              other_allele_col,
              freq_col,
              beta_col,
              se_col,
              p_value_col,
              N_col)]
  names(df) <- c('CHR','SNP','A1','A2','freq','b','se','p','N')
  
  chrs <- unique(df$CHR)
  for(i in chrs){
    df_out <- subset(df, CHR==i)
    df_out <- df_out[,-1]
    write.table(df_out, file=paste0(output_prefix,'_chr',i,'.ma'), row.names = F, quote = F)
  }
}

format.to.ma(csv_in, output_prefix)
