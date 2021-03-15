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

# Clean column names for mice

setnames(Masseycasted,make.names(colnames(Masseycasted)))

rm(Massey)

# Add Massy data to training and testing data sets

# Function needed
Lastnotnull <- function(vector) {
  for (i in length(vector):1){
    if (!is.null(vector[i])){
      return(vector[i])
    }
  }
  return(NULL)
}

# Test Set new row

test[,Rollday := DayNum]

# Set keys 
setkey(Masseycasted,Season,TeamID,RankingDayNum)

# Rolling Join

setkey(test, Season,Team1,Rollday)

Team1T <- test[Masseycasted,nomatch = 0,roll = -Inf]

rankings <- names(Team1T)[-1:-5]

# Save most recent data for each team

Team1T <- Team1T[, lapply(.SD,Lastnotnull), by = c("Season","Team1","Team2","DayNum"),.SDcols = rankings]

setkey(test, Season,Team2,Rollday)

Team2T <- test[Masseycasted,nomatch = 0, roll = -Inf]

rankings <- names(Team2T)[-1:-5]

Team2T <- Team2T[, lapply(.SD,Lastnotnull), by = c("Season","Team1","Team2","DayNum"),.SDcols = rankings]


# Merge the 2 data tables together

test <- Team1T[Team2T, 
                on = c("Season","Team1","Team2","DayNum"),
                nomatch = 0,
                lapply(
                  setNames(rankings, rankings),
                  function(x) get(x) - get(paste0("i.", x))
                ),
                by = .EACHI]

rm(Team1T,Team2T)

# Train set

train[, RollDay := DayNum - 1]

setkey(train, Season,WTeamID,RollDay)

trainW <- train[Masseycasted,nomatch = 0, roll = T]

trainW <- trainW[, lapply(.SD,Lastnotnull), by = c("Season","WTeamID","LTeamID","DayNum"),.SDcols = rankings]

setkey(train, Season,LTeamID,RollDay)

trainL <- train[Masseycasted,nomatch = 0, roll = -Inf]

trainL <- trainL[, lapply(.SD,Lastnotnull), by = c("Season","WTeamID","LTeamID","DayNum"),.SDcols = rankings]


train1 <- trainW[trainL, 
               on = c("Season","WTeamID","LTeamID","DayNum"),
               nomatch = 0,
               lapply(
                 setNames(rankings, rankings),
                 function(x) get(x) - get(paste0("i.", x))
               ),
               by = .EACHI]


setnames(train1,c("WTeamID","LTeamID"),c("Team1","Team2"))

train1$Result = 1

train2 <- trainW[trainL, 
                 on = c("Season","WTeamID","LTeamID","DayNum"),
                 nomatch = 0,
                 lapply(
                   setNames(rankings, rankings),
                   function(x) get(paste0("i.", x)) - get(x)
                 ),
                 by = .EACHI]

setnames(train2,c("WTeamID","LTeamID"),c("Team2","Team1"))

train2$Result = 0

train <- rbind(train1,train2)

rm(train1,train2,trainL,trainW)

# Remove rankings in the test set with any NAs

test <- test[,which(unlist(lapply(test, function(x)!any(is.na(x))))),with=FALSE]

keep = c(names(test),"Result")

train <- train[, ..keep]

train <- na.omit(train)

fwrite(test,"project/volume/data/interim/test4.csv")

fwrite(train,"project/volume/data/interim/train4.csv")

fwrite(list(names(test)),"project/volume/data/interim/rankingkeep.csv")



