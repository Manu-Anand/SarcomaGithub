#!/bin/bash -l
#$ -l h_rt=48:00:00
#$ -cwd
#$ -l mem=48G
#$ -l tmpfs=20G
#$ -N p100000-k20-medecom-TCGA
#$ -pe smp 32


# load modules
module unload compilers
module unload mpi
module load r/recommended

# do something
Rscript --vanilla /home/ucakman/Scratch/TCGA.R /home/ucakman/Scratch/SARC-combined.txt /home/ucakman/Scratch/results 100000 20 32
