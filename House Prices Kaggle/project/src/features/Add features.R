library(data.table)
library(Metrics)
library(caret)
library(xgboost)


traindata <- fread('./project/volume/data/external/Stat_380_train.csv')
testdata <-  fread('./project/volume/data/external/Stat_380_test.csv')
# Save saleprice data 

traindata_y <- traindata$SalePrice

# Add Saleprice column to testdata 

testdata$SalePrice <- mean(traindata_y)

# Dummy Vars

dummies <- dummyVars(SalePrice ~ ., data = traindata)

traindata <- data.table(predict(dummies, newdata = traindata))

testdata <- data.table(predict(dummies, newdata = testdata))

traindata <- sapply(traindata, as.numeric)

testdata <- sapply(testdata, as.numeric)


dtrain <- xgb.DMatrix(traindata,
                      label = traindata_y,
                      missing = NA)

dtest <- xgb.DMatrix(testdata,
                     missing = NA)



xgb.DMatrix.save(dtrain,'project/volume/data/interim/train.data')

xgb.DMatrix.save(dtest,'project/volume/data/interim/test.data')
