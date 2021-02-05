library(data.table)
library(Metrics)
library(caret)
traindata <- fread('./project/volume/data/external/Stat_380_train.csv')
testdata <-  fread('./project/volume/data/external/Stat_380_test.csv')
# Save saleprice data 

traindata_y <- traindata$SalePrice

# Add Saleprice column to testdata 

testdata$SalePrice <- mean(traindata_y)

# Changes NAs to 0

traindata[is.na(traindata)] <- 0

testdata[is.na(testdata)] <- 0

dummies <- dummyVars(SalePrice ~ ., data = traindata)

traindata <- data.table(predict(dummies, newdata = traindata))

traindata$SalePrice <- traindata_y

testdata <- data.table(predict(dummies, newdata = testdata))
rm(traindata_y)


fwrite(traindata,'./project/volume/data/interim/train.csv')

fwrite(testdata,'./project/volume/data/interim/test.csv')
