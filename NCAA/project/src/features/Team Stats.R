library(data.table)

set.seed(4765)

# Get variable names needed

n = names(train)

winning = c("Season","DayNum",n[substr(n,1,1) == "W"])

winning = winning[winning != "WLoc"]

losing = c("Season","DayNum",n[substr(n,1,1) == "L"])

# Filter data sets

Wteam <- train[,winning,with=F]

Lteam <- train[,losing,with=F]

# Rename data sets

range = 1:length(winning)

winning2 = replace(winning,range ,ifelse(substr(winning,1,1) == "W",substr(winning,2,length(winning)),winning))

losing2 = replace(losing,range ,ifelse(substr(losing,1,1) == "L",substr(losing,2,length(losing)),losing))

setnames(Wteam,winning,winning2)

setnames(Lteam,losing,losing2)

master_stats <- rbind(Wteam,Lteam)

rm(n,losing,losing2,winning,range,winning2,Wteam,Lteam)

# Loop for stats by day

`%notin%` <- Negate(`%in%`)

stats = names(Lteam)[names(Lteam) %notin%  c("Season","DayNum","TeamID")]

stats_by_day<-NULL

for (i in 1:max(master_stats$DayNum)){
  
  sub_master_stats<-master_stats[DayNum < i]
  
  team_stats_by_day <- dcast(sub_master_stats, TeamID+Season~.,mean,value.var=stats)
  
  team_stats_by_day$DayNum <- i
  stats_by_day<-rbind(stats_by_day,team_stats_by_day)
}
rm(sub_master_stats,team_stats_by_day,i)
stats_by_day$DayNum <- stats_by_day$DayNum + 1

train <- train[, c("Season","DayNum","WTeamID","LTeamID")]

getdiff <- function(season,Daynum,WTeamID,LTeamID){
  vec1 = unlist(stats_by_day[Season == season & DayNum == Daynum & TeamID == WTeamID,stats,with=F][1])
  vec2 = unlist(stats_by_day[Season == season & DayNum == Daynum & TeamID == LTeamID,stats,with=F][1])
  if(length(vec1) == 0 | length(vec2) == 0){
    return(setNames(rep(NA,length(stats)),stats))
  }
  return(vec1-vec2)
}


temp <- t(mapply(getdiff,season = train$Season,Daynum = train$DayNum, WTeamID = train$WTeamID, LTeamID = train$LTeamID))

train <- cbind(train,temp)

train <- na.omit(train)

temp <- t(mapply(getdiff,season = test$Season,Daynum = test$DayNum, WTeamID = test$Team1, LTeamID = test$Team2))

test <- cbind(test,temp)
