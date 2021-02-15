library("data.table")
library("ISLR")


test <- fread('project/volume/data/raw/test_file.csv')

train <- fread('project/volume/data/raw/train_file.csv')




fwrite(test,'project/volume/data/interim/test.csv')

fwrite(train,'project/volume/data/interim/train.csv')