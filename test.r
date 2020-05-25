library(earlycross)
pbmc_small$trt <- sample(c("drug", "control"), ncol(pbmc_small), replace=TRUE)
pbmc_small$genotype <- sample(c("1", "2", "3"), ncol(pbmc_small), replace=TRUE)
CompareClustersByTrt(pbmc_small, rlang::quo(trt), rlang::quo(genotype)) + ggplot2::xlab("")
