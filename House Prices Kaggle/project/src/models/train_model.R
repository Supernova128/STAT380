library(data.table)
library(Metrics)
library(caret)
library(xgboost)
set.seed(5431)

testdata <- fread('project/volume/data/external/Stat_380_test.csv')

dtrain <- xgb.DMatrix('./project/volume/data/interim/train.data')
dtest <-  xgb.DMatrix('./project//volume/data/interim/test.data')

hyper_parm_tune <- NULL
for (d in c(1,3,5)){
  for (e in c(0.01, 0.05, 0.01, 0.5)){
    myparam <- list(  objective           = "reg:squarederror",   #tells xgboost we're doing regression
                      gamma               = 0.02,        # minimum loss reduction required
                      booster             = "gbtree",    # the default
                      eval_metric         = "rmse",      # for the cv error
                      eta                 = e,        # (0,1) learning rate defaults to 0.3
                      # I am going to learn slower than the default
                      # the smaller you set eta, the larger you need to set B
                      max_depth           = 5,          # defaults to 6
                      # similar to eta, smaller max_depth means I have to set B to be larger
                      min_child_weight    = 1,      # min num of observations in each region
                      subsample           = 1.0,   
                      colsample_bytree    = 1.0, # ratio of predictors like in RF
                      tree_method         = 'hist'
    )
    # 
    # 0.001 0.002 0.003 0.004 # not a very good grid
    #set rnounds to a large value
    XGBfit <- xgb.cv( params = myparam,
                      nfold = 5,
                      nrounds = 100000,
                      missing = NA,
                      data = dtrain,
                      print_every_n = 1,    # so i can see the errors every step
                      early_stopping_rounds = 25
                      ) 
    best_tree_n <- unclass(XGBfit)$best_iteration
    new_row <- data.table(t(myparam))
    new_row$best_tree_n <- best_tree_n
    test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_rmse_mean
    new_row$test_error <- test_error
    hyper_parm_tune <- rbind(new_row, hyper_parm_tune)
  }
}

best <- hyper_parm_tune[test_error == min(test_error)]

params <- c(best[,.(objective,gamma,booster,eval_metric,eta,max_depth,
                  min_child_weight,subsample,colsample_bytree,tree_method)])


best_n <- best[,best_tree_n]

watchlist = list(train = dtrain)

XGBfit2 <- xgb.train(params = params,
                    nrounds = best_n,
                    missing = NA,
                    watchlist = watchlist,
                    data = dtrain,
                    print_every_n =  1)

testdata$SalePrice <- predict(XGBfit2,dtest)

fwrite(testdata[,.(Id,SalePrice)],'./project//volume/data/processed/Submission6.csv')