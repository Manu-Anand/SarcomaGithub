#!/bin/bash
scriptFile=/home/ucakman/Scratch/TCGA.R
TCGAfile=/home/ucakman/Scratch/SARC-combined.txt
outDir=/home/ucakman/Scratch/results
nProbes=10000
nCores=32
for K in {2..20}; do
echo "#!/bin/bash -l
#$ -l h_rt=48:00:00
#$ -cwd
#$ -l mem=48G
#$ -l tmpfs=20G
#$ -N p$nProbes-k$K-medecom-TCGA
#$ -pe smp $nCores


# load modules
module unload compilers
module unload mpi
module load r/recommended

# do something
Rscript --vanilla $scriptFile $TCGAfile $outDir $nProbes $K $nCores" > tmp.sh
qsub tmp.sh
done
