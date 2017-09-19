data_path <- "Z:/"
pos_tr <- read.csv(file.path(data_path, "pos_cohort_20170315/poscoh_80perc_consumer_v1.csv"), nrows = 1000)

neg_tr <- read.csv(file.path(data_path, "neg_cohort_20170328/negcoh_perc80_20170320.csv"), nrows=1000)

setdiff(names(pos_tr), names(neg_tr))

setdiff(names(neg_tr), names(pos_tr))
