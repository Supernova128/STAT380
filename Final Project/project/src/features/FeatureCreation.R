library(data.table)
library(ClusterR)
library(Rtsne)

# Load data

trainemb <- fread('project/volume/data/external/train_emb.csv') 

testemb <- fread('project/volume/data/external/test_emb.csv') 

trainraw <- fread('project/volume/data/external/train_data.csv')
  
testraw <- fread('project/volume/data/external/test_file.csv')

# Clean train data

# Get the names of subreddits

subreddits <- names(trainraw[,-1:-2])

# Bind the answers and embedded data 

train <- cbind(trainraw[,-1:-2],trainemb)

# Melt data

train <- melt(train,id.vars = (length(subreddits)+1):length(names(train)))

# Only keep subreddits that the post belongs to

train <- train[value == 1]

# Null out value column

train[,value := NULL]

# save Y values and null it out

train.y <- train$variable

train[,variable := NULL]



totaldata <- rbind(train,testemb)

totaldata.pca <- prcomp(totaldata)


pca.dt <- data.table(totaldata.pca$x)

test <- pca.dt[(nrow(train)+1):nrow(pca.dt)]

train <- pca.dt[1:nrow(train)]



train_dt <- data.table(train.tsne$Y)




train_pca <- data.table(train.tsne$Y)

test_pca <- data.table(test.tsne$Y)





biplot(p)


p$center