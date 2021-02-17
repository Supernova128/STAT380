library('data.table')

train <- fread('project/volume/data/interim/train.csv')
test <- fread('project/volume/data/interim/test.csv')


model <- glm(result ~ total,family = binomial,data = train)

saveRDS(model,"./project/volume/models/Coin.model")

test$result <- predict(model,newdata = test, type = "response")

answers <- test[,.(id,result)]

fwrite(answers,'project/volume/data/processed/Submission3.csv')

rm(model,test,train,answers)

# Theoretical distribution 

tmodel <- as.data.table(list(0:10,seq(1/12,11/12,by = 1/12)))

setnames(tmodel,"V1","total")
setnames(tmodel,"V2","result")

test <- fread('project/volume/data/interim/test.csv')

tanswers <- merge.data.table(test,tmodel, by = "total")[,.(id,result)][order(id)]

fwrite(tanswers,'project/volume/data/processed/SubmissionT.csv')
