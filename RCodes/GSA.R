#=================================================================================
# Global sensitivity analysis using Sobols method in R using sensitivity package
#=================================================================================
library(sensitivity)
library(boot)
library(ggplot2)
#=================================================================================
# Set working directory where all the files are from GitHub repository were saved
wkdir <- "<Lunux Directory>"
setwd(wkdir)
sitePath <- paste(wkdir, "/Broadbalk", sep = "")
#=================================================================================
source("./RCodes/RunDayCent.R")
source("./RCodes/change_fix100Parameters.R")
source("./RCodes/change_cult100Parameters.R")
#=================================================================================
# read prior distribution from a csv file
paramBounds <- read.csv("./InputData/GSA_Parameters.csv", stringsAsFactors = FALSE)
#=================================================================================
# names of parameters that are allowed to vary
varSI       <- paramBounds$Parameters
nParams     <- length(varSI)
#=================================================================================
# Random sampling for GSA
#=================================================================================
set.seed(1562)
# sample size (10 used for illustration purposes)
N <- 10 # (1024 used in Gurung et al., 2020)
# Sobols method required 2 matrix
m1 = matrix(runif(nParams*N), nrow=N);
m2 = matrix(runif(nParams*N), nrow=N);

M1 <- matrix(0, nrow = N, ncol = nParams)
M2 <- matrix(0, nrow = N, ncol = nParams)

# transform standard uniform to prior distribution 
for(i in 1:nParams){
     pos <- which(paramBounds$Parameter == varSI[i])
     lower <- paramBounds[pos, "Lower"]
     upper <- paramBounds[pos, "Upper"]
     M1[, i] <- qunif(m1[, i], min = lower, max = upper)
     M2[, i] <- qunif(m2[, i], min = lower, max = upper)
}
X1 = data.frame(M1)
X2 = data.frame(M2)
names(X1) <- varSI
names(X2) <- varSI
#=================================================================================
# choose a sensitivity method of your choice from the sensitivity package in R.
# see documantation for available options.
#    - soboljansen is used for ilustration here
si_obj2 <- soboljansen(model = NULL, X1 = X1, X2 = X2, nboot = 100)
X <- si_obj2$X
n <- nrow(X)
X <- cbind("SampleID" = 1:nrow(X), X)
#=================================================================================
# End of sample generation for GSA
#=================================================================================
MeasSOC <- read.csv("./InputData/SOCdataset.csv", stringsAsFactors = FALSE)
#=================================================================================
# Run the model and calculate log-likelihood
#    - likelihoods were calculated assuming that the error (modeled - mesasured)
#      are iid 
#=================================================================================
Lkhood <- NULL
for(i in 1:nrow(X)){
     lkd <- RunDC(i)
     Lkhood <- rbind(Lkhood, lkd)
}
setwd(wkdir)
#=================================================================================
# Calculate First-order and Total global sensitivity indices
#=================================================================================
si_obj2_llkhd <- tell(x = si_obj2, y = Lkhood$llkhd)
#=================================================================================
# Total-Order sensitivity indices
#=================================================================================
totalSI <- si_obj2_llkhd$T # total sensitivity indices
totalSI$parmas <- row.names(totalSI)
names(totalSI) <- c("totsi", "bias", "std.error", "totsi.lci", "totsi.uci", "params")
totalSI <- totalSI[order(-totalSI$totsi), ]
rownames(totalSI) <- 1:nrow(totalSI)
totalSI$ID <- 1:nrow(totalSI)
totalSI <- totalSI[, c("ID", "params", "totsi", "totsi.lci", "totsi.uci")]
setwd(wkdir)
write.csv(totalSI, "totalSI.csv")
saveRDS(totalSI, "totalSI.rds")
#=================================================================================
# Result Plot
#=================================================================================
library(ggplot2)
p1 <- ggplot(totalSI, aes(x = reorder(params, -ID), y = totsi))+ 
     xlab("Parameters") + ylab("Total Sensitivity Index") +
     geom_bar(stat='identity', fill = "grey50") +
     coord_flip() + theme_bw()

jpeg(paste("GSA.jpg", sep = ""), width = 7, height = 3, unit = "in", res = 1000, quality = 100)
print(p1)
dev.off()
