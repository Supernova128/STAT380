library(data.table)
library(Metrics)
library(caret)
traindata <- fread('./project/volume/data/interim/train.csv')
testdata <-  fread('./project//volume/data/interim/test.csv')



model <- lm(SalePrice ~ .,data=traindata)

summary(model)

testdata$SalePrice <- predict(model,testdata)

fwrite(testdata[,.(Id,SalePrice)],'./project//volume/data/processed/Submission2.csv')