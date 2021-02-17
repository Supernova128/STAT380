library("data.table")
library("ISLR")


test <- fread('project/volume/data/raw/test_file.csv')

train <- fread('project/volume/data/raw/train_file.csv')

test <- test[,total := V1 + V2 + V3 + V4 + V5 + V6 + V7 + V8 + V9 + V10][,.(id,total)]
train <- train[,total := V1 + V2 + V3 + V4 + V5 + V6 + V7 + V8 + V9 + V10][,.(id,total,result)]

fwrite(test,'project/volume/data/interim/test.csv')

fwrite(train,'project/volume/data/interim/train.csv')