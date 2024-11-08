#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=168:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=medium    # standard node(s)
#SBATCH --job-name="bwa"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module load bwa/0.7.17
module load samtools/1.16.1

# Replace these variables with the actual paths and filenames
input_folder="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/process_radtags4"
output_folder="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/bwa/aligned"
reference_genome="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/bwa/reference_genome/GCA_003710045.2_USU_Nmel_1.3_genomic.fa"
    
for fastq_file in "$input_folder"/*.fq; do
    if [ -f "$fastq_file" ]; then
        # Extract the sample name from the filename
        sample_name=$(basename "$fastq_file" .fq)

        # Align reads using BWA
        bwa mem -M -t 4 "$reference_genome" "$fastq_file" |
        samtools view -b |
        samtools sort --threads 4 > "$output_folder/$sample_name.bam"
        echo "Alignment completed for $sample_name"
    fi
done

# Resource
# https://catchenlab.life.illinois.edu/stacks/manual/#refmapbyhand
