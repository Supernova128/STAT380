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

# Bind test and train data

totaldata <- rbind(train,testemb)

# Perform PCA

totaldata.pca <- prcomp(totaldata)


pca.dt <- data.table(totaldata.pca$x)

# Separate test and train data

test <- pca.dt[(nrow(train)+1):nrow(pca.dt)]

train <- pca.dt[1:nrow(train)]

# Bind subreddits to train 

train <- cbind(train,train.y)

# Save data 

fwrite(train,file = "project/volume/data/interim/trainpca")


fwrite(test,file = "project/volume/data/interim/testpca")










