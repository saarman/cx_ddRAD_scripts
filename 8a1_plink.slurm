#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --partition=saarman-shared-np   
#SBATCH --account=saarman-np
#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --mem=24576 # memory given in MB
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=16   # 20 processor core(s) per node X 2 threads per core
#SBATCH --job-name="stacks"
#SBATCH --mail-user=emily.calhoun@usu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load Module
module load plink
module load vcftools

# Input and output
in_path="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_populations_output"
in_file="populations.snps"
out_path="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/"
popmap="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_scripts/cx_dummyplate2_filtered.txt"


# Code

#MOVE to output directory 
cd ${out_path}

#PLINK to convert VCF to PLINK:
plink --vcf ${in_path}/${in_file}.vcf --double-id --allow-extra-chr --make-bed --out ./${in_file}
plink --bfile ./${in_file} --double-id --allow-extra-chr --recode tab --out ./${in_file}

MEDIUM FILTER FOR EVERYTHING
#PLINK to filter by missing data, note this threshold is how much MISSING data is allowed, not how COMPLETE it needs to be (as it is with STACKS)
cp /dev/null ${in_file}_g70m70g60m60g50m50_plink_log.txt
plink --file ${in_file} --geno .7 --double-id --allow-extra-chr --recode --out ${in_file}_g70        >> ${in_file}_g70m70g60m60g50m50_plink_log.txt
plink --file ${in_file}_g70 --mind .7 --double-id --allow-extra-chr --recode --out ${in_file}_m70    >> ${in_file}_g70m70g60m60g50m50_plink_log.txt
plink --file ${in_file}_m70 --geno .6 --double-id --allow-extra-chr --recode --out ${in_file}_g60    >> ${in_file}_g70m70g60m60g50m50_plink_log.txt
plink --file ${in_file}_g60 --mind .6 --double-id --allow-extra-chr --recode --out ${in_file}_m60    >> ${in_file}_g70m70g60m60g50m50_plink_log.txt
plink --file ${in_file}_m60 --geno .5 --double-id --allow-extra-chr --recode --out ${in_file}_g50    >> ${in_file}_g70m70g60m60g50m50_plink_log.txt
plink --file ${in_file}_g50 --mind .5 --double-id --allow-extra-chr --recode --out ${in_file}_g70m70g60m60g50m50    >> ${in_file}_g70m70g60m60g50m50_plink_log.txt
plink --file ${in_file}_g70m70g60m60g50m50 --missing 

# MED FILTER FOR GENO, SOFT FILTER FOR MIND
#PLINK to filter by missing data with SOFT filter for mind, note this threshold is how much MISSING data is allowed, not how COMPLETE it needs to be (as it is with STACKS)
cp /dev/null ${in_file}_g70m70g50_plink_log.txt
plink --file ${in_file} --geno .7 --double-id --allow-extra-chr --recode --out ${in_file}_g70           >> ${in_file}_g70m70g50_plink_log.txt
plink --file ${in_file}_g70 --mind .7 --double-id --allow-extra-chr --recode --out ${in_file}_g70m70    >> ${in_file}_g70m70g50_plink_log.txt
plink --file ${in_file}_g70m70 --geno .5 --double-id --allow-extra-chr --recode --out ${in_file}_g70m70g50    >> ${in_file}_g70m70g50_plink_log.txt
plink --file ${in_file}_g70m70g50  --missing 

# HARD FILTER FOR GENO, SOFT FILTER FOR MIND 
#PLINK to filter by missing data with HARD filter for geno and SOFT filter for mind, note this threshold is how much MISSING data is allowed, not how COMPLETE it needs to be (as it is with STACKS)
cp /dev/null ${in_file}_g70m70g20_plink_log.txt
plink --file ${in_file} --geno .7 --double-id --allow-extra-chr --recode --out ${in_file}_g70           >> ${in_file}_g70m70g20_plink_log.txt
plink --file ${in_file}_g70 --mind .7 --double-id --allow-extra-chr --recode --out ${in_file}_g70m70    >> ${in_file}_g70m70g20_plink_log.txt
plink --file ${in_file}_g70m70 --geno .2 --double-id --allow-extra-chr --recode --out ${in_file}_g70m70g20    >> ${in_file}_g70m70g20_plink_log.txt
plink --file ${in_file}_g70m70g20  --missing 







# Code usage

# Missing rate per SNP
# Subsequent analyses can be set to automatically exclude SNPs on the basis of missing genotype rate, with the --geno option: the default is to include all SNPS (i.e. --geno 1). To include only SNPs with a 90% genotyping rate (10% missing) use
# plink --file mydata --geno 0.1
# As with the --maf option, these counts are calculated after removing individuals with high missing genotype rates.

# Missing rate per person
# The initial step in all data analysis is to exclude individuals with too much missing genotype data. This option is set as follows:
# plink --file mydata --mind 0.1
# which means exclude with more than 10% missing genotypes (this is the defalt value). A line in the terminal output will appear, indicating how many individuals were removed due to low genotyping. If any individuals were removed, a file called
#      plink.irem     
# will be created, listing the Family and Individual IDs of these removed individuals. Any subsequent analysis also specifeid on the same command line will be performed without these individuals.
# One might instead wish to create a new PED file with these individuals permanently removed, simply add an option to generate a new fileset: for example,
# plink --file data --mind 0.1 --recode --out cleaned
# will generate files
#      cleaned.ped
#      cleaned.map
# with the high-missing-rate individuals removed; alternatively, to create a binary fileset with these individuals removed:
# plink --file data --mind 0.1 --make-bed --out cleaned
# which results in the files
#      cleaned.bed
#      cleaned.bim
#      cleaned.fam
# HINT You can specify that certain genotypes were never attempted, i.e. that they are obligatory missing, and these will be handled appropriately by these genotyping rate filters. See the summary statistics page for more details.
# 

# Missing genotypes
# To generate a list genotyping/missingness rate statistics:
# plink --file data --missing
# This option creates two files:
#      plink.imiss
#      plink.lmiss 
# which detail missingness by individual and by SNP (locus), respectively. For individuals, the format is:
#      FID                Family ID
#      IID                Individual ID
#      MISS_PHENO         Missing phenotype? (Y/N)
#      N_MISS             Number of missing SNPs
#      N_GENO             Number of non-obligatory missing genotypes
#      F_MISS             Proportion of missing SNPs
# For each SNP, the format is:
#      SNP                SNP identifier
#      CHR                Chromosome number
#      N_MISS             Number of individuals missing this SNP
#      N_GENO             Number of non-obligatory missing genotypes
#      F_MISS             Proportion of sample missing for this SNP
# HINT To test for case/control differences in missingness, see the --test-missing option.
# HINT To produce summary of missingness that is stratified by a categorical cluster variable, use the --within filename option as well as --missing. In this way, the missing rates will be given separately for each level of the categorical variable. For example, the categorical variable could be which plate that sample was on in the genotyping. Details on the format of a cluster file can be found here.
#
