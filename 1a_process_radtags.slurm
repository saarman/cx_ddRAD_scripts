#!/bin/bash

# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --partition=saarman-shared-np   
#SBATCH --account=saarman-np
#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --mem=24576 # memory given in MB
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=16   # 20 processor core(s) per node X 2 threads per core
#SBATCH --job-name="stacks_process"
#SBATCH --mail-user=norah.saarman@usu.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

# Load Module
module load stacks/2.64

# Input and output files
in_file1="/uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_raw/bee_ddRAD_plate1.fastq.gz"
in_file2="/uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_raw/bee_ddRAD_plate2.fastq.gz"
out_path="/uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_processed/"
barcode_file1="/uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_raw/barcodes_plate1_plusC.txt"
barcode_file2="/uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD_raw/barcodes_plate2_plusC.txt"

# Function
process_radtags -f $in_file1 -b $barcode_file1 -o $out_path \
                -r -c -q --inline-null -e ecoRI \
                --adapter-1 CTCTTTCCCTACACGACGCTCTTCCGATCT \
		--filter-illumina --disable-rad-check --barcode-dist-1 2
cp ${out_path}/process_radtags.bee_ddRAD_raw.log ${out_path}/process_radtags-%j-plate1.log

process_radtags -f $in_file2 -b $barcode_file2 -o $out_path \
                -r -c -q --inline-null -e ecoRI \
                --adapter-1 CTCTTTCCCTACACGACGCTCTTCCGATCT \
		--filter-illumina --disable-rad-check --barcode-dist-1 2
cp ${out_path}/process_radtags.bee_ddRAD_raw.log ${out_path}/process_radtags-%j-plate2.log

# Permissions
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/bee_ddRAD*

# Explanation of parameters:

# process_radtags 2.64
# process_radtags -p in_dir [-P] [-b barcode_file] -o out_dir -e enz [--threads num] [-c] [-q] [-r] [-t len]
# process_radtags -f in_file [-b barcode_file] -o out_dir -e enz [--threads num] [-c] [-q] [-r] [-t len]
# process_radtags --in-path in_dir [--paired] [--barcodes barcode_file] --out-path out_dir --renz-1 enz [--renz-2 enz] [--threads num] [-c] [-q] [-r] [-t len]
# process_radtags -1 pair_1 -2 pair_2 [-b barcode_file] -o out_dir -e enz [--threads num] [-c] [-q] [-r] [-t len]

# -p,--in-path: path to a directory of files.
# -P,--paired: files contained within the directory are paired.
# -I,--interleaved: specify that the paired-end reads are interleaved in single files.
# -i,--in-type: input file type, either 'fastq', 'gzfastq' (gzipped fastq), 'bam', or 'bustard' (default: guess, or gzfastq if unable to).
# -b,--barcodes: path to a file containing barcodes for this run, omit to ignore any barcoding or for already demultiplexed data.
# -o,--out-path: path to output the processed files.
# -f: path to the input file if processing single-end sequences.
# -1: first input file in a set of paired-end sequences.
# -2: second input file in a set of paired-end sequences.
# --threads: number of threads to run.
# -c,--clean: clean data, remove any read with an uncalled base ('N').
# -q,--quality: discard reads with low quality (phred) scores.
# -r,--rescue: rescue barcodes and RAD-Tag cut sites.
# -t,--truncate: truncate final read length to this value.
# -D,--discards: capture discarded reads to a file.
# -y,--out-type: output type, either 'fastq', 'gzfastq', 'fasta', or 'gzfasta' (default: match input type).

#  Barcode options:
#    --inline-null:   barcode is inline with sequence, occurs only on single-end read (default).
#    --index-null:    barcode is provded in FASTQ header (Illumina i5 or i7 read).
#    --null-index:    barcode is provded in FASTQ header (Illumina i7 read if both i5 and i7 read are provided).
#    --inline-inline: barcode is inline with sequence, occurs on single and paired-end read.
#    --index-index:   barcode is provded in FASTQ header (Illumina i5 and i7 reads).
#    --inline-index:  barcode is inline with sequence on single-end read and occurs in FASTQ header (from either i5 or i7 read).
#    --index-inline:  barcode occurs in FASTQ header (Illumina i5 or i7 read) and is inline with single-end sequence (for single-end data) on paired-end read (for paired-end data).

#  Restriction enzyme options:
#    -e [enz], --renz-1 [enz]: provide the restriction enzyme used (cut site occurs on single-end read)
#    --renz-2 [enz]: if a double digest was used, provide the second restriction enzyme used (cut site occurs on the paired-end read).
#    Currently supported enzymes include:
#      'aciI', 'aclI', 'ageI', 'aluI', 'apaLI', 'apeKI', 'apoI', 'aseI', 
#      'bamHI', 'bbvCI', 'bfaI', 'bfuCI', 'bgIII', 'bsaHI', 'bspDI', 'bstYI', 
#      'btgI', 'cac8I', 'claI', 'csp6I', 'ddeI', 'dpnII', 'eaeI', 'ecoRI', 
#      'ecoRV', 'ecoT22I', 'haeIII', 'hhaI', 'hinP1I', 'hindIII', 'hpaII', 'hpyCH4IV', 
#      'kpnI', 'mluCI', 'mseI', 'mslI', 'mspI', 'ncoI', 'ndeI', 'ngoMIV', 
#      'nheI', 'nlaIII', 'notI', 'nsiI', 'nspI', 'pacI', 'pspXI', 'pstI', 
#      'pstIshi', 'rsaI', 'sacI', 'sau3AI', 'sbfI', 'sexAI', 'sgrAI', 'speI', 
#      'sphI', 'taqI', 'xbaI', or 'xhoI'

#  Protocol-specific options:
#    --bestrad: library was generated using BestRAD, check for restriction enzyme on either read and potentially tranpose reads.

 # Adapter options:
 #   --adapter-1 <sequence>: provide adaptor sequence that may occur on the single-end read for filtering.
 #   --adapter-2 <sequence>: provide adaptor sequence that may occur on the paired-read for filtering.
 #     --adapter-mm <mismatches>: number of mismatches allowed in the adapter sequence.

 # Output options:
 #   --retain-header: retain unmodified FASTQ headers in the output.
 #   --merge: if no barcodes are specified, merge all input files into a single output file.

#  Advanced options:
#    --filter-illumina: discard reads that have been marked by Illumina's chastity/purity filter as failing.
#    --disable-rad-check: disable checking if the RAD cut site is intact.
#    --encoding: specify how quality scores are encoded, 'phred33' (Illumina 1.8+/Sanger, default) or 'phred64' (Illumina 1.3-1.5).
#    --window-size: set the size of the sliding window as a fraction of the read length, between 0 and 1 (default 0.15).
#    --score-limit: set the phred score limit. If the average score within the sliding window drops below this value, the read is discarded (default 10).
#    --len-limit <limit>: specify a minimum sequence length (useful if your data has already been trimmed).
#    --barcode-dist-1: the number of allowed mismatches when rescuing single-end barcodes (default 1).
#    --barcode-dist-2: the number of allowed mismatches when rescuing paired-end barcodes (defaults to --barcode-dist-1).
