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
OUTDIR="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered"
GQDP_VCF="${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_GQDP.vcf.gz"   # already exists from last run
OUT_FINAL="${OUTDIR}/cx_ddRAD_combined2-3_g70m70g60_ABfiltered.vcf.gz"

cd ${OUTDIR}

echo "Starting AB filter (awk-based, average across hets only)..."
echo "$(date)"

# Step 1: Extract CHROM, POS, GT, AD per sample
bcftools query -f '%CHROM\t%POS[\t%GT\t%AD]\n' ${GQDP_VCF} > snp_data.txt

# Step 2: Compute average AB across heterozygous calls only, per site
# Keep sites where avg AB (alt/(ref+alt)) falls between 0.3-0.7
awk '
BEGIN { OFS="\t" }
{
    chrom=$1; pos=$2;
    sum_ab=0; count_het=0;
    for (i=3; i<=NF; i+=2) {
        gt=$i; ad=$(i+1);
        if (gt == "0/1" || gt == "1/0" || gt == "0|1" || gt == "1|0") {
            split(ad, depths, ",");
            if (depths[1] != "." && depths[2] != "." && (depths[1]+depths[2]) > 0) {
                ab = depths[2] / (depths[1] + depths[2]);
                sum_ab += ab;
                count_het++;
            }
        }
    }
    if (count_het > 0) {
        avg_ab = sum_ab / count_het;
        if (avg_ab >= 0.3 && avg_ab <= 0.7) {
            print chrom, pos;
        }
    } else {
        # No het calls at this site - keep it (nothing to filter on)
        print chrom, pos;
    }
}' snp_data.txt > snps_to_keep.txt

echo "Sites to keep: $(wc -l < snps_to_keep.txt)"

# Step 3: Filter VCF to retain only these sites
bcftools view -T snps_to_keep.txt ${GQDP_VCF} -O z -o ${OUT_FINAL}
bcftools index ${OUT_FINAL}

# Cleanup
rm snp_data.txt snps_to_keep.txt

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
