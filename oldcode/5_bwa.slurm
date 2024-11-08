#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=48:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-name="bwa"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Replace these variables with the actual paths and filenames
module load bwa/0.7.17

# Files
input_folder="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/process_radtags"
reference_genome="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/bwa/GCA_003710045.2_USU_Nmel_1.3_genomic.fna"
output_folder="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/bwa/output_folder"

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Iterate through FASTQ files in the input folder
for fastq_file in "$input_folder"/*.fq; do
    if [ -f "$fastq_file" ]; then
        # Extract the sample name from the filename
        sample_name=$(basename "$fastq_file" .fq)

        # Align reads using BWA
        # bwa mem ref.fa reads.fq > aln-se.sam
        bwa mem -M -t 4 "$reference_genome" "$fastq_file" > "$output_folder/$sample_name.sam"

        # Convert SAM to BAM and sort
        samtools view -@ 4 -b -o "$output_folder/$sample_name.bam" "$output_folder/$sample_name.sam"
        samtools sort -@ 4 -o "$output_folder/$sample_name.sorted.bam" "$output_folder/$sample_name.bam"

        # Index the sorted BAM file
        samtools index "$output_folder/$sample_name.sorted.bam"

        echo "Alignment completed for $sample_name"
    fi
done
