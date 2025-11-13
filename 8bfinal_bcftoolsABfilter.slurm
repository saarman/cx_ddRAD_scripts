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

# LOAD MODULES
module load bcftools

# INPUT and OUTPUT
filter_include="g70m70g20"             # NOTE: This is where you choose which filtered output from geno/mind/plink you will use going forward
plate_name="cx_ddRAD_combined2-3"      # NOTE: This is where you choose which plate/root name of file
in_file="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/${plate_name}_${filter_include}_filtered.recode.recode.vcf"
out_file="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/${plate_name}_${filter_include}_ABfiltered.vcf"

# TEMPORARY FILES
snp_data="snp_data.txt"
filtered_snps="filtered_snps.tsv"
snps_to_keep="snps_to_keep.txt"
temp_file="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/tempfile_snps_indels.vcf"

# PERMISSIONS
chmod -R g+w /uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD*

# TIMESTAMP
now=$(date +"%T")
echo "Start time : $now"

# Step 1: Retain both SNPs and indels, filter by QUAL and DP
bcftools view -v snps,indels ${in_file} -Ou | \
bcftools filter -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' -Ou | \

# Step 2: Filter biallelic SNPs by allele balance (AB) and minor allele frequency (MAF)
bcftools view -m2 -M2 -v snps -Ou | \
bcftools +fill-tags -Ou -- -t MAF | \
bcftools filter -i 'INFO/MAF >= 0.01 & FORMAT/AD[1]/(FORMAT/AD[0]+FORMAT/AD[1]) > 0.3 & FORMAT/AD[1]/(FORMAT/AD[0]+FORMAT/AD[1]) < 0.7 & GT=="0/1"' -Ou | \

# Step 3: Retain indels without further filtering
bcftools view -v indels ${in_file} -Ou | \

# Step 4: Combine filtered SNPs and indels into a single file
bcftools concat -a -o ${temp_file}

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
bcftools view -T ${snps_to_keep} ${in_file} -o ${out_file}

# Step 9: Remove temp file
rm ${temp_file}

# PERMISSIONS
chmod -R g+w /uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD*

# TIMESTAMP
now=$(date +"%T")
echo "BCFtools pipeline, including AB filter, completed successfully."
echo "End time : $now"
