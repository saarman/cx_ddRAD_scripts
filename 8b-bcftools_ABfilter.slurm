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

# Step 0: Sort, compress, index
bcftools sort ${IN_VCF} -O z -o ${IN_VCF}.gz
bcftools index ${IN_VCF}.gz

# ============================================================
# UPDATED FILTER RATIONALE
# Stacks does not populate site-level QUAL or INFO/DP (both
# come back as missing "."). Switched to FORMAT-level fields
# which ARE populated:
#
# FORMAT/GQ >= 20  : genotype quality threshold per call
#                     (replaces QUAL >= 30; GQ20 = standard
#                     "good confidence" threshold)
# FORMAT/DP >= 3   : minimum read depth per genotype call
#                     (lenient since RAD coverage is naturally
#                     more variable than WGS; replaces DP 10-100)
# MAF >= 0.01      : unchanged, removes near-fixed loci
# AB 0.3-0.7       : unchanged, uses FORMAT/AD as before
# ============================================================

# Step 1: Biallelic SNPs, MAF filter
bcftools view -m2 -M2 -v snps ${IN_VCF}.gz -Ou | \
bcftools +fill-tags -- -t MAF | \
bcftools filter \
    -i 'INFO/MAF >= 0.01' \
    -O z -o ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_maf.vcf.gz

bcftools index ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_maf.vcf.gz

# Step 2: Soft-tag genotypes failing GQ/DP thresholds, set to missing
bcftools filter \
    -S . \
    -e 'FORMAT/GQ < 20 | FORMAT/DP < 3' \
    -O z \
    -o ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_GQDP.vcf.gz \
    ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_maf.vcf.gz

bcftools index ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_GQDP.vcf.gz

# Step 3: Soft-tag het calls with bad allele balance
bcftools filter \
    --soft-filter ABfilter \
    --exclude 'GT=="het" && (FORMAT/AD[*:0]/(FORMAT/AD[*:0]+FORMAT/AD[*:1]) < 0.3 || FORMAT/AD[*:0]/(FORMAT/AD[*:0]+FORMAT/AD[*:1]) > 0.7)' \
    -O z \
    -o ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_ABtagged.vcf.gz \
    ${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_GQDP.vcf.gz

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
