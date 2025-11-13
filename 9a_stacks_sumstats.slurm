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
filter_include="g70m70g20"             # NOTE: This is where you choose which filtered output from geno/mind/plink you will use going forward
plate_name="cx_ddRAD_combined2-3"      # NOTE: This is where you choose which plate/root name of file
POPMAP="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/cx_popmapcombined-fixed11-12.txt"
IN_FILE="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/${plate_name}_${filter_include}_ABfiltered.vcf"
OUT_PATH="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/"                                             
SUMMARY_OUT="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_filtered/${plate_name}_${filter_include}_finalsummary"

#################################
# Step 1: Run Stacks populations
#################################
echo "Running Stacks populations script..."
populations -V ${IN_FILE} --popmap $POPMAP -O ${OUT_PATH} --vcf --plink

# Rename and copy the Stacks summary statistics file
echo "Stacks summary statistics saved in: ${OUT_PATH}"

#################################
# What This Script Does
#################################
# Loads necessary modules (stacks/2.64 and plink).
# Runs Stacks populations to generate summary statistics.
# Verifies that Stacks output exists before proceeding.
