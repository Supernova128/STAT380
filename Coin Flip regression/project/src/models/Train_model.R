library('tidyverse')

train <- read.csv('project/volume/data/raw/train_file.csv')
test <- read.csv('project/volume/data/raw/test_file.csv')


model <- train %>%
  group_by(V1,V2,V3,V4,V5,V6,V7,V8,V9,V10) %>%
  summarise(result = sum(result)/n()) %>%
  distinct()

answers<- 
  test %>%
  left_join(model) %>%
  select(id,result)

write_csv(answers,'project/volume/data/processed/Submission1.csv')