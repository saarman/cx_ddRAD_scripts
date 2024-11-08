#!/bin/bash

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-name="fastqc"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module load fastqc/0.12.1

wd=/90daydata/shared/jonathan.koch/${species}

# Specify the path to the config file
config=${wd}/config_files/fastq_process_radtags_array.txt
#config=${wd}/config_files/fastq_trimmed_array.txt
#config=${wd}/config_files/fastq_files_array.txt


# Extract the file name for the current $SLURM_ARRAY_TASK_ID
sample=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

# Print to a file a message that includes the current $SLURM_ARRAY_TASK_ID, the same name, and the sex of the sample
echo "This is array task ${SLURM_ARRAY_TASK_ID}, the file name is ${sample}."

 version='fastqc --version'

echo "Generating fastqc output  on $(date) with ${version}"

fastqc -o ${wd}/fastqc_reports -t 2 --noextract ${wd}/${sample} 

mv FastQC.* ${wd}/fastqc_reports/std_outs/
