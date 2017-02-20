assignLayoutAntiVir <- function(plaqueOut, treatment){
  
  # load layout
  treatment <- read.csv(treatment, header=T)
  
  # assign proper header to layout table
  library(stringr)
  names <- c('row', str_pad(seq(24), 2, pad="0"))
  names(treatment)=names
  treatment
  
  #assign treatment
  for (well in unique(plaqueOut$well)) {
    value <- treatment[treatment$row==substr(well, 1, 1), substr(well, 2, 3)]
    plaqueOut[plaqueOut$well==well, 'treatment'] <- as.character(value)
  }
  plaqueOut$treatment <- factor(plaqueOut$treatment)
  return(plaqueOut)
}
