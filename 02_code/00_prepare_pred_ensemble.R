path = "F:/orla/HCV_manuscript/"
source(file.path(path, "02_code/utils.R"))
data_tr <- readRDS(file.path(path, "01_data/gilead_train_pos_neg.rds"))
var_config <- read_csv(file.path(path, "01_data/meta_data/hcv_varconfig_flags.csv"))

#LR training predictions
pred_tr_LR <- read.csv(file.path(path, "03_results/LR/predictions_tr_lr_HCV_counts_flag_freq_1_50.csv"))
pred_tr_RF <- read.csv(file.path(path, "03_results/rf/predictions_tr_rf_HCV_counts_freq_1_50.csv"))
pred_tr_XGB <- read.csv(file.path(path, "03_results/xgboost/predictions_tr_xgb_HCV_counts_freq_1_50.csv"))