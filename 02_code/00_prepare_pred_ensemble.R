library(tidyverse)

path = "F:/orla/HCV_manuscript/"

data_tr <- readRDS(file.path(path, "01_data/gilead_train_pos_neg.rds"))


#LR training predictions
pred_tr_LR <- read.csv(file.path(path, "03_results/LR/final/predictions_tr_lr_HCV_counts_flags_freq_1_50.csv"))
pred_tr_RF <- read.csv(file.path(path, "03_results/rf/predictions_tr_rf_HCV_counts_freq_1_50.csv"))
pred_tr_XGB <- read.csv(file.path(path, "03_results/xgboost/predictions_tr_xgb_HCV_counts_freq_1_50.csv"))

#create joined predictions data frame with patient ids and matching ids
xp_tr <- cbind(select(data_tr, Patient_Id, test_patient_id, label), pred_tr_LR$prob.1,pred_tr_RF$prob.1,pred_tr_XGB$prob.1)
xp_tr <- xp_tr %>% 
  rename(pred_LR= `pred_tr_LR$prob.1`,
         pred_RF= `pred_tr_RF$prob.1`,
         pred_XGB= `pred_tr_XGB$prob.1`)

write_rds(xp_tr, file.path(path, "/01_data/ensemble_lr_rf_xgb_tr.rds"))

#hold out data

data_ts <- readRDS(file.path(path, "01_data/gilead_holdout1_pos_neg.rds"))


#LR training predictions
pred_ts_LR <- read.csv(file.path(path, "03_results/LR/final/predictions_ts_lr_HCV_counts_flags_freq_1_50.csv"))
pred_ts_RF <- read.csv(file.path(path, "03_results/rf/predictions_ts_rf_HCV_counts_freq_1_50.csv"))
pred_ts_XGB <- read.csv(file.path(path, "03_results/xgboost/predictions_ts_xgb_HCV_counts_freq_1_50.csv"))

#create joined predictions data frame with patient ids and matching ids
xp_ts <- cbind(select(data_ts, Patient_Id, test_patient_id, label), pred_ts_LR$prob.1,pred_ts_RF$prob.1,pred_ts_XGB$prob.1)

xp_ts <- xp_ts %>% 
  rename(pred_LR= `pred_ts_LR$prob.1`,
         pred_RF= `pred_ts_RF$prob.1`,
         pred_XGB= `pred_ts_XGB$prob.1`)

write_rds(xp_ts, file.path(path, "/01_data/ensemble_lr_rf_xgb_ho1.rds"))
