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

# --- Step 1: Filter SNPs and indels by QUAL and DP ---
echo "Filtering by QUAL and DP..."
bcftools view -v snps,indels ${in_file} -Ou | \
bcftools filter -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' -Ov -o temp_qd.vcf

# --- Step 2: Filter SNPs for MAF and allele balance ---
echo "Filtering SNPs for MAF and allele balance..."
bcftools view -m2 -M2 -v snps temp_qd.vcf -Ou | \
bcftools +fill-tags -Ou -- -t MAF | \
bcftools filter -i 'INFO/MAF >= 0.01 & FORMAT/AD[1]/(FORMAT/AD[0]+FORMAT/AD[1]) > 0.3 & FORMAT/AD[1]/(FORMAT/AD[0]+FORMAT/AD[1]) < 0.7' -Ov -o temp_snps.vcf

# --- Step 3: Retain indels without further filtering ---
echo "Extracting indels..."
bcftools view -v indels temp_qd.vcf -Ov -o temp_indels.vcf

# --- Step 4: Combine filtered SNPs and indels ---
echo "Concatenating filtered SNPs and indels..."
bcftools concat -a temp_snps.vcf temp_indels.vcf -Ov -o ${out_file}

echo "Filtering complete."
echo "Output written to: ${out_file}"
echo "End time : $(date +%T)"
