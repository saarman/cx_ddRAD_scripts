#!/bin/bash
#SBATCH --job-name=bcftools_ABfilter
#SBATCH --output=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/8b_bcftools_ABfilter_%j.out
#SBATCH --error=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/8b_bcftools_ABfilter_%j.err
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --account=saarman-np
#SBATCH --partition=saarman-np
#SBATCH --mail-user=emily.calhoun@usu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load bcftools

# --- Paths ---
IN_VCF="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/cx_ddRAD_combined2-3_g70m70g60_filtered.recode.vcf"
OUTDIR="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered"
OUT_FINAL="${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_ABfiltered.vcf.gz"

mkdir -p ${OUTDIR}

echo "Starting bcftools AB filter..."
echo "Input: ${IN_VCF}"
echo "$(date)"

# Step 0: Sort, then compress and index (vcftools output isn't guaranteed sorted)
bcftools sort ${IN_VCF} -O z -o ${IN_VCF}.gz
bcftools index ${IN_VCF}.gz

# Step 2: QUAL, DP, biallelic SNP, MAF filter
bcftools view -m2 -M2 -v snps ${IN_VCF}.gz -Ou | \
bcftools filter \
    -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' \
    -Ou | \
bcftools +fill-tags -- -t MAF | \
bcftools filter \
    -i 'INFO/MAF >= 0.01' \
    -O z -o ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_qualDP.vcf.gz

bcftools index ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_qualDP.vcf.gz

# Step 3: Soft-tag het calls with bad allele balance (explicit FORMAT/AD to resolve ambiguity)
bcftools filter \
    --soft-filter ABfilter \
    --exclude 'GT=="het" && (FORMAT/AD[0]/(FORMAT/AD[0]+FORMAT/AD[1]) < 0.3 || FORMAT/AD[0]/(FORMAT/AD[0]+FORMAT/AD[1]) > 0.7)' \
    -O z \
    -o ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_ABtagged.vcf.gz \
    ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_qualDP.vcf.gz

bcftools index ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_ABtagged.vcf.gz

# Step 4: Keep only PASS sites
bcftools view \
    -f PASS \
    -O z \
    -o ${OUT_FINAL} \
    ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_ABtagged.vcf.gz

bcftools index ${OUT_FINAL}

echo ""
echo "=== FINAL DATASET SUMMARY ==="
NSNP=$(bcftools view -H ${OUT_FINAL} | wc -l)
NIND=$(bcftools query -l ${OUT_FINAL} | wc -l)
echo "Final SNPs:        ${NSNP}"
echo "Final individuals: ${NIND}"
echo "$(date)"
echo "=============================="
echo ""
echo "Final dataset: ${OUT_FINAL}"
echo "Ready for PCA and downstream population genomics in R"
