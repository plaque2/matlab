assignLayoutAntiVir <- function(cpout, treatment){
  
  # load layout
  treatment <- read.csv(treatment, header=T)
  
  # assign proper header to layout table
  library(stringr)
  names <- c('row', str_pad(seq(24), 2, pad="0"))
  names(treatment)=names
  treatment
  
  #assign treatment
  for (well in unique(cpout$well)) {
    value <- treatment[treatment$row==substr(well, 1, 1), substr(well, 2, 3)]
    cpout[cpout$well==well, 'treatment'] <- as.character(value)
  }
  cpout$treatment <- factor(cpout$treatment)
  return(cpout)
}
