#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=40   # 20 processor core(s) per node X 2 threads per core
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-name="multiqc"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load Module
module load  multiqc/1.15

# Input and output files
in_path="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/fastqc2/"
outdir="/project/piru_hylaues/KochProjects/alkalibeepopgen/stacks_pipeline/fastqc2/multiqc"

multiqc $in_path --outdir $outdir
