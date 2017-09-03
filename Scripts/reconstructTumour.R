library(METHods)

# load undiff betas
# load medecom LMCs
lmc = read.csv("~/Scratch/results/lmc.csv")# load medecom lmcs
prop = read.csv("~/Scratch/results/prop.csv")# load medecom props
rownames(prop) = paste0('LMC',rownames(prop))
# function to create betas mixture
createMix = function(LMCs,props)
	{
	sapply(colnames(prop),FUN=function(x) rowSums(sapply(rownames(props),FUN=function(y) props[y,x]*LMCs[,y])))
	}

# remove normal and renormalise
norm = c('LMC5') # See hirearchical clustring and send the file to Chris.
lmcsTum = lmcs[,-which(colnames(lmcs)%in%norm)]
propTum = prop[-which(rownames(prop)%in%norm),]
propTum = apply(propTum,MARGIN=2,FUN=function(x) as.numeric(x)/sum(as.numeric(x)))
rownames(propTum) = colnames(lmcsTum)
# remove tumour and renormalise

# create mixture
mixTum = createMix(lmcsTum,propTum)
write.csv(mixTum,file = "~/Scratch/results/reconstructedbeta.csv")
