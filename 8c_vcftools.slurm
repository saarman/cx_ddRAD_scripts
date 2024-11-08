#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-name="vcf"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

now=$(date +"%T")
echo "Start time : $now"

# Load Module
module load vcftools/0.1.16

# Input and output
in_file="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/populations_output_2/populations.snps_filtered.recode.vcf"

# Code

vcftools --vcf $in_file --max-alleles 2 --min-alleles 2 --remove bad_inds_0.5 --maf 0.01 --max-missing 0.5 --thin 10000 --min-meanDP 10  --recode

now=$(date +"%T")
echo "End time : $now"
