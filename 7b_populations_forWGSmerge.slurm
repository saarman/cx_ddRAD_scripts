#!/bin/bash
#SBATCH --partition=saarman-np
#SBATCH --account=saarman-np
#SBATCH --time=48:00:00
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --job-name="prep_ddrad"
#SBATCH --mail-user=emily.calhoun@usu.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL


module load stacks/2.64

out_path="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_populations_formerge"
popmap="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_scripts/cx_popmapcombined-fixed11-12.txt"
in_path="/uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_stacks_filtered"

mkdir -p /uufs/chpc.utah.edu/common/home/u1055819/saarman-group/cx_ddRAD_populations_formerge

# Relaxed filters, all SNPs per locus (no --write-random-snp), VCF only
populations -P $in_path --popmap $popmap -O $out_path \
    -p 1 -r 0.1 -t 8 \
    --vcf
