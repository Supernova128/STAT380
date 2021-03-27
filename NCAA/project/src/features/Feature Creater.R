library(data.table)
set.seed(4765)

# Train set
Season <- fread("project/volume/data/external/MDataFiles_Stage2/MRegularSeasonDetailedResults.csv")
Tourney <- fread("project/volume/data/external/MDataFiles_Stage2/MNCAATourneyDetailedResults.csv")
train <- rbind(Season,Tourney)
rm(Season,Tourney)

# Testing set
test <- fread("project/volume/data/external/MDataFiles_Stage2/MSampleSubmissionStage2.csv")
test <- test[,c("ID","Season","Team1","Team2","Pred") := list(
  NULL,
  as.numeric(gsub("_[^_]*_[^_]*$","",ID)),
  as.numeric(gsub("^[^_]*_|_[^_]*$","",ID)),
  as.numeric(gsub("^[^_]*_[^_]*_","",ID)),
  NULL)]

test$DayNum <- max(train[Season %in% test$Season]$DayNum) + 1


# Team stats 

source(file = "project/src/features/Team Stats.R")
# Massey stats 

Massey <- fread("project/volume/data/external/MDataFiles_Stage2/MMasseyOrdinals.csv")
train <- train[,c("Season","WTeamID","LTeamID","DayNum")]
source(file = "project/src/features/Masseyfeatures.R")

rm(test,train)

# Merge data sets from sections

mtest <- fread("project/volume/data/interim/Masseytest.csv")
mtrain <- fread("project/volume/data/interim/Masseytrain.csv")
stest <-fread("project/volume/data/interim/teamstattest.csv")
strain <- fread("project/volume/data/interim/teamstattrain.csv")

setkey(mtest,Season,Team1,Team2,DayNum)
setkey(stest,Season,Team1,Team2,DayNum)
setkey(mtrain,Season,WTeamID,LTeamID,DayNum)
setkey(strain,Season,WTeamID,LTeamID,DayNum)

test <- mtest[stest,nomatch = 0]

train <- mtrain[strain,nomatch = 0]

set.seed(4765)

samp<- sample(nrow(train), floor(nrow(train)/2))

Wtrain <- train[samp,]

Wtrain[,result := 1]

setnames(Wtrain, c("WTeamID","LTeamID"),c("Team1","Team2"))

Ltrain <- train[!samp,]

neg <- names(Ltrain)[-1:-4]

Ltrainids <- Ltrain[,1:4]

Ltrain <- cbind(Ltrainids,Ltrain[,lapply(.SD, function(x) -x ), .SDcols = neg])

Ltrain[,result := 0] 

setnames(Ltrain, c("WTeamID","LTeamID"),c("Team2","Team1"))

train <- rbind(Wtrain,Ltrain)
fwrite(test,"project/volume/data/interim/test_Complete")
fwrite(train,"project/volume/data/interim/train_Complete")
rm(Ltrain,Ltrainids,mtest,mtrain,stest,strain,test,train,Wtrain,neg,samp)










