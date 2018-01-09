library(tidyverse)
path = "F:/orla/HCV_manuscript/"

data_ho1 <- readRDS(file.path(path, "01_data/gilead_holdout1_pos_neg.rds"))
neg <- data_ho1 %>% filter(label==0)
pos <- data_ho1 %>% filter(label==1)

neg_100 <- neg %>%
  group_by(test_patient_id) %>%
  sample_n(.,100)

data_ho1_100 <- bind_rows(pos,neg_100)

write_rds(data_ho1_100, paste0(path, "01_data/gilead_holdout1_pos_neg_100.rds"))


data_ho1 <- readRDS(file.path(path, "01_data/gilead_holdout2_pos_neg.rds"))
neg <- data_ho1 %>% filter(label==0)
pos <- data_ho1 %>% filter(label==1)

neg_100 <- neg %>%
  group_by(test_patient_id) %>%
  sample_n(.,100)

data_ho1_100 <- bind_rows(pos,neg_100)

write_rds(data_ho1_100, paste0(path, "01_data/gilead_holdout2_pos_neg_100.rds"))
