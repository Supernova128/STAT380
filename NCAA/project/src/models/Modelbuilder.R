library(glmnet)
library(data.table)

set.seed(4765)

train <- fread("project/volume/data/interim/train_Complete")
test <- fread("project/volume/data/interim/test_Complete")

train <- train[,c("Season","Team1","Team2","DayNum"):= c(NULL,NULL,NULL,NULL)]

y = train[,result]

train <- train[,result:= NULL]

x = as.matrix(train)

modelR <- glmnet(x,y,family = "binomial",alpha = 0)
saveRDS(modelR,"project/volume/models/RidgeModel.rds")
modelL <- glmnet(x,y,family = "binomial",alpha = 1)
saveRDS(modelL,"project/volume/models/LassoModel.rds")

test.bm = as.matrix(test[,c("Season","Team1","Team2","DayNum"):= c(NULL,NULL,NULL,NULL)])

fitR = min(modelR$lambda)

fitL = min(modelL$lambda)

testR <- fread("project/volume/data/interim/test_Complete")

testL <- fread("project/volume/data/interim/test_Complete")

testR[,Pred := predict(modelR,newx = test.bm,s = fitR, type = "response")]

testL[,Pred := predict(modelL,newx = test.bm,s = fitL, type = "response")]


testR[, id := paste(Season,"_",Team1,"_",Team2,sep = "")]

testL[, id := paste(Season,"_",Team1,"_",Team2,sep = "")]

testR <- testR[, .(id,Pred)]

testL <- testL[, .(id,Pred)]

fwrite(testR,"project/volume/data/processed/SubmissionRidge.csv")
fwrite(testL,"project/volume/data/processed/SubmissionLasso.csv")

