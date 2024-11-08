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

# Replace "your_file.fastq" with the actual name of your FASTQ file
# file="ddRAD/trimmomatic/ddRAD_output_trimmed.fastq"
file="ddRAD/ddRAD.fastq"

# Count the number of lines in the file
line_count=$(wc -l < "$file")

# Calculate the number of reads (assuming each read has 4 lines)
read_count=$((line_count / 4))

echo "Number of reads in the trimmed $file: $read_count"
