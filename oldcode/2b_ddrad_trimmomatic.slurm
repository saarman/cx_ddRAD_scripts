#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-name="trimmomatic"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load Module
module load java

# Set the path to Trimmomatic jar file
trimmomatic_jar="/project/piru_hylaues/KochProjects/apps/Trimmomatic-0.38/trimmomatic-0.38.jar"

# Test of the data
# Input and output files
# input_file="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/process_radtags/Ru001F.fq"
# output_file="/project/piru_hylaues/KochProjects/alkalibeepopgen/trimmomatic/Ru001F_trimmed.fq"

# java -jar "$trimmomatic_jar" SE -phred33 "$input_file" "$output_file" HEADCROP:1

###################

input_dir ="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/process_radtags/"
output_dir ="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/process_radtags/trimmed/"

# Create the output directory if it doesn't exist

mkdir -p $output_dir

Loop through all fastq files in the input directory
for input_file in $input_dir/*.fq; do
    # Extract the base name of the file
    base_name=$(basename $input_file)

    # Define the output file path
    output_file="$output_dir/trimmed_$base_name"

    # Run Trimmomatic to trim the first nucleotide
    java -jar "$trimmomatic_jar" SE -phred33 "$input_file" "$output_file" HEADCROP:1

# done

# Explanation of parameters:
# - SE: Single-end mode
# - phred33: Input quality encoding
# - LEADING: Cut bases off the start of a read, if below a threshold quality
# - TRAILING: Cut bases off the end of a read, if below a threshold quality
# - MINLEN: Drop reads below a specified length
# - ILLUMINACLIP: Adapter trimming, if adapter sequences are known
# - HEADCROP: Clips 1st base
