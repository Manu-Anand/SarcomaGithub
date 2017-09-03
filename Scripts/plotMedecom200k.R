library(METHods)
#dirs = assignFolders()
# load betas
manifest = METHods:::getManifest("450k")
sexIndex = rownames(manifest)[which(manifest$chr%in%c("chrX","chrY"))]
rm(manifest)
gc()
# load data
library(data.table)
data = fread('~/Scratch/SARC-combined.txt')
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
data = data[rev(order(MAD))[1:10000],]
probeNames = unlist(probeNames[rev(order(MAD))[1:10000]])
rm(MAD)
gc()

# function to load medecom results
loadRes = function(file)
	{
	load(file)
	return(medecom.result)
	}

# medecom result files
resDir = "~/Scratch/results"
files = list.files(resDir)
files = files[grep("p10k",files)]
# load results
results = sapply(paste(resDir,files,sep="/"),FUN=loadRes,simplify=FALSE)
# get cross validation error
cve = t(sapply(results,FUN=function(x) x@outputs$'1'$cve))
# select K to minimise CVE
kNames = sapply(gsub("[.]Rdata","",files),FUN=function(x) strsplit(x,split="-")[[1]][3])
kNames = gsub("K","",kNames)
rownames(cve) = kNames
colnames(cve) = results[[1]]@parameters$lambdas
pdf("~/Scratch/results/cv_error_k.pdf")
matplot(x=rownames(cve)[order(as.numeric(rownames(cve)))],y=cve[order(as.numeric(rownames(cve))),],type="l",xlab="K",ylab="CVE error")
dev.off()
indexK = row(cve)[which.min(cve)]
k = gsub("K","",rownames(cve)[indexK])

library(MeDeCom)
# select Lambda to minimise CVE
pdf("~/Scratch/results/lamda.pdf")
plotParameters(results[[indexK]], K=k, lambdaScale="log")
dev.off()
Lambda = 0.1 # Check the lamda for cv error and get the value for min and replace here.
# plot proportions
pdf("~/Scratch/results/proportions.pdf")
plotProportions(results[[indexK]], K=k, lambda=Lambda, type="heatmap",heatmap.clusterCols=TRUE,#sample.characteristic=groupsNamed,
heatmap.clusterRows = TRUE)
dev.off()

# get latent variables
lmcs = getLMCs(results[[indexK]],K=k,lambda=Lambda)
rownames(lmcs) = probeNames
colnames(lmcs) = paste0("LMC",1:k)
write.csv(lmcs, file="~/Scratch/results/lmc.csv")
# get proportions
prop = getProportions(results[[indexK]], K=k, lambda=Lambda)
colnames(prop) = colnames(data)
rownames(prop) = paste0("LMC",1:k)
write.csv(prop, file="~/Scratch/results/prop.csv")

# load references
load("~/Scratch/combined-tissueRefs.Rdata")
probes = intersect(probeNames,rownames(refs))
# correlate references and hiddeen variables
corr = cor(lmcs[probes,],refs[probes,])
library(corrplot)
pdf("~/Scratch/results/corrplot.pdf")
corrplot(corr)
dev.off()

# cluster references and hidden variables - ward
pdf("~/Scratch/results/tissue_cluster_ward.pdf")
clusters = hclust(dist(t(cbind(lmcs[probes,],refs[probes,]))),method="ward.D2")
plot(clusters,main=NA,xlab=NA)
dev.off()

# cluster references and hidden variables
pdf("~/Scratch/results/tissue_cluster.pdf")
clusters = hclust(dist(t(cbind(lmcs[probes,],refs[probes,]))))
plot(clusters,main=NA,xlab=NA)
dev.off()

# get manifest
