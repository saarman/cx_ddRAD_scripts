#!/bin/bash

# Job standard output will be saved as slurm-%j.out (where %j is the job ID)

#SBATCH --partition=saarman-shared-np   
#SBATCH --account=saarman-np
#SBATCH --time=24:00:00   # Walltime limit (HH:MM:SS)
#SBATCH --mem=24576       # Memory in MB
#SBATCH --nodes=1         # Number of nodes
#SBATCH --ntasks-per-node=16   # 16 tasks per node (adjust as needed)
#SBATCH --job-name="stacks"
#SBATCH --mail-user=emily.calhoun@usu.edu   # Email notifications
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Load required modules for Stacks and PLINK
module load plink/1.90

# Define input and output paths/files
POPMAP="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_scripts/cx_plate3_popmap.txt"
IN_FILE="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate3_g70m70g50_finalfiltered_snps_noindels.vcf"
OUT_PREFIX="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate3_g70m70g50_finalsnps"
OUT_PATH="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/"                                             
SUMMARY_OUT="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate3_g70m70g50_final_plinkstats"


#################################
# Step 1: Run PLINK Summary Statistics Commands
#################################
# Ensure the input VCF file exists
if [[ ! -f "$IN_FILE" ]]; then
    echo "Warning: VCF file not found: $IN_FILE"
    exit 1
fi

# Convert VCF file to PLINK format
echo "Converting VCF to PLINK format..."
plink --vcf $IN_FILE --make-bed --out $OUT_PREFIX

# Verify that PLINK file conversion was successful
if [[ ! -f "${OUT_PREFIX}.bed" ]]; then
    echo "Warning: PLINK file conversion failed." 
    exit 1
fi

# Compute allele frequencies
echo "Computing Allele Frequencies..."
plink --bfile $OUT_PREFIX --freq --out ${SUMMARY_OUT}_allele_freq

# Compute missingness per SNP and per individual
echo "Computing Missingness Per SNP and Per Individual..."
plink --bfile $OUT_PREFIX --missing --out ${SUMMARY_OUT}_missing

# Compute heterozygosity per individual
echo "Computing Heterozygosity per Individual..."
plink --bfile $OUT_PREFIX --het --out ${SUMMARY_OUT}_heterozygosity

# Perform Hardy-Weinberg Equilibrium (HWE) test
echo "Performing Hardy-Weinberg Equilibrium Test..."
plink --bfile $OUT_PREFIX --hardy --out ${SUMMARY_OUT}_hwe

# Compute inbreeding coefficients (F-statistics)
echo "Computing Inbreeding Coefficients (F-statistics)..."
plink --bfile $OUT_PREFIX --het --out ${SUMMARY_OUT}_fstat

#################################
# Step 2: Merge Summary Statistics
#################################
echo "Compiling summary statistics..."

# Ensure all required summary statistics files exist before merging
if [[ -f ${SUMMARY_OUT}_allele_freq.frq && -f ${SUMMARY_OUT}_missing.lmiss && \
      -f ${SUMMARY_OUT}_missing.imiss && -f ${SUMMARY_OUT}_heterozygosity.het && \
      -f ${SUMMARY_OUT}_hwe.hwe ]]; then

    paste ${SUMMARY_OUT}_allele_freq.frq ${SUMMARY_OUT}_missing.lmiss ${SUMMARY_OUT}_missing.imiss \
          ${SUMMARY_OUT}_heterozygosity.het ${SUMMARY_OUT}_hwe.hwe > ${SUMMARY_OUT}_combined.tsv
    echo "Summary statistics saved to: ${SUMMARY_OUT}_combined.tsv"

else
    echo "Warning: One or more summary statistics files are missing. Skipping merge."
fi

echo "PLINK processing completed successfully!"

#################################
# What This Script Does
#################################
# Loads necessary modules (stacks/2.64 and plink).
# Converts the VCF to PLINK format and checks for errors.
# Computes multiple PLINK-based summary statistics:
# Allele frequencies
# Missingness per SNP/individual
# Heterozygosity
# Hardy-Weinberg Equilibrium (HWE) test
# F-statistics (inbreeding coefficients)
# Merges PLINK outputs into a single file, checking that all required files exist before merging.
# Logs possible errors as warnings instead of exiting immediately where possible.
