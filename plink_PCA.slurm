#!/bin/bash
#SBATCH --job-name=plink_PCA
#SBATCH --output=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/plink_PCA_%j.out
#SBATCH --error=/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/logs/plink_PCA_%j.err
#SBATCH --partition=saarman-np   
#SBATCH --account=saarman-np
#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --mem=24576 # memory given in MB
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=16   # 20 processor core(s) per node X 2 threads per core
#SBATCH --mail-user=emily.calhoun@usu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load plink

# --- Paths ---
IN_VCF="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/cx_ddRAD_combined2-3_g70m70g60_ABfiltered.vcf.gz"
OUTDIR="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered"
OUT_PREFIX="${OUTDIR}/cx_ddRAD_g70m70g60_pca"

mkdir -p ${OUTDIR}

echo "Starting PLINK PCA..."
echo "$(date)"

# Step 1: Convert VCF to PLINK binary format
plink --vcf ${IN_VCF} \
      --double-id \
      --allow-extra-chr \
      --set-missing-var-ids @:# \
      --make-bed \
      --out ${OUT_PREFIX}

# Step 2: LD pruning before PCA
# --indep-pairwise 50 10 0.1 : window 50 SNPs, step 10, r2 threshold 0.1
# Important for PCA - correlated SNPs inflate variance of early PCs
plink --bfile ${OUT_PREFIX} \
      --double-id \
      --allow-extra-chr \
      --set-missing-var-ids @:# \
      --indep-pairwise 50 10 0.1 \
      --out ${OUT_PREFIX}

# Step 3: Run PCA on pruned SNPs
plink --bfile ${OUT_PREFIX} \
      --double-id \
      --allow-extra-chr \
      --set-missing-var-ids @:# \
      --extract ${OUT_PREFIX}.prune.in \
      --pca 10 \
      --out ${OUT_PREFIX}

echo ""
echo "=== PCA SUMMARY ==="
NSNP=$(wc -l < ${OUT_PREFIX}.prune.in)
echo "SNPs used for PCA (post LD pruning): ${NSNP}"
echo "Output eigenvectors: ${OUT_PREFIX}.eigenvec"
echo "Output eigenvalues:  ${OUT_PREFIX}.eigenval"
echo "$(date)"
echo "==================="
echo ""
echo "Ready to load into R for plotting!"
