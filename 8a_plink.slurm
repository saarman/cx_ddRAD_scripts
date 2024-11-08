#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-in_file="stacks"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load Module
module load plink

# Input and output
out_path="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/populations_output_2"
popmap="/project/piru_hylaues/KochProjects/alkalibeepopgen/popmap2/nomia_dummy_plate2"
in_path="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/refmap_output13"
in_file="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/populations_output_2/populations.snps"

# Code

#Filter out SNPs with missingness above thresholds, but keep all individuals for now.

#PLINK to convert VCF to PLINK:
plink --vcf ${in_file}.vcf --double-id --allow-extra-chr --make-bed --out $in_file
plink --bfile ${in_file} --double-id --allow-extra-chr --recode tab --out $in_file

#PLINK to filter by missing data, note this threshold is how much MISSING data is allowed, not how COMPLETE it needs to be (as it is with STACKS)
cp /dev/null $in_file.missing.log
plink --file ${in_file} --geno .7 --double-id --allow-extra-chr --recode --out ${in_file}_geno70           >> ${in_file}.missing.log
plink --file ${in_file}_geno70 --mind .7 --double-id --allow-extra-chr --recode --out ${in_file}_mind70    >> ${in_file}.missing.log
plink --file ${in_file}_mind70 --geno .65 --double-id --allow-extra-chr --recode --out ${in_file}_geno65    >> ${in_file}.missing.log
plink --file ${in_file}_geno65 --mind .65 --double-id --allow-extra-chr --recode --out ${in_file}_mind65    >> ${in_file}.missing.log
plink --file ${in_file}_mind65 --geno .6 --double-id --allow-extra-chr --recode --out ${in_file}_geno60    >> ${in_file}.missing.log
plink --file ${in_file}_geno60 --mind .6 --double-id --allow-extra-chr --recode --out ${in_file}_mind60    >> ${in_file}.missing.log
plink --file ${in_file}_mind60 --geno .55 --double-id --allow-extra-chr --recode --out ${in_file}_geno55    >> ${in_file}.missing.log
plink --file ${in_file}_geno55 --mind .55 --double-id --allow-extra-chr --recode --out ${in_file}_mind55    >> ${in_file}.missing.log
plink --file ${in_file}_mind55 --geno .5 --double-id --allow-extra-chr --recode --out ${in_file}_geno50    >> ${in_file}.missing.log
plink --file ${in_file}_geno50 --mind .5 --double-id --allow-extra-chr --recode --out ${in_file}_mind50    >> ${in_file}.missing.log
plink --file ${in_file}_mind50 --missing 

#Extract sites from those that passed missing filters:
cat ${in_file}_mind50.map | awk '{print $1 "\t" $4}' > ${in_file}_mind50.pos
vcftools --vcf ${in_file}.vcf \
--positions ${in_file}_mind50.pos \
--recode --out ${in_file}_filtered

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
