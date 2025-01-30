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

module load bcftools
module load htslib   # Ensure bgzip and tabix are available

# INPUT and OUTPUT FILES
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

# STEP 1: Retain SNPs & Indels, filter by QUAL and DP
bcftools view -v snps,indels ${in_file} -Ou | \
bcftools filter -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' -Ou > step1.vcf

# STEP 2: Filter Biallelic SNPs, Add Minor Allele Frequency (MAF)
bcftools view -m2 -M2 -v snps -Ou step1.vcf | \
bcftools +fill-tags -Ou -- -t MAF > step2.vcf

# STEP 3: Filter heterozygotes (GT field)
bcftools filter -i 'GT~"0/1" | GT~"1/0" | GT~"0|1" | GT~"1|0"' step2.vcf -Ou > step3.vcf

# DEBUG: Check if filtering removed all variants
if [[ ! -s step3.vcf ]]; then
    echo "Error: No variants remain after heterozygote filtering!"
    exit 1
fi

# STEP 4: Retain Indels Separately (No further filtering)
bcftools view -v indels ${in_file} -Ou > indels.vcf

# STEP 5: Concatenate SNPs and Indels into Final Output File
bcftools concat -a -O v -o ${out_file} step3.vcf indels.vcf

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



