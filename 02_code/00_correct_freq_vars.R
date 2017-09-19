

path = "F:/orla/HCV_manuscript/"

var_config <- read_csv(file.path(path, "01_data/meta_data/hcv_varconfig_counts_freq_flags.csv"))
cap_non_zero_numeric_to_p99 <- function(col){
  pos_col = col[pos_mask]
  non_zero_col = pos_col[pos_col != 0 ]
  non_missing = non_zero_col[!is.na(non_zero_col)]
  p99 = quantile(non_missing, probs = seq(0,1,.01))[100]
  col[col > p99] = p99
  col
}

data <- readRDS(file.path(path, "01_data/gilead_train_pos_neg.rds"))
freq_vars = grep("_ave_", colnames(data))
# multiply the negative freq by 365 so they reflect freq per year
data[data$label==0, freq_vars] = data[data$label==0, freq_vars] * 365

num_cols = var_config %>% 
  filter_(~Column %in% colnames(data)) %>% 
  filter(Type=="numerical") %>%
  select(Column)
num_cols = num_cols$Column

pos_mask = data$label == 1
num_capped = data.frame(lapply(data[, num_cols], cap_non_zero_numeric_to_p99))
data[,num_cols] <- num_capped

write_rds(data, file.path(path, "01_data/gilead_train_pos_neg.rds"))


data <- readRDS(file.path(path, "01_data/gilead_holdout1_pos_neg.rds"))
freq_vars = grep("_ave_", colnames(data))
# multiply the negative freq by 365 so they reflect freq per year
data[data$label==0, freq_vars] = data[data$label==0, freq_vars] * 365
num_cols = var_config %>% 
  filter_(~Column %in% colnames(data)) %>% 
  filter(Type=="numerical") %>%
  select(Column)
num_cols = num_cols$Column

pos_mask = data$label == 1
num_capped = data.frame(lapply(data[, num_cols], cap_non_zero_numeric_to_p99))
data[,num_cols] <- num_capped
write_rds(data, file.path(path,"01_data/gilead_holdout1_pos_neg.rds"))

data <- readRDS(file.path(path, "01_data/gilead_holdout2_pos_neg.rds"))
freq_vars = grep("_ave_", colnames(data))
# multiply the negative freq by 365 so they reflect freq per year
data[data$label==0, freq_vars] = data[data$label==0, freq_vars] * 365
num_cols = var_config %>% 
  filter_(~Column %in% colnames(data)) %>% 
  filter(Type=="numerical") %>%
  select(Column)
num_cols = num_cols$Column

pos_mask = data$label == 1
num_capped = data.frame(lapply(data[, num_cols], cap_non_zero_numeric_to_p99))
data[,num_cols] <- num_capped
write_rds(data, file.path(path,"01_data/gilead_holdout2_pos_neg.rds"))



