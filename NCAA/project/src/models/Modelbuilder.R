library(glmnet)
library(data.table)

set.seed(4765)

train <- fread("project/volume/data/interim/train3.csv")
test <- fread("project/volume/data/interim/test3.csv")

train <- train[,c("Season","Team1","Team2","DayNum"):= c(NULL,NULL,NULL,NULL)]

y = train$Result

train <- train[,Result:= NULL]

x = as.matrix(train)

model<- glmnet(x,y,family = "binomial",alpha = 0)

plot(model)

test.bm = as.matrix(test[,c("Season","Team1","Team2","DayNum"):= c(NULL,NULL,NULL,NULL)])

fit = min(model$lambda)

test <- fread("project/volume/data/interim/test3.csv")

test$Result <- predict(model,newx = test.bm,s = fit, type = "response")

test[, id := paste(Team1,"_",Team2,sep = "")]

test <- test[, .(id,Result)]

mean(test$Result)

fwrite(test,"project/volume/data/processed/Submission3.csv")