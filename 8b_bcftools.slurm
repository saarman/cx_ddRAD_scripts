#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=336:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20          # same as $max set in ForkManager
#SBATCH --account=saarman-np
#SBATCH --partition=saarman-shared-np   
#SBATCH --job-name=bwa-mem2
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=emily.calhoun@usu.edu

# LOAD MODULES, BCFtools (in place of vcftools)
module load bcftools

# INPUT and OUTPUT
in_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered.recode.vcf"
out_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered_snps_indels.vcf"

# PERMISSIONS
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD*

# TIMESTAMP
now=$(date +"%T")
echo "Start time : $now"

# CODE
# Step 1: Retain both SNPs and indels, filter by QUAL and DP
bcftools view -v snps,indels ${in_file} -Ou | \
bcftools filter \
  -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' -Ou | \

# Step 2: Filter biallelic SNPs for allele balance (AB) and minor allele frequency (MAF)
bcftools view \
  -m2 -M2 -v snps -Ou | \
bcftools +fill-tags -Ou -- -t MAF | \
bcftools filter \
  -i 'INFO/MAF >= 0.01 & FORMAT/AB > 0.3 & FORMAT/AB < 0.7' -Ou | \

# Step 3: Retain indels without further filtering
bcftools view -v indels input.vcf -Ou | \

# Step 4: Combine filtered SNPs and indels
bcftools concat -a -o ${out_file}


# TIMESTAMP
now=$(date +"%T")
echo "Start time : $now"
