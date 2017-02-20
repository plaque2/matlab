CalcFudgeAxis = function( y1, y2=y1) {
  Cast2To1 = function(x) ((ylim1[2]-ylim1[1])/(ylim2[2]-ylim2[1])*x) # x gets mapped to range of ylim2
  ylim1 <- c(min(y1),max(y1))
  ylim2 <- c(min(y2),max(y2))    
  yf <- Cast2To1(y2)
  labelsyf <- pretty(y2)  
  return(list(
    yf=yf,
    labels=labelsyf,
    breaks=Cast2To1(labelsyf)
  ))
}