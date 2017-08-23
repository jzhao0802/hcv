#library(palab)
library(dplyr)
library(stringr)

# ----------------------------------------------------------------------------
# Read in positive cohort
# ----------------------------------------------------------------------------

# Commonly used variables
data_loc = data_path <- "Z:/"

#pos_all <- read.csv(str_c(data_loc, "poscoh_80perc_consumer_v1.csv"),
#                     na.strings = c(".", " "))
# saveRDS(pos_all, str_c(data_loc, "poscoh_80perc_consumer_v1.rds"))
pos_all <- readr::read_rds(file.path(data_path, "pos_cohort_20170315/poscoh_20perc_consumer_v1.rds"))

pos_all <- pos_all %>%
  select(-OVERALL_COUNT_OF_PREDICTORS) %>%
  rename(
    COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`,
    COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`,
    CLAIM_COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `CLAIM_COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`,
    CLAIM_COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `CLAIM_COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`,
    VIRAL_HEPATITIS__NON_C__DX_flag = `VIRAL_HEPATITIS_.NON_C._DX_flag`,
    VIRAL_HEPATITIS__NON_C__DX_claims_count = `VIRAL_HEPATITIS_.NON_C._DX_claims_count`,
    VIRAL_HEPATITIS__NON_C__DX_ave_claims_count = `VIRAL_HEPATITIS_.NON_C._DX_ave_claims_count`,
    VIRAL_HEPATITIS__NON_C__DX_first_expdt = `VIRAL_HEPATITIS_.NON_C._DX_first_expdt`,
    CHILDREN = CHILDREN.,
    ALCOHOL_OPIOID_ABUSE_NDC_PROC_flag = ALCOHOL_OPIOID.ABUSE_NDC_PROC_flag,
    ALCOHOL_OPIOID_ABUSE_NDC_PROC_claims_count = ALCOHOL_OPIOID.ABUSE_NDC_PROC_claims_count,
    ALCOHOL_OPIOID_ABUSE_NDC_PROC_ave_claims_count = ALCOHOL_OPIOID.ABUSE_NDC_PROC_ave_claims_count,
    ALCOHOL_OPIOID_ABUSE_NDC_PROC_first_expdt = ALCOHOL_OPIOID.ABUSE_NDC_PROC_first_expdt,
    PEPTIC_ULCER_DISEASE_GE_REFLUX_NDC_flag = PEPTIC.ULCER.DISEASE_GE.REFLUX_NDC_flag,
    PEPTIC_ULCER_DISEASE_GE_REFLUX_NDC_claims_count = PEPTIC.ULCER.DISEASE_GE.REFLUX_NDC_claims_count ,
    PEPTIC_ULCER_DISEASE_GE_REFLUX_NDC_ave_claims_count = PEPTIC.ULCER.DISEASE_GE.REFLUX_NDC_ave_claims_count ,
    PEPTIC_ULCER_DISEASE_GE_REFLUX_NDC_first_expdt = PEPTIC.ULCER.DISEASE_GE.REFLUX_NDC_first_expdt,
    OVERALL_COUNT_OF_PREDICTORS = historic_pred_count
  )
pos_all <- pos_all %>%
  mutate(
    label = 1L,
    COUNT_OF_ANY_HCV_TREATMENT = NA,
    COUNT_OF_HCV_DIAGNOSIS = NA,
    COUNT_OF_ONLY_HCV_INDICATED_TREATMENT = NA,
    CLAIM_COUNT_OF_HCV_DIAGNOSIS = NA,
    CLAIM_COUNT_OF_ANY_HCV_TREATMENT = NA,
    CLAIM_COUNT_OF_ONLY_HCV_INDICATED_TREATMENT = NA,
    test_patient_id = NA
  ) 



# ----------------------------------------------------------------------------
# read in negative cohort
# ----------------------------------------------------------------------------

