#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# inFile, outFile, nProbes, K, nCores
args[3:5] = as.numeric(args[3:5])
# get probes to remove
library(METHods)
manifest = METHods:::getManifest("450k")
sexIndex = rownames(manifest)[which(manifest$chr%in%c("chrX","chrY"))]
rm(manifest)
gc()
# load data
library(data.table)
data = fread(args[1])
# remove NAs
data = subset(data,subset=complete.cases(data))
# remove SNP probes
data = subset(data,subset=!grepl("rs",t(data[,1])))
# remove sex probes
data = subset(data,subset=!t(data[,1])%in%sexIndex)
rm(sexIndex)
gc()
# remove probe names
probeNames = subset(data,select=1)
data = subset(data,select=-1)
# subset to variable probes
MAD = apply(data,MARGIN=1,mad)
data = data[rev(order(MAD))[1:args[3]],]
rm(MAD)
gc()
# convert to matrix
data = as.matrix(data)
# run medecom
library(MeDeCom)
medecom.result<-runMeDeCom(data, Ks=as.numeric(args[4]), lambdas=c(0,10^(-5:-1)),NCORES=as.numeric(args[5]))
save(list=c("medecom.result","probeNames"),file=paste0(args[2],"/medecomResults-p",as.numeric(args[3])/1000,"k-K",args[4],".Rdata"))
