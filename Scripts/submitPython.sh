#!/bin/bash -l
#$ -l h_rt=24:00:00
#$ -cwd
#$ -l mem=20G
#$ -l tmpfs=5G
#$ -N pythonClassify
####### -pe smp $nCores


# load modules
#module load python

# do something
python sar_classification.py
#qsub tmp.sh

