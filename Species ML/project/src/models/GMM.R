library(data.table)
library(ggplot2)
library(ClusterR)
library(Rtsne)


data <- fread('project/volume/data/external/data.csv')

# Use tsne 

pca <- Rtsne(data[,-1],
             pca = T, 
             perplexity = 100, 
             check_duplicate = F)


pca_dt <- data.table(pca$Y)

# Do GMM

gmm_data <- GMM(pca_dt,3)

probclus <- predict_GMM(pca_dt,
                        gmm_data$centroids,
                        gmm_data$covariance_matrices,
                        gmm_data$weights)


answers <- cbind(data[,1],probclus$cluster_proba)


setnames(answers, c('id','breed.3','breed.2','breed.1'))




fwrite(answers,file = 'project/volume/data/processed/submission.csv')




