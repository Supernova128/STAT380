dir.create('data')
download.file(url="https://s3.amazonaws.com/stat.184.data/Flights/2008.csv",destfile='data/2008.csv', method='curl')
