library(data.table)
set.seed(4765)

# Train set
Season <- fread("project/volume/data/external/Stage2DataFiles/RegularSeasonDetailedResults.csv")
Tourney <- fread("project/volume/data/external/Stage2DataFiles/NCAATourneyDetailedResults.csv")
train <- rbind(Season,Tourney)
rm(Season,Tourney)
test <- fread("project/volume/data/external/examp_sub.csv")
test <- test[,c("id","Season","Team1","Team2","DayNum","Result") := list(
  NULL,
  2019,
  as.numeric(gsub("_[^_]*$","",id)),
  as.numeric(gsub("^[^_]*_","",id)),
  131,
  NULL)]



# Testing set



Massey <- fread("project/volume/data/external/MasseyOrdinals_thru_2019_day_128/MasseyOrdinals_thru_2019_day_128.csv")
source(file = "project/src/features/Masseyfeatures.R")