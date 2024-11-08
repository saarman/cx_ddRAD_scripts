#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-name="stacks"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load Module
module load stacks/2.64

# Input and output
out_path="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/populations_output_2"
popmap="/project/piru_hylaues/KochProjects/alkalibeepopgen/popmap2/nomia_popmap_plate1_plate2"
in_path="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/refmap_output13"

# Code
populations -P $in_path --popmap $popmap -O $out_path -p 1 -r 0.25 -t 8 --write-random-snp --vcf --plink 

# Code usage
# ref_map.pl --samples dir --popmap path [-s spacer] --out-path path [--rm-pcr-duplicates] [-X prog:"opts" ...]

# Input/Output files:
# --samples [path] — path to the directory containing the samples BAM (or SAM) alignment files.
# --popmap [path] — path to a population map file (format is " TAB ", one sample per line).
# s [spacer for file names] — by default this is empty and the program looks for files named 'SAMPLE_NAME.bam'; if this option is given the program looks for files named 'SAMPLE_NAME.SPACER.bam'.
# o [path] — path to an output directory.
# General options:
# X — additional options for specific pipeline components, e.g. -X "populations: -p 3 -r 0.50"
# T — the number of threads/CPUs to use (default: 1).
# d — Dry run. Do not actually execute anything, just print the individual pipeline commands that would be executed.
# Paired-end options:
# --rm-pcr-duplicates — remove all but one copy of read pairs of the same sample that have the same insert length.
# --ignore-pe-reads — ignore paired-end reads even if present in the input
# --unpaired — ignore read pairing (for paired-end GBS; treat READ2's as if they were READ1's)
# SNP model options:
# --var-alpha — significance level at which to call variant sites (for gstacks; default: 0.05).
# --gt-alpha — significance level at which to call genotypes (for gstacks; default: 0.05).
# Miscellaneous:
# --time-components — (for benchmarking)
