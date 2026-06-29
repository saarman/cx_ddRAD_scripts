#!/bin/bash
#SBATCH --job-name=bcftools_ABfilter
#SBATCH --output=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/8b_bcftools_ABfilter_%j.out
#SBATCH --error=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/8b_bcftools_ABfilter_%j.err
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --account=saarman-np
#SBATCH --partition=saarman-shared-np
#SBATCH --mail-user=emily.calhoun@usu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load bcftools

# --- Paths ---
IN_VCF="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/ddrad_filtered.vcf"
OUTDIR="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered"
OUT_FINAL="${OUTDIR}/ddrad_final.vcf.gz"

mkdir -p ${OUTDIR}

# ============================================================
# FILTER RATIONALE (matching original 8bfinal logic, simplified)
#
# QUAL >= 30 & DP 10-100 : matches Norah's original thresholds
#                           DP cap of 100 removes likely paralogous
#                           loci with artificially high coverage
#
# Biallelic SNPs only     : indels excluded for population genomics
#                           (PCA, FST, ADMIXTURE all expect SNPs)
#
# MAF >= 0.01             : matches original; removes near-fixed loci
#
# AB 0.3-0.7              : matches Norah's original threshold exactly
#                           (original used 0.3/0.7, not 0.2/0.8)
#                           Applied per-genotype for het calls only
#
# Note: original script ran two rounds of AB filtering (per-genotype
# in step 2 AND per-SNP average in step 6). We apply it once
# per-genotype which is the more standard approach.
# ============================================================

echo "Starting bcftools AB filter..."
echo "Input: ${IN_VCF}"
echo "$(date)"

# Step 1: Compress and index
bcftools view -O z -o ${IN_VCF}.gz ${IN_VCF}
bcftools index ${IN_VCF}.gz

# Step 2: QUAL, DP, biallelic SNP filter
bcftools view -m2 -M2 -v snps ${IN_VCF}.gz -Ou | \
bcftools filter \
    -i 'QUAL >= 30 & INFO/DP >= 10 & INFO/DP <= 100' \
    -Ou | \
bcftools +fill-tags -- -t MAF | \
bcftools filter \
    -i 'INFO/MAF >= 0.01' \
    -O z -o ${OUTDIR}/ddrad_qualDP_filtered.vcf.gz

bcftools index ${OUTDIR}/ddrad_qualDP_filtered.vcf.gz

# Step 3: Soft-tag het calls with bad allele balance (0.3-0.7 matches original)
bcftools filter \
    --soft-filter ABfilter \
    --exclude 'GT=="het" && (AD[0]/(AD[0]+AD[1]) < 0.3 || AD[0]/(AD[0]+AD[1]) > 0.7)' \
    -O z \
    -o ${OUTDIR}/ddrad_ABtagged.vcf.gz \
    ${OUTDIR}/ddrad_qualDP_filtered.vcf.gz

bcftools index ${OUTDIR}/ddrad_ABtagged.vcf.gz

# Step 4: Keep only PASS sites
bcftools view \
    -f PASS \
    -O z \
    -o ${OUT_FINAL} \
    ${OUTDIR}/ddrad_ABtagged.vcf.gz

bcftools index ${OUT_FINAL}

echo ""
echo "=== FINAL DATASET SUMMARY ==="
NSNP=$(bcftools view -H ${OUT_FINAL} | wc -l)
NIND=$(bcftools query -l ${OUT_FINAL} | wc -l)
echo "Final SNPs:        ${NSNP}"
echo "Final individuals: ${NIND}"
echo "$(date)"
echo "=============================="
