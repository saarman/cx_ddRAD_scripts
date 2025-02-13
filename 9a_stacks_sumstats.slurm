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
module load stacks/2.64

# Define input and output paths/files
POPMAP="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_scripts/cx_p2_popmap_filtered.txt"
IN_FILE="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered_snps_indels.vcf"
OUT_PREFIX="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered_snps_indels"
OUT_PATH="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/"                                             
SUMMARY_OUT="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_filtered/cx_ddRAD_plate2_g70m70g50_filtered_snps_indels_sumstats"

# Define error log file
ERROR_LOG="${OUT_PATH}/populations_error_log.txt"

#################################
# Step 1: Run Stacks populations
#################################
echo "Running Stacks populations script..."
populations -V ${IN_FILE} --popmap $POPMAP -O ${OUT_PATH} --vcf --plink

# Check if Stacks output was generated successfully
if [[ ! -f "${OUT_PATH}/populations.sumstats_summary.tsv" ]]; then
    echo "Error: Stacks populations summary statistics were not generated." | tee -a $ERROR_LOG
    exit 1
fi

# Rename and copy the Stacks summary statistics file
cp ${OUT_PATH}/populations* ${OUT_PATH}/
echo "Stacks summary statistics saved in: "${OUT_PATH}"

#################################
# What This Script Does
#################################
# Loads necessary modules (stacks/2.64 and plink).
# Runs Stacks populations to generate summary statistics.
# Verifies that Stacks output exists before proceeding.
# Logs errors to populations_error_log.txt instead of exiting immediately where possible.
