#!/bin/bash

#SBATCH --time=336:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20          
#SBATCH --account=saarman-np
#SBATCH --partition=saarman-shared-np   
#SBATCH --job-name=bcftools
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=emily.calhoun@usu.edu

# LOAD MODULES
module load bcftools

# INPUT and OUTPUT FILES
in_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered.recode.vcf"
out_file="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered_snps_indels.vcf"
snp_data="snp_data.txt"
filtered_snps="filtered_snps.tsv"
snps_to_keep="snps_to_keep.txt"
final_filtered="final_filtered.vcf"

# Temporary files for SNPs and indels
temp_snps="temp_filtered_snps.vcf"
temp_indels="temp_filtered_indels.vcf"

# TIMESTAMP
now=$(date +"%T")
echo "Start time : $now"

# Step 1: Retain both SNPs and indels, filter by QUAL and DP
bcftools view -v snps,indels ${in_file} -Ou | \
bcftools filter -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' -Ov -o ${temp_snps}

# Verify SNP filtering output
if [ ! -s ${temp_snps} ]; then
    echo "Error: ${temp_snps} is empty! Exiting."
    exit 1
fi

# Step 2: Filter biallelic SNPs by allele balance (AB) and minor allele frequency (MAF)
bcftools view -m2 -M2 -v snps ${temp_snps} -Ou | \
bcftools +fill-tags -Ou -- -t MAF | \
bcftools filter -i 'INFO/MAF >= 0.01 & FORMAT/AD[1]/(FORMAT/AD[0]+FORMAT/AD[1]) > 0.3 & FORMAT/AD[1]/(FORMAT/AD[0]+FORMAT/AD[1]) < 0.7 & GT=="0/1"' -Ov -o ${temp_snps}

# Verify SNP filtering output again
if [ ! -s ${temp_snps} ]; then
    echo "Error: ${temp_snps} is empty after filtering! Exiting."
    exit 1
fi

# Step 3: Retain indels without further filtering
bcftools view -v indels ${in_file} -Ov -o ${temp_indels}

# Verify indels output
if [ ! -s ${temp_indels} ]; then
    echo "Error: ${temp_indels} is empty! Exiting."
    exit 1
fi

# Step 4: Combine filtered SNPs and indels into a single file
bcftools concat -a -o ${out_file} ${temp_snps} ${temp_indels}

# Verify final output
if [ ! -s ${out_file} ]; then
    echo "Error: ${out_file} was not created! Exiting."
    exit 1
fi

# Step 5: Extract Genotype (GT) and Allelic Depth (AD) Fields for SNPs
bcftools query -f '%CHROM\t%POS\t%ID\t[%GT\t%AD\t]\n' ${in_file} > ${snp_data}

# Step 6: Calculate Average Allele Balance for Each SNP
awk '
BEGIN { OFS="\t" }
{
    chrom=$1; pos=$2; id=$3;
    sum_ab = 0; count_het = 0;

    for (i=4; i<=NF; i+=2) {
        gt = $(i); ad = $(i+1);
        split(ad, depths, ",");

        if (gt == "0/1" || gt == "1/0") {  # Check if heterozygous
            if (depths[1] + depths[2] > 0) {  # Avoid division by zero
                ab = depths[2] / (depths[1] + depths[2]);
                sum_ab += ab;
                count_het++;
            }
        }
    }

    if (count_het > 0) {
        avg_ab = sum_ab / count_het;
        if (avg_ab >= 0.3 && avg_ab <= 0.7) {  # Apply filtering threshold
            print chrom, pos, id, avg_ab;
        }
    }
}' ${snp_data} > ${filtered_snps}

# Step 7: Create a List of SNPs to Retain
cut -f1,2 ${filtered_snps} > ${snps_to_keep}

# Step 8: Filter VCF to Retain Only the Selected SNPs
bcftools view -T ${snps_to_keep} ${in_file} -o ${final_filtered}

# Clean up temp files
rm ${temp_snps} ${temp_indels}

# TIMESTAMP
now=$(date +"%T")
echo "Pipeline completed successfully"
echo "End time : $now"


