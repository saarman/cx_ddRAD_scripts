#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=336:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20          # same as $max set in ForkManager
#SBATCH --account=saarman-np
#SBATCH --partition=saarman-shared-np   
#SBATCH --job-name=bcftools
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=emily.calhoun@usu.edu

# LOAD MODULES, BCFtools (in place of vcftools)
module load bcftools

# INPUT and OUTPUT
in_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_combined2-3_g70m70g50_filtered.recode.vcf"
out_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_combined2-3_g70m70g50_filteredstep8b.vcf"

# PERMISSIONS
# chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD*

# TIMESTAMP
echo "Start time : $(date +%T)"

# Step 1. Filter by QUAL and DP
echo "Filtering by QUAL and DP..."
bcftools filter -i 'QUAL >= 30 && INFO/DP >= 10 && INFO/DP <= 100' -Ov ${in_file} -o step1_qd.vcf

# Step 2. Keep only biallelic SNPs, fill MAF, filter on MAF >= 0.01
echo "Filtering SNPs for MAF..."
bcftools view -v snps -m2 -M2 step1_qd.vcf -Ou | \
bcftools +fill-tags -Ou -- -t MAF | \
bcftools filter -i 'INFO/MAF >= 0.01' -Ov -o step2_snps.vcf

# Step 3. Extract indels
echo "Extracting indels..."
bcftools view -v indels step1_qd.vcf -Ov -o step3_indels.vcf

# Step 4. Concatenate SNPs and indels
echo "Concatenating filtered SNPs and indels..."
bcftools concat -a step2_snps.vcf step3_indels.vcf -Ov -o ${out_file}

echo "Filtering complete."
echo "Output written to: ${out_file}"
echo "End time : $(date +%T)"
