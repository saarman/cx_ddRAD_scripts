#!/bin/bash
#SBATCH --partition=saarman-shared-np   
#SBATCH --account=saarman-np
#SBATCH --time=24:00:00
#SBATCH --mem=24576
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --job-name="stacks_formerge"
#SBATCH --mail-user=emily.calhoun@usu.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load stacks/2.64

out_path="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_populations_formerge"
popmap="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/cx_popmapcombined-fixed11-12.txt"
in_path="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_stacks_filtered"

# Relaxed filters, all SNPs per locus (no --write-random-snp), VCF only
populations -P $in_path --popmap $popmap -O $out_path \
    -p 1 -r 0.1 -t 8 \
    --vcf
