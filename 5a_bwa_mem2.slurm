#!/bin/sh
#SBATCH --time=336:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1          # same as $max set in ForkManager
#SBATCH --mem=400G
#SBATCH --account=saarman-np
#SBATCH --partition=saarman-shared-np   
#SBATCH --job-name=bwa-mem2
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=norah.saarman@usu.edu

# Load the specific version of samtools and bwa-mem2
module load samtools/1.16
module load bwa-mem/2.2.1

# Change to the directory where the input data is located
cd /uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_processed

# Run the Perl script with the input files
perl /uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_scripts/alkalibee/5a_bwa_mem2.pl *.fq.gz
