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

# INPUT and OUTPUT
in_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered.recode.vcf"
out_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered_snps_indels.vcf"

# TIMESTAMP
now=$(date +"%T")
echo "Start time : $now"

# STEP 1: Retain SNPs & indels, filter by QUAL and DP
bcftools view -v snps,indels ${in_file} -Ou | \
bcftools filter -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' -Ou > step1.bcf

# STEP 2: Filter biallelic SNPs, add minor allele frequency (MAF)
bcftools view -m2 -M2 -v snps step1.bcf -Ou | \
bcftools +fill-tags -Ou -- -t MAF | \
bcftools filter -i 'INFO/MAF >= 0.01 & FORMAT/AD[0:1] > 0.3 & FORMAT/AD[0:1] < 0.7' -Ou > step4.vcf

# STEP 3: Retain indels separately
bcftools view -v indels step1.bcf -Ov -o indels.vcf

# STEP 4: Sort VCF files (necessary for bgzip and tabix)
bcftools sort step4.vcf -Ou > step4_sorted.vcf
bcftools sort indels.vcf -Ou > indels_sorted.vcf

# STEP 5: Compress and index VCFs
bgzip -c step4_sorted.vcf > step4_sorted.vcf.gz
tabix -p vcf step4_sorted.vcf.gz

bgzip -c indels_sorted.vcf > indels_sorted.vcf.gz
tabix -p vcf indels_sorted.vcf.gz

# STEP 6: Concatenate SNPs and indels into final output file
bcftools concat -a step4_sorted.vcf.gz indels_sorted.vcf.gz -O v -o ${out_file}

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



