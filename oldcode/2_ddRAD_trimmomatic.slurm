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

# Input and output files
input_file="/project/piru_hylaues/KochProjects/alkalibeepopgen/ddRAD.fastq"
output_file="/project/piru_hylaues/KochProjects/alkalibeepopgen/trimmomatic/ddRAD_output_trimmed.fastq"

# Trimming parameters
# You can adjust these parameters based on your data and quality requirements
# min length set to 300 based on sequencing approach from forward end; identified in email by Norah Saarman
quality_threshold="20"
min_length="300"

# Adapter sequences (if known)
# You can specify adapter sequences to remove
# Example: adapters="ILLUMINACLIP:TruSeq3-SE.fa:2:30:10"
# adapters="ILLUMINACLIP:/project/piru_hylaues/KochProjects/apps/Trimmomatic-0.38/adapters/TruSeq3-SE.fa:2:30:10"
adapters="ILLUMINACLIP:/project/piru_hylaues/KochProjects/alkalibeepopgen/saarman_adapters.fa:2:30:10"

# Run Trimmomatic
java -jar "$trimmomatic_jar" SE -phred33 "$input_file" "$output_file" \
    LEADING:"$quality_threshold" TRAILING:"$quality_threshold" \
    SLIDINGWINDOW:30:20 AVGQUAL:"$quality_threshold" \
    MINLEN:"$min_length" $adapters

# Explanation of parameters:
# - SE: Single-end mode
# - phred33: Input quality encoding
# - LEADING: Cut bases off the start of a read, if below a threshold quality
# - TRAILING: Cut bases off the end of a read, if below a threshold quality
# - MINLEN: Drop reads below a specified length
# - ILLUMINACLIP: Adapter trimming, if adapter sequences are known
