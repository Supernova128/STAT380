library(data.table)
library(xgboost)


# Get data 

train <- fread("project/volume/data/interim/trainpca")

test <- fread("project/volume/data/interim/testpca")

train.y <- train[,subreddits]

train[,subreddits := NULL]

# Convert to matrix


train.m <- data.matrix(train)

test.m <- data.matrix(test)

dtrain = xgb.DMatrix(data=train.m, 
                        label=train.y,
                        missing = NA)


dtest = xgb.DMatrix(data=test.m,
                       missing = NA)

xgb.DMatrix.save(dtrain,'project/volume/data/interim/train.data')

xgb.DMatrix.save(dtest,'project/volume/data/interim/test.data')
