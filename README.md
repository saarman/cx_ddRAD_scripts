# cx_ddRAD bioinformatics steps
Culex population genomics with [Saarman ddRADseq protocol](https://docs.google.com/document/d/1fbrfyLTfIlvvffxJgiXUt4KfkHRMW-tx/edit?usp=sharing&ouid=111289447482543500025&rtpof=true&sd=true), Illumina NextSeq 2000 P1 300 cycles, 150 bp paired-end reads, enzymes EcoRI and MspI, 500-1400 bp fagment size selected (Blue Pippin set to 600-1500 bp to account for 103 bp of adaptors/primers added before size selection step).

## A place to keep track of ddRAD bioinformatics steps

# Logging onto CHPC with Terminal on a mac
1. Open Terminal
2. ssh u6036559@notchpeak.chpc.utah.edu        #replace with your username
3. salloc --time=72:00:00 --ntasks 1 --mem=100G --account=saarman-np --partition=saarman-shared-np

# Prepare input files  

## Upload files to CHPC group1 storage
SFTP file transfer protocol with Cyberduck worked easily.  
Select SFTP at the top.  
Server: notchpeak  
User: u6036559  
Port: 21  
Drag and drop from local disk.  
/uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_raw  

## To unzip a .tar.gz file:
```
tar –xvzf cx_ddRAD_plate1.tar.gz
mv ./data/Saarman/ddRAD/ddRAD.fastq.gz ./cx_ddRAD_plate1.fastq.gz
```

## Change permissions
```
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD*
```

# Submit your job

## Github
***Run just ONCE: Clone from Github***  
Before running, I need to make these files on github, and then use git to clone
```
# Just once:
cd /uufs/chpc.utah.edu/common/home/saarman-group1/ 
git clone https://github.com/saarman/cx_ddRAD_scripts cx_ddRAD_scripts
```
***Need to run every time: Pull any changes from Github***  
```
cd /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_scripts/
git pull
```
***Need to run every time: Submit to slurm***
https://www.chpc.utah.edu/documentation/software/slurm.php#usingslurm
```
cd /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD_scripts/
sbatch 1a_process_radtags.slurm
```

##  Checking the status of your job
https://www.chpc.utah.edu/documentation/software/slurm.php#squeue  
```
squeue --me
```

## Change permissions (again)
```
chmod -R g+w /uufs/chpc.utah.edu/common/home/saarman-group1/cx_ddRAD*
```
