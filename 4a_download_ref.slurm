#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --partition=saarman-shared-np   
#SBATCH --account=saarman-np
#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --mem=24576 # memory given in MB
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=16   # 20 processor core(s) per node X 2 threads per core
#SBATCH --job-name="download"
#SBATCH --mail-user=emily.calhoun@usu.edu    # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load modules
module load bwa/2020_03_19

# Replace these variables with the actual paths and filenames
input_folder="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_processed/"
output_folder="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_bwa/ref/"

# Download reference
# cd $output_folder
# wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/710/045/GCF_003710045.2_USU_Nmel_1.3/GCF_003710045.2_USU_Nmel_1.3_genomic.fna.gz

#Reference already here
Ref="/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_bwa/ref/Cpip29_nodeb_gfill_mito.fasta" 


# Permissions
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD*

# Unzip reference if needed
# gzip -d GCF_003710045.2_USU_Nmel_1.3_genomic.fna.gz 

# Permissions
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD*
