summary_table <- function(data){
  res<- data.frame(matrix(ncol=3, nrow=5))
  colnames(res) <- c("Variable", "HCV", "non-HCV")
  #counts
  res[1,1] <- "Patient counts"
  res[1,2] <- sum(data$label==1)
  res[1,3] <- sum(data$label==0)
  
  #age
  res[2,1] <- "Age"
  res[2,2] <- paste0(round(mean(data$PATIENT_AGE[data$label==1]),1),
                     " +/- ", round(sd(data$PATIENT_AGE[data$label==1]),1))
  res[2,3] <- paste0(round(mean(data$PATIENT_AGE[data$label==0]),1),
                     " +/- ", round(sd(data$PATIENT_AGE[data$label==0]),1))
  
  #gender
  res[3,1] <- "Gender"
  res[3,2] <- paste0("M: ", round(100*(sum(data$PAT_GENDER_CD[data$label==1] == "M")/sum(data$label==1)),1),
                     "% , F: ",round(100*(sum(data$PAT_GENDER_CD[data$label==1] == "F")/sum(data$label==1)),1), "%")
  res[3,3] <-paste0("M: ", round(100*(sum(data$PAT_GENDER_CD[data$label==0] == "M")/sum(data$label==0)),1),
                    "% , F: ",round(100*(sum(data$PAT_GENDER_CD[data$label==0] == "F")/sum(data$label==0)),1), "%")
  
  #treated for HCV
  res[3,1] <- "Treated for HCV"
  res[3,2] <- paste(round(100*sum(data$TREAT_FOR_HCV[data$label == 1]==1)/data$label==1,1), "%")
  res[3,3] <- paste(round(100*sum(data$TREAT_FOR_HCV[data$label == 0]==1)/data$label==0,1), "%")
  return(res)
}
  

get_curve <- function(prob, truth, x_metric, y_metric){
  if(length(prob) != length(truth)){
    stop("Length of prob and truth should be the same!")
  }
  
  # This was originally based on Hui's code
  aucobj <- ROCR::prediction(prob, truth)
  perf <- ROCR::performance(aucobj, y_metric, x_metric)
  x <- perf@x.values[[1]]
  y <- perf@y.values[[1]]
  thresh <- perf@alpha.values[[1]]
  
  # Ignore nans and inf
  non_nan <- (!is.nan(x) & !is.nan(y) & !is.nan(thresh) & !is.infinite(x) &
                !is.infinite(y) & !is.infinite(thresh))
  x <- x[non_nan]
  y <- y[non_nan]
  thresh <- thresh[non_nan]
  
  # Make and return df
  data.frame(x=x, y=y, thresh=thresh)
}


bin_curve <- function(curve_df, bin_num, agg_func=mean){
  curve_df <- curve_df %>%
    dplyr::group_by(x_binned=cut(x, breaks = seq(0, 1, by=1/bin_num))) %>%
    dplyr::summarise_each(funs(agg_func(., na.rm = TRUE)))
  # move x_binned column to the end
  curve_df <- curve_df[, c(2,3,4,1)]
}

perf_binned_perf_curve <- function(pred, bin_num = 20, x_metric = "rec",
                                   y_metric = "prec", agg_func = mean, subdiv=200){
  # get probabilities and truth
  tp <- palabmod:::get_truth_pred(pred)
  # compute and bin curve
  curve_df <- palabmod:::get_curve(tp$prob, tp$truth, x_metric, y_metric)
  # get auc
  auc <- palabmod:::auc_curve(curve_df, subdiv)
  curve_df <- palabmod:::bin_curve(curve_df, bin_num, agg_func)
  # prepare df that we return
  curve_df <- as.data.frame(curve_df[,c("x_binned", "y", "thresh")])
  colnames(curve_df) <- c(paste(x_metric, "_binned", sep=""), y_metric, "thresh")
  return(list(curve=curve_df, auc=auc))
}
