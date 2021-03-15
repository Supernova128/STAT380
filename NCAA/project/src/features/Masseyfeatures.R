library(data.table)
library(caret)
set.seed(4765)
# Code for the example submission from google

# test <- Example[,c("Season","Team1","Team2","ID") := list(
#   as.numeric(gsub("_[^_]*_[^_]*$","",ID)),
#   as.numeric(gsub("^[^_]*_|_[^_]*$","",ID)),
#   as.numeric(gsub("^[^_]*_[^_]*_","",ID)),
#   gsub("^[^_]*_","",ID))]

# Filter Massey rankings 

# Adding latest Massey data to data sets

# Set keys 

setkey(Massey, Season,RankingDayNum, TeamID)

# Recast the data

Masseycasted <- dcast(Massey,  Season + RankingDayNum + TeamID ~ SystemName,value.var = "OrdinalRank")
rankings = c("POM","PIG","SAG","MOR","DOK")
keep = c(c("Season", "RankingDayNum", "TeamID",rankings))

Masseycasted <- Masseycasted[,keep,with=F]

setnames(Masseycasted,make.names(colnames(Masseycasted)))

rm(Massey)

# Add Massy data to training and testing data sets

# Set keys 
setkey(Masseycasted,Season,TeamID,RankingDayNum)

# Rolling Join

getdiff <- function(season,Daynum,WTeamID,LTeamID){
  vec1 = unlist(Masseycasted[Season == season & RankingDayNum < Daynum & TeamID == WTeamID,rankings,with=F][, lapply(.SD, function(x) tail(x[!is.na(x)],1))])
  vec2 = unlist(Masseycasted[Season == season & RankingDayNum < Daynum & TeamID == LTeamID,rankings,with=F][, lapply(.SD, function(x) tail(x[!is.na(x)],1))])
  if(length(vec1) == 0 | length(vec2) == 0){
    return(setNames(rep(NA,length(rankings)),rankings))
  }
  return(vec1-vec2)
}

temp <- t(mapply(getdiff,season = test$Season,Daynum = test$DayNum, WTeamID = test$Team1, LTeamID = test$Team2))

mtest <- cbind(test,temp)

temp <- t(mapply(getdiff,season = train$Season,Daynum = train$DayNum, WTeamID = train$WTeamID, LTeamID = train$LTeamID))

mtrain <- cbind(train,temp)

mtrain <- na.omit(mtrain)

fwrite(mtest,"project/volume/data/interim/Masseytest.csv")

fwrite(mtrain,"project/volume/data/interim/Masseytrain.csv")

rm(Masseycasted,mtest,mtrain,temp,keep,rankings,getdiff)

