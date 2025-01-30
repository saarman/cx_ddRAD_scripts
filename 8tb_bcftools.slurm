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

# LOAD MODULES
module load bcftools

# INPUT and OUTPUT
in_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered.recode.vcf"
out_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered_snps_indels.vcf"

# TIMESTAMP
now=$(date +"%T")
echo "Start time : $now"

# DEBUG: Check if input file exists
if [[ ! -f "$in_file" ]]; then
    echo "Error: Input VCF file not found!"
    exit 1
fi

# STEP 1: Retain SNPs & indels, filter by QUAL and DP
bcftools view -v snps,indels ${in_file} -Ou > step1.vcf

# STEP 2: Filter by quality and depth
bcftools filter -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' step1.vcf -Ou > step2.vcf

# STEP 3: Filter biallelic SNPs, add minor allele frequency (MAF)
bcftools view -m2 -M2 -v snps -Ou step2.vcf | \
bcftools +fill-tags -Ou -- -t MAF > step3.vcf

# STEP 4: Filter heterozygotes (GT field)
bcftools filter -i 'GT~"0/1" | GT~"1/0" | GT~"0|1" | GT~"1|0"' step3.vcf -Ov > step4.vcf

# DEBUG: Check if filtering removed all variants
if [[ ! -s step4.vcf ]]; then
    echo "Error: No variants remain after heterozygote filtering!"
    exit 1
fi

# STEP 5: Retain indels separately
bcftools view -v indels ${in_file} -Ou > indels.vcf

# STEP 6: Concatenate SNPs and indels into final output file
bcftools concat -a -O v -o ${out_file} step4.vcf indels.vcf

# FINAL CHECK: Confirm output file exists
if [[ -s ${out_file} ]]; then
    echo "Pipeline completed successfully. Output: ${out_file}"
else
    echo "Error: Output file was not created!"
    exit 1
fi

# TIMESTAMP
now=$(date +"%T")
echo "End time : $now"

