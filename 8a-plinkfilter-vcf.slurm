#!/bin/bash
#SBATCH --job-name=plinkfiltervcftools
#SBATCH --output=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/8a_vcftools_filter_%j.out
#SBATCH --error=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/8a_vcftools_filter_%j.err
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --account=saarman-np
#SBATCH --partition=saarman-np
#SBATCH --mail-user=emily.calhoun@usu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load plink
module load vcftools

# --- Paths ---
IN_VCF="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_populations_output/populations.snps.vcf"
OUTDIR="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered"
IN_FILE="cx_ddRAD_combined2-3"
POPMAP="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/cx_popmapcombined-fixed11-12.txt"

mkdir -p ${OUTDIR}
cd ${OUTDIR}

# ============================================================
# PART 1: ITERATIVE PLINK MISSINGNESS FILTER (was 8a1)
#
# --geno 0.7  : drop loci missing in >70% of individuals
# --mind 0.7  : drop individuals missing >70% of loci
# --geno 0.5  : drop loci missing in >50% of individuals
#               (replaces original --geno 0.2 which dropped 93% of SNPs)
# ============================================================

echo "=== PART 1: PLINK iterative missingness filter ==="
echo "$(date)"

# Convert VCF to PLINK format
plink --vcf ${IN_VCF} \
      --double-id --allow-extra-chr \
      --make-bed --out ${IN_FILE}

plink --bfile ${IN_FILE} \
      --double-id --allow-extra-chr \
      --recode tab --out ${IN_FILE}

# Pass 1: drop loci missing in >70% of individuals
plink --file ${IN_FILE} \
      --geno 0.7 \
      --double-id --allow-extra-chr \
      --recode --out ${IN_FILE}_g70

# Pass 2: drop individuals missing >70% of loci
plink --file ${IN_FILE}_g70 \
      --mind 0.7 \
      --double-id --allow-extra-chr \
      --recode --out ${IN_FILE}_g70m70

# Pass 3: drop loci missing in >50% of individuals
plink --file ${IN_FILE}_g70m70 \
      --geno 0.5 \
      --double-id --allow-extra-chr \
      --recode --out ${IN_FILE}_g70m70g50

# Missingness stats on final PLINK output
plink --file ${IN_FILE}_g70m70g50 \
      --allow-extra-chr --missing

echo ""
echo "=== PLINK FILTER SUMMARY ==="
NSNP=$(wc -l < ${IN_FILE}_g70m70g50.map)
NIND=$(wc -l < ${IN_FILE}_g70m70g50.ped)
echo "SNPs after PLINK filter: ${NSNP}"
echo "Individuals:             ${NIND}"
echo "============================="

# ============================================================
# PART 2: CONVERT BACK TO VCF (was 8a2)
#
# Extracts the PLINK-passing sites and individuals back from
# the original VCF to preserve all INFO/FORMAT fields needed
# for the AB filter in 8b (especially AD fields)
# ============================================================

echo ""
echo "=== PART 2: Convert PLINK output back to VCF ==="
echo "$(date)"

# Extract passing site positions from PLINK .map file
awk '{print $1 "\t" $4}' ${IN_FILE}_g70m70g50.map > ${IN_FILE}_g70m70g50.pos

# Extract passing individual IDs from PLINK .nosex file
# (nosex file lists all individuals remaining after filtering)
awk '{print $1}' ${IN_FILE}_g70m70g50.fam > ${IN_FILE}_g70m70g50.keep

vcftools --vcf ${IN_VCF} \
    --positions ${IN_FILE}_g70m70g50.pos \
    --keep ${IN_FILE}_g70m70g50.keep \
    --recode --recode-INFO-all \
    --out ${IN_FILE}_g70m70g50_filtered

echo ""
echo "=== FINAL VCF SUMMARY ==="
NSNP_VCF=$(grep -v "^#" ${IN_FILE}_g70m70g50_filtered.recode.vcf | wc -l)
NIND_VCF=$(grep "^#CHROM" ${IN_FILE}_g70m70g50_filtered.recode.vcf | tr '\t' '\n' | tail -n +10 | wc -l)
echo "SNPs in final VCF:  ${NSNP_VCF}"
echo "Individuals in VCF: ${NIND_VCF}"
echo "========================="
echo ""
echo "Output VCF: ${OUTDIR}/${IN_FILE}_g70m70g50_filtered.recode.vcf"
echo "Next step: run 8b_bcftools_ABfilter.slurm on this file"
echo "$(date)"
