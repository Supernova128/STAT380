library(data.table)
library(Metrics)
traindata <- fread('/project/volume/data/external/Stat_380_train.csv')
testdata <-  fread('/project//volume/data/external/Stat_380_test.csv')

# Models 

# Null model 
setkey(traindata,SalePrice)

testdata$SalePrice <- mean(traindata$SalePrice)

submission <- testdata[,.(Id,SalePrice)]

fwrite(submission,'/project/volume/data/processed/NullModel.csv')

# Simple linear model based off of GrLivArea
setkey(traindata,SalePrice,GrLivArea)

# Create model 
model <- lm(SalePrice ~ GrLivArea,data=traindata)

# Check accuracy of model 
summary(model)

# Create predictions 

testdata$SalePrice <- predict(model,testdata)

fwrite(testdata[,.(Id,SalePrice)],'/project/volume/data/processed/Submission1.csv')


