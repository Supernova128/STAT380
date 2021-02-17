library('data.table')

train <- fread('project/volume/data/interim/train.csv')
test <- fread('project/volume/data/interim/test.csv')


model <- glm(result ~ total,family = binomial,data = train)

saveRDS(model,"./project/volume/models/Coin.model")

test$result <- predict(model,newdata = test, type = "response")

answers <- test[,.(id,result)]

fwrite(answers,'project/volume/data/processed/Submission3.csv')