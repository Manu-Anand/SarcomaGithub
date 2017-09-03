#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
args = as.numeric(args)

dataDir="/home/ucbtcds/Scratch/data/undiff/"
# load betas 
load(paste0(dataDir,"undiffNormOnly-NoLowGrade-NoMultiDiff-NoFusions-betas-funnormSex-dropSex-dropLowQ.Rdata"))
# out dir
outDir = "/home/ucbtcds/Scratch/results/undiff/medecom/"
outFile = paste0(outDir,args[1]/1000,"k")
system(paste0("mkdir ",outFile))
# subset to probes of interest
MAD = apply(betasSarc,MARGIN=1,mad)
betasSarc = betasSarc[rev(order(MAD))[1:args[1]],]
rm(MAD)
gc()
library(MeDeCom)
# run with range of params
medecom.result<-runMeDeCom(betasSarc, Ks=args[2], lambdas=c(0,10^(-5:-1)),NCORES=args[3])
save(list="medecom.result",file=paste0(outFile,"/medecomResults-",args[1]/1000,"k-K",args[2],".Rdata"))
