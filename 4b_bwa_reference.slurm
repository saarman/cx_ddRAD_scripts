#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --partition=saarman-shared-np   
#SBATCH --account=saarman-np
#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --mem=24576 # memory given in MB
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=16   # 20 processor core(s) per node X 2 threads per core
#SBATCH --job-name="bwa-ref"
#SBATCH --mail-user=norah.saarman@usu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load modules
#module load bwa/2020_03_19
module load bwa-mem/2.2.1

# Replace these variables with the actual paths and filenames
input_folder="/uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_processed/"
output_folder="/uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_bwa/ref/"

# Permissions
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD*

# Index reference
cd $output_folder
#bwa index -a bwtsw GCF_003710045.2_USU_Nmel_1.3_genomic.fna
bwa-mem2 index GCF_003710045.2_USU_Nmel_1.3_genomic.fna

# Permissions
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD*