rr <- readr::read_csv(file.path(data_path, "neg_cohort_20170328/negcoh_perc20_20170320.csv"))
#rr <- readr::read_rds(file.path(data_path, "neg_cohort_20170320/negcoh_perc20_20170320_renamed.rds"))
#saveRDS(rr, str_c(data_loc, "negcoh_perc80_20170320_renamed.rds"))
#rr <- readRDS(str_c(data_loc, "negcoh_perc80_20170320_renamed.rds"))

# Rename bad varaibles

rr <- rr %>%
  rename(
    Patient_Id = control_patient_id,
    DX_FLAG = dx_flag,
    LRX_FLAG = lrx_flag,
    COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`,
    COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`,
    CLAIM_COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `CLAIM_COUNT_OF_TX_PROC_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`,
    CLAIM_COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK_FACTORS = `CLAIM_COUNT_OF_TX_FOR_MISDIAGNOSIS_COMORBIDITIES_SYMPTOMS_RISK.FACTORS`
  )
rr <- rr %>%
  mutate(
    label = 0L,
    TREAT_FOR_HCV = NA
  )

#split the positive cohort into two hold out partitions
ix_pos <- rep(1:nrow(pos_all))
set.seed(123, "L'Ecuyer")
shuffled_ix_pos <- sample(ix_pos)
ix_split1 <- shuffled_ix_pos[1:12002]
ix_split2 <- shuffled_ix_pos[12003:24005]
pos_all_1 <- pos_all[ix_split1,]
pos_all_2 <- pos_all[ix_split2,]


pos_match_1 <- pos_all_1 %>% select(Patient_Id) %>% rename(test_patient_id = Patient_Id)
rr_match_2<- merge(rr, pos_match_1, by = "test_patient_id", all.y = TRUE)

# ----------------------------------------------------------------------------
# Set training pos and training negative together
# ----------------------------------------------------------------------------

setdiff(colnames(pos_all_1), colnames(rr_match_1))

# [1] "DIAGNOSED"           "TREAT_FOR_OTHER"     "FIRST_HCV_Expo_Date"

setdiff(colnames(rr_match_1), colnames(pos_all_1))

# [1] "test_patient_id" "X"               "lookback_date_1" "lookback_date_2" "index_date"


# Find common cols
common_cols <- intersect(colnames(pos_all_1), colnames(rr_match_1))

# Bind the two together
gilead_test1 <- rbind(
  pos_all_1[common_cols],
  rr_match_1[common_cols]
)

saveRDS(gilead_test1, "F:/orla/HCV_manuscript/01_data/gilead_holdout1_pos_neg.rds")
#write.csv(common_cols, "F:/Projects/Gilead/data/combined_20170320/gilead_test3_var_config.csv")


# Select only those matched to the remaining positve patients
pos_match_2 <- pos_all_2 %>% select(Patient_Id) %>% rename(test_patient_id = Patient_Id)
rr_match_2<- merge(rr, pos_match_2, by = "test_patient_id", all.y = TRUE)

# ----------------------------------------------------------------------------
# Set training pos and training negative together
# ----------------------------------------------------------------------------

setdiff(colnames(pos_all_2), colnames(rr_match_2))

# [1] "DIAGNOSED"           "TREAT_FOR_OTHER"     "FIRST_HCV_Expo_Date"

setdiff(colnames(rr_match_2), colnames(pos_all_2))

# [1] "test_patient_id" "X"               "lookback_date_1" "lookback_date_2" "index_date"


# Find common cols
common_cols <- intersect(colnames(pos_all_2), colnames(rr_match_2))

# Bind the two together
gilead_test2 <- rbind(
  pos_all_2[common_cols],
  rr_match_2[common_cols]
)

saveRDS(gilead_test2, "F:/orla/HCV_manuscript/01_data/gilead_holdout2_pos_neg.rds")
#write.csv(common_cols, "F:/Projects/Gilead/data/combined_20170320/hcv_var_config.csv")
