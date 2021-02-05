library(data.table)
library(Metrics)
traindata <- fread('volume/data/external/Stat_380_train.csv')
testdata <-  fread('volume/data/external/Stat_380_test.csv')
# Null model 
setkey(traindata,SalePrice)

testdata$SalePrice <- mean(traindata$SalePrice)

submission <- testdata[,.(Id,SalePrice)]

write.csv(submission,'volume/data/processed/NullModel.csv',quote = FALSE,row.names = FALSE)

# Simple linear model based off of GrLivArea
setkey(traindata,SalePrice,GrLivArea)

# Create model 
model <- lm(SalePrice ~ GrLivArea,data=traindata)

# Check accuracy of model 
summary(model)

# Create predictions 

testdata$SalePrice <- predict(model,testdata)

submission <- testdata[,.(Id,SalePrice)]

write.csv(submission,'volume/data/processed/Submission1.csv',quote = FALSE,row.names = FALSE)
