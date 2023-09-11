# # Using HAIL to get out GeneBass Results
#
# This file covers some of the most basic usage fo HAIL. For most instances, it will be easier for people to use HAIL to extract results in matrix table format (.mt) and then output it to an easier to use and faster format, such as a .tsv.
#
# ## What is HAIL
# HAIL is software designed to unify a wide range of input formats (eg .vcf, .bgen, .tsv, .bed or plink files) and support scalable queries for genetic data.
#
# Although other tools are available, HAIL is currently being used with some more major datasets:
# - UKBioBank
# - gnomAD
# - [GeneBass](https://app.genebass.org)
#
# Particularly, many large public summary datasets such as GeneBass or gnomAD provide downloadable results in the form of HAIL matrixtables.
#
# ## How to download the GeneBass results
# **Please note: this is a big file (~800GB), so only do this if the data hasn't already been downloaded to your server**
#
# GeneBass is currently available through Google Cloud Storage (.gs). To download the data without an account there is a useful package available to do this. The one that currently works for me is `gsutil=5.15`.
#
# I recommend using a separate conda environment for this (there is a conda .yml available int his folder), as it seems to break things when installed with other packages.
#
# `conda env create -f gsutil.yml`
#
# HAIL is easier and the latest version can be installed through pip.

# +
# The first step is to import HAIL and initialise it
import hail as hl
# When initialising HAIL, there are some settings that can be played around with
# If you don't want to play around with any settings, there are defaults provided
# hl.init()

# We can assign more informative temporary file names for intermediary data HAIL might require
# This can make recording what you've done as well as deleting unnecessary file easier
TMP_FILE = 'my_tmp_file.txt'
TMP_DIR = 'mytmp_dir'
LOG_FILE = 'mylog.log'

# HAIL uses a pyspark cluster, so values can be set in the same way
# From testing, I found the following to work well for teh GeneBass data on the server
# For this, I've tried to use only a small amount of memory, a larger overhead may be needed for larger file extraction
LOCAL_CORES = 2
CONFIG = {'spark.driver.memory': '2g',
          'spark.driver.cores': '1',
          'spark.executor.memory':'5g',
          'spark.executor.cores':'4'}

hl.init(log=LOG_FILE, tmp_dir=TMP_DIR, local=f'local{LOCAL_CORES}', spark_conf=CONFIG)
# -

# ## Importing the Data
# We can use the function `hl.read_matrix_table()` to get our results.
# Please note, the 'results.mt' is actually a folder which HAIL uses to reference the data.
# It is not a single file.

# +
# We import the data simply using hl.read_matrix_table()
# Note: The matrix table is actually a folder ending with .mt
# This should be very fast, as it doesn't actually read in the file
# It creates a pointer for when we want to extract data
genebass = hl.read_matrix_table('/slade/projects/Public_GWAS_summary_stats/GeneBass/results.mt')

# We can then descript our dataset to get a better idea of what's inside it
genebass.describe()
# -

# We might want to see what unique variables there are in a particular row/col
# For this, we can select the row/column from the object (eg df.column)
# And then use the .collect() function
genebass.description.collect()

# We most likely want to filter the data before extracting it
# Data filteation will speed up changing the data to pandas, but
# doesn't speed up things like viewing the dataframe
# When we filter rows, we make a new object each time, similar to R
# HAIL does not support chaining functions like pandas
df = genebass.filter_rows(genebass.gene_symbol=='IGF1R')
# Key rows/columns are always left and cannot be added to the selection
df = df.select_rows()
df = df.select_cols('description','description_more','coding_description','category')
df = df.select_entries('Pvalue','Pvalue_Burden','Pvalue_SKAT','BETA_Burden','SE_Burden')
# Filtering on multiple things at once
df = df.filter_entries((df['Pvalue'] < 5*10**-7) | (df.Pvalue_Burden < 5*10**-7) | (df['Pvalue_SKAT'] < 5*10**-7))

# We may want to take a quick look at the dataframe we created
# We can do this using .head() or .show()
df.head(10)
df.show()

# We can then convert our dataframe to pandas like so
df_pd = df.entries().to_pandas()
