#=================================================================================
# Sampling Importance Resampling algorithm with Latin hypercube sampling in R
#=================================================================================
library(lhs)
library(reshape2)
library(ggplot2)
#================================================================================
# Set working directory where all the files are from GitHub repository were saved
wkdir <- "<linux directory>"
setwd(wkdir)
sitePath <- paste(wkdir, "/Broadbalk", sep = "")
#=================================================================================
source("./RCodes/RunDayCent.R")
source("./RCodes/change_fix100Parameters.R")
source("./RCodes/change_cult100Parameters.R")
#=================================================================================
# read prior distribution from a csv file
paramBounds <- read.csv("./InputData/SIR_Parameters.csv", stringsAsFactors = FALSE)
#=================================================================================
# names of parameters that are allowed to vary
varSI       <- paramBounds$Parameters
nParams     <- length(varSI)
#=================================================================================
# LHS sampling for SIR
#=================================================================================
set.seed(1562)
# sample size (1000 used for illustration purposes)
n <- 200 # (1000000 samples were used in Gurung et al., 2020)
X1 <- randomLHS(n = n, k = nParams)
# transform standard uniform LHS to prior distribution 
Y1 <- matrix(0, nrow = nrow(X1), ncol = nParams)
for(i in 1:nParams){
     pos <- which(paramBounds$Parameter == varSI[i])
     lower <- paramBounds[pos, "Lower"]
     upper <- paramBounds[pos, "Upper"]
     Y1[, i] <- qunif(X1[, i], min = lower, max = upper)
}
X <- as.data.frame(Y1)
names(X) <- varSI
X <- cbind("SampleID" = 1:nrow(X), X)
#=================================================================================
# End of LHS generation for SIR
#=================================================================================
MeasSOC <- read.csv("./InputData/SOCdataset.csv", stringsAsFactors = FALSE)
#=================================================================================
# Run the model and calculate log-likelihood
#    - likelihoods were calculated assuming that the error (modeled - mesasured)
#      are iid 
#=================================================================================
Lkhood <- NULL
for(i in 1:nrow(X)){
	 print(paste(i, " ", date()))
     lkd <- RunDC(i)
	 Lkhood <- rbind(Lkhood, lkd)
}
#=================================================================================
# Calculate importance weights
Lkhood$Wts <- exp(Lkhood$llkhd)/sum(exp(Lkhood$llkhd))
#=================================================================================
# sample without replacement
set.seed(13546)
nsamp <- 50 # (a resampling of 1000 were used in Gurung et al., 2020)
sampIndx <- sample(1:nrow(Lkhood), 
                   size = nsamp, replace = FALSE,
                   prob = Lkhood$Wts)
PostTheta <- as.data.frame(X[sampIndx,])
#================================================================================================================
prior <- melt(X[,-1])
posterior <- melt(PostTheta[,-1])

p2 <- ggplot() +
  geom_density(data = posterior, aes(value), col = NA, fill = "red", alpha = 0.2) +
  geom_density(data = prior, aes(value), col = NA, fill = "blue", alpha = 0.2) +
  facet_wrap(~variable, scales = "free", ncol = 3) +
  theme_bw() +
  theme(panel.border = element_rect(colour = "black", fill = NA), panel.grid.major = element_blank(),
        axis.title.x=element_blank(),panel.grid.minor = element_blank()) +
  scale_y_continuous(expand = c(0,0)) + scale_x_continuous(expand = c(0,0))

setwd(wkdir)
jpeg(paste("SIR.jpg", sep = ""), width = 11, height = 7, unit = "in", res = 1000, quality = 100)
print(p2)
dev.off()
