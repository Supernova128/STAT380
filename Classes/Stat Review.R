# Stat 380 review, data wrangling 
rm(list = ls())

dir.create('data')
download.file(url="https://s3.amazonaws.com/stat.184.data/Flights/2008.csv",destfile='data/2008.csv', method='curl')


require(data.table)

# Load Data
dat <- fread('./data/2008.csv')


# Useful functions 
# dat[i,j,by]
# dim(dat)

# Def. Filter - subsetting or removing observations based on some conditions.

newdat <- dat[DepDelay > 0]

newdat <- dat[Dest == 'TPA']

# You can combine multiple filters 

newdat <- dat[DepDelay > 0 & Dest == 'TPA']

# And get the information about the table 

dat[DepDelay > 0 & Dest == 'TPA', length(NASDelay)]

# Special Function .N gets sample size. 
dat[DepDelay > 0 & Dest == 'TPA', .N]