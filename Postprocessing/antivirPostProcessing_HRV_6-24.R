# Postprocessing of AntiVir Plaque 2.0 analysis and plotting
# Written by Fanny Georgi qand Luca Murer
# Last edit 20171013 by Fanny Georgi

# Prerequisites: 
# install.packages('gtools'), etc
# 1- Run Plaque 2.0 analysis using FG's commit from 20171013
# 2- Generate plate layout file following v(\\d*)_n(\\w*)_m(\\d*.?\\d*) and title Z(.+)_p(.+)_s(.+)_v(.+)_d(.+).csv

# Bugs:
# - Axis height of double y plots off

# To do:
# - export overview numbers to .csv
# - total plaque area as parameter

# Define Functions  -----------------------------------------------------------------------------------------------------------------------

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

minMaxNormalize <- function(x){
  a <- min(x)
  b <- max(x)
  (x - a)/(b - a) 
}

zFactor <- function(parameter, negative, positive, substractor) {
  parameter = parameter - substractor
  plaqueOut$parameterNormalized = minMaxNormalize(parameter)
  negativeMean = mean(plaqueOut[plaqueOut$drug == negative , 'parameterNormalized'])
  positiveMean = mean(plaqueOut[plaqueOut$drug == positive , 'parameterNormalized'])
  negativeSTD = sd(plaqueOut[plaqueOut$drug == negative , 'parameterNormalized'])
  positiveSTD = sd(plaqueOut[plaqueOut$drug == positive , 'parameterNormalized'])
  
  zFactor3 = 1 - (3 * (positiveSTD + negativeSTD) / abs(positiveMean - negativeMean))
  zFactor2 = 1 - (2 * (positiveSTD + negativeSTD) / abs(positiveMean - negativeMean))
  
  return(zFactor3)
}

# Groundwork ------------------------------------------------------------------------------------------------------------------------------
library(stringr)

# User input
plaqueOutputFile <- 'N:/antivir_screen/6-prestwick/6-19-24_HRV_Z_a-b/Results/170915-6-24-HRV-pZ-b_Plate_832_ImageData.csv'
layoutFile <- 'N:/antivir_screen/6-prestwick/6-19-24_HRV_Z_a-b/Parameters/Zb_p6_sBSF018109_vHRV_d1e5.csv'
plateName = str_match(plaqueOutputFile, '(^.*/(.+)_ImageData.csv$)')[,3]
head(plateName)
virusName = str_match(layoutFile, '(^.*/Z(.+)_p(.+)_s(.+)_v(.+)_d(.+).csv$)')[,6]
head(virusName)
virusDilution = str_match(layoutFile, '(^.*/Z(.+)_p(.+)_s(.+)_v(.+)_d(.+).csv$)')[,7]
head(virusDilution)
establishmentPlateNumber = str_match(layoutFile, '(^.*/Z(.+)_p(.+)_s(.+)_v(.+)_d(.+).csv$)')[,4]
head(establishmentPlateNumber)
imagingPlateNumber = str_match(plaqueOutputFile, '(^.*/(.+)_Plate_(.+)_ImageData.csv$)')[,4]
head(imagingPlateNumber)
zPlateNumber = str_match(layoutFile, '(^.*/Z(.+)_p(.+)_s(.+)_v(.+)_d(.+).csv$)')[,3]
head(zPlateNumber)

# Output setup
plotTitle = '\n BafA: HRV-16-GFP (1:100,000),\n 2 dpi on HOG'
outputPlotDirectory <- 'N:/antivir_screen/6-prestwick/6-19-24_HRV_Z_a-b/Results/postprocessed/Graphs/' 
outputPlotNameBase <- paste(virusName, zPlateNumber, virusDilution, sep="_")
outputAnalysisDirectory <- 'N:/antivir_screen/6-prestwick/6-19-24_HRV_Z_a-b/Results/postprocessed/'

# Data input
plaqueOut <- read.csv(plaqueOutputFile)
head(plaqueOut)  

# Generate well name column
plaqueOut['well'] <- str_match(plaqueOut$NucleiImageName, pattern = '(\\w\\d{2})_w\\d.TIF')[,2]
head(plaqueOut)

# Assign layout
plaqueOut <- assignLayoutAntiVir(plaqueOut, layoutFile)
head(plaqueOut)

# # Only keep relevant colums
# cpout <- data.frame(cpout$well, cpout$numberOfNuclei, cpout$numberOfInfectedNuclei, cpout$numberOfPlaques)
# names(cpout)=c('well', 'numberOfNuclei', 'numberOfInfectedNuclei', 'numberOfPlaques')

# Read treatment conditions
plaqueOut$virus = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,2]
plaqueOut$drug = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,3]
plaqueOut$conc = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,4]
head(plaqueOut)

# Exclude wells with treatment = exclude that shall be excluded from further analysis
plaqueOut <- plaqueOut[plaqueOut$treatment!='exclude',]
head(plaqueOut)

# Reorder and rename drugs for ploting
unique(plaqueOut$drug)
plaqueOut$drug <- factor(plaqueOut$drug, levels=c('dmso', 'bafa'))
levels(plaqueOut$drug) <- c('DMSO', 'BafA')

# Calculations ------------------------------------------------------------------------------------------------------------------------------

## Infection Index
plaqueOut$infectionIndex = plaqueOut$numberOfInfectedNuclei / plaqueOut$numberOfNuclei
plaqueOut$infectionIndexInverse = plaqueOut$numberOfNuclei / plaqueOut$numberOfInfectedNuclei

## GFP intensity background normalization
# In an infected well, significantly overscale the intensity visualizaion, measure mean background intensity. Open mask in MATLAB, calculate sum 
# [ sum(mask_IXM_C_4x(:)) ] and multiply this by the mean. Then substract this from the total GFP intensity. 
# = - 2580192618
plaqueOut$totalVirusIntensityBackgroundSubstracted = plaqueOut$totalVirusIntensity - 2580192618 #(manual)
#plaqueOut$totalVirusIntensityBackgroundSubstracted[plaqueOut$totalVirusIntensityBackgroundSubstracted<0] <- 0
plaqueOut$totalVirusIntensityLog = log(plaqueOut$totalVirusIntensity)

## Min Max Normalization
plaqueOut$numberOfNucleiNormalized = minMaxNormalize(plaqueOut$numberOfNuclei)
plaqueOut$numberOfInfectedNucleiNormalized = minMaxNormalize(plaqueOut$numberOfInfectedNuclei)
plaqueOut$infectionIndexNormalized = minMaxNormalize(plaqueOut$infectionIndex)
plaqueOut$infectionIndexInverseNormalized = minMaxNormalize(plaqueOut$infectionIndexInverse)
plaqueOut$numberOfPlaquesNormalized = minMaxNormalize(plaqueOut$numberOfPlaques)
plaqueOut$totalVirusIntensityNormalized = minMaxNormalize(plaqueOut$totalVirusIntensityBackgroundSubstracted)

## Relative cell numbers, infected cells and plaques to DMSO ctr.
plaqueOut$relNumberOfNuclei = plaqueOut$numberOfNuclei / DMSONucleiMean
plaqueOut$relNumberOfInfectedNuclei = plaqueOut$numberOfInfectedNuclei / DMSOInfectedNucleiMean
plaqueOut$relInfectionIndex = plaqueOut$infectionIndex / DMSOInfectioIndexMean
plaqueOut$relNumberOfPlaques = plaqueOut$numberOfPlaques / DMSOPlaqueMean

## Calculate BafA effect compared to DMSO
BafANucleiRelative = BafANucleiMean / DMSONucleiMean
BafAINfectedNucleiRelative = BafAInfectedNucleiMean / DMSOInfectedNucleiMean
BafAInfectionIndexRelative = BafAInfectioIndexMean / DMSOInfectioIndexMean
BafAPlaqueRelative = BafAPlaqueMean / DMSOPlaqueMean

## Min Max Normalization
plaqueOut$numberOfNucleiNormalized = minMaxNormalize(plaqueOut$numberOfNuclei)
plaqueOut$numberOfInfectedNucleiNormalized = minMaxNormalize(plaqueOut$numberOfInfectedNuclei)
plaqueOut$infectionIndexNormalized = minMaxNormalize(plaqueOut$infectionIndex)
plaqueOut$infectionIndexInverseNormalized = minMaxNormalize(plaqueOut$infectionIndexInverse)
plaqueOut$numberOfPlaquesNormalized = minMaxNormalize(plaqueOut$numberOfPlaques)
plaqueOut$totalVirusIntensityNormalized = minMaxNormalize(plaqueOut$totalVirusIntensity)
plaqueOut$totalVirusIntensityBackNormalized = minMaxNormalize(plaqueOut$totalVirusIntensityBackgroundSubstracted)
plaqueOut$totalVirusIntensityLogNormalized = minMaxNormalize(plaqueOut$totalVirusIntensityLog)

## Calculate DMSO ctr. means + STD
DMSONucleiMean = mean(plaqueOut[plaqueOut$drug == 'DMSO' , 'numberOfNuclei'])
DMSOInfectedNucleiMean = mean(plaqueOut[plaqueOut$drug == 'DMSO' , 'numberOfInfectedNuclei'])
DMSOInfectioIndexMean = mean(plaqueOut[plaqueOut$drug == 'DMSO' , 'infectionIndex'])
DMSOInfectioIndexInverseMean = mean(plaqueOut[plaqueOut$drug == 'DMSO' , 'infectionIndexInverse'])
DMSOPlaqueMean = mean(plaqueOut[plaqueOut$drug == 'DMSO' , 'numberOfPlaques'])
DMSOGfpMean = mean(plaqueOut[plaqueOut$drug == 'DMSO' , 'totalVirusIntensity'])

## Calculate BafA ctr. means + STD
BafANucleiMean = mean(plaqueOut[plaqueOut$drug == 'BafA' , 'numberOfNuclei'])
BafAInfectedNucleiMean = mean(plaqueOut[plaqueOut$drug == 'BafA' , 'numberOfInfectedNuclei'])
BafAInfectioIndexMean = mean(plaqueOut[plaqueOut$drug == 'BafA' , 'infectionIndex'])
BafAInfectioIndexInverseMean = mean(plaqueOut[plaqueOut$drug == 'BafA' , 'infectionIndexInverse'])
BafAPlaqueMean = mean(plaqueOut[plaqueOut$drug == 'BafA' , 'numberOfPlaques'])
BafAGfpMean = mean(plaqueOut[plaqueOut$drug == 'BafA' , 'totalVirusIntensity'])

## Relative cell numbers, infected cells and plaques to DMSO ctr.
plaqueOut$relNumberOfNuclei = plaqueOut$numberOfNuclei / DMSONucleiMean
plaqueOut$relNumberOfInfectedNuclei = plaqueOut$numberOfInfectedNuclei / DMSOInfectedNucleiMean
plaqueOut$relInfectionIndex = plaqueOut$infectionIndex / DMSOInfectioIndexMean
plaqueOut$relNumberOfPlaques = plaqueOut$numberOfPlaques / DMSOPlaqueMean

## Calculate BafA effect compared to DMSO
BafANucleiRelative = BafANucleiMean / DMSONucleiMean
BafAINfectedNucleiRelative = BafAInfectedNucleiMean / DMSOInfectedNucleiMean
BafAInfectionIndexRelative = BafAInfectioIndexMean / DMSOInfectioIndexMean
BafAPlaqueRelative = BafAPlaqueMean / DMSOPlaqueMean

##Z Factors
zFactorInfectionIndex = zFactor(plaqueOut$infectionIndex, "DMSO", "BafA", 0)
head(zFactorInfectionIndex)
zFactorInfectionIndexInverse =zFactor(plaqueOut$infectionIndexInverse, "DMSO", "BafA", 0)
head(zFactorInfectionIndexInverse)
zFactorNumberOfInfectedNuclei = zFactor(plaqueOut$numberOfInfectedNuclei, "DMSO", "BafA", 0)
head(zFactorNumberOfInfectedNuclei)
zFactorGfpIntensity = zFactor(plaqueOut$totalVirusIntensity, "DMSO", "BafA", 0)
head(zFactorGfpIntensity)
zFactorGfpBackIntensity = zFactor(plaqueOut$totalVirusIntensity, "DMSO", "BafA", 2580192618)
head(zFactorGfpBackIntensity)
zFactorGfpLogIntensity = zFactor(plaqueOut$totalVirusIntensityLog, "DMSO", "BafA", 0)
head(zFactorGfpLogIntensity)
zFactorGfpMeanIntensity = zFactor(plaqueOut$meanVirusIntensity, "DMSO", "BafA", 0)
head(zFactorGfpMeanIntensity)
zFactorNumberOfPlaques =  zFactor(plaqueOut$numberOfPlaques, "DMSO", "BafA", 0)
head(zFactorNumberOfPlaques)
zFactorNumberOfNuclei =zFactor(plaqueOut$numberOfNuclei, "DMSO", "BafA", 0)
head(zFactorNumberOfNuclei)

# Export ----------------------------------------------------------------------------------------------------------------------------------

write.table(plaqueOut, paste(outputAnalysisDirectory, plateName, '_complete.csv'), sep='\t') 

##### write something to export environment

# Plots ----------------------------------------------------------------------------------------------------------------------------------
library(ggplot2)
library(scales)
require('gtools')

## Infected Cells

# double y axis plot - number of infected cells and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfInfectedNuclei, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=numberOfInfectedNuclei))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells\n'), name='Infected Cells\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfectedNuclei.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - relative - number of infected cells and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$relNumberOfInfectedNuclei, y2=plaqueOut$relNumberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=relNumberOfInfectedNuclei))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$relNumberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells (Relative to Solvent Control)\n'), name='Infected Cells (Relative to Solvent Control)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfectedNuclei_relative.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - minmaxnormalized - infected cells and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfInfectedNucleiNormalized, y2=plaqueOut$numberOfNucleiNormalized)$yf
ggplot(plaqueOut, aes(x=conc, y=numberOfInfectedNucleiNormalized))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNucleiNormalized)/max(plaqueOut$fudgeTotal), name='Cells (Normalized)\n'), name='Infected Cells (Normalized)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfectedNuclei_normalized.png', sep=''), width=7, height=10, units='cm', dpi=1200)

## Plaques

# double y axis plot - number of plaques and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfPlaques, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=numberOfPlaques))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells\n'), name='Plaques\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaques.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - relative - number of plaques and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$relNumberOfPlaques, y2=plaqueOut$relNumberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=relNumberOfPlaques))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$relNumberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells (Relative to Solvent Control)\n'), name='Plaques (Relative to Solvent Control)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaques_relative.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - minmaxnormalized - number of plaques and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfPlaquesNormalized, y2=plaqueOut$numberOfNucleiNormalized)$yf
ggplot(plaqueOut, aes(x=conc, y=numberOfPlaquesNormalized))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNucleiNormalized)/max(plaqueOut$fudgeTotal), name='Cells (Normalized)\n'), name='Plaques (Normalized)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaques_normalized.png', sep=''), width=7, height=10, units='cm', dpi=1200)

## Infection Index

# double y axis plot - infection index and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$infectionIndex, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=infectionIndex))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells\n'), name='Infection Index\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfectionIndex.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - relative -infection index and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$relInfectionIndex, y2=plaqueOut$relNumberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=relInfectionIndex))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$relNumberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells (Relative to Solvent Control)\n'), name='Infection Index (Relative to Solvent Control)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfectionIndex_relative.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - minmaxnormalized - infection index and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$infectionIndexNormalized, y2=plaqueOut$numberOfNucleiNormalized)$yf
ggplot(plaqueOut, aes(x=conc, y=infectionIndexNormalized))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNucleiNormalized)/max(plaqueOut$fudgeTotal), name='Cells (Normalized)\n'), name='Infection Index (Normalized)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfectionIndex_normalized.png', sep=''), width=7, height=10, units='cm', dpi=1200)

## Total GFP

# double y axis plot - total GFP and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$totalVirusIntensity, y2=plaqueOut$relNumberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=totalVirusIntensity))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$relNumberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells (Relative to Solvent Control)\n'), name='Total GFP Intensity\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_TotalGFP.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - background substacted - total GFP and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$totalVirusIntensityBackgroundSubstracted, y2=plaqueOut$relNumberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=totalVirusIntensityBackgroundSubstracted))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$relNumberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells (Relative to Solvent Control)\n'), name='Total GFP Intensity (Background substracted)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_TotalGFP_background.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - minmaxnormalized - backgroundsubstracted total GFP and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$totalVirusIntensityBackNormalized, y2=plaqueOut$numberOfNucleiNormalized)$yf
ggplot(plaqueOut, aes(x=conc, y=totalVirusIntensityBackNormalized))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNucleiNormalized)/max(plaqueOut$fudgeTotal), name='Cells (Normalized)\n'), name='Total GFP Intensity (Normalized)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_TotalGFP_normalized_background.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - log - backgroundsubstracted total GFP and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$totalVirusIntensityLog, y2=plaqueOut$relNumberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=totalVirusIntensityLog))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$relNumberOfNuclei)/max(plaqueOut$fudgeTotal), name='Cells (Relative to Solvent Control)\n'), name='Total GFP Intensity (Log)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_TotalGFP_log.png', sep=''), width=7, height=10, units='cm', dpi=1200)

# double y axis plot - minmaxnormalized - log backgroundsubstracted total GFP and number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$totalVirusIntensityLogNormalized, y2=plaqueOut$numberOfNucleiNormalized)$yf
ggplot(plaqueOut, aes(x=conc, y=totalVirusIntensityLogNormalized))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNucleiNormalized)/max(plaqueOut$fudgeTotal), name='Cells (Normalized)\n'), name='Total GFP Intensity (Log, Normalized)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_TotalGFP_Normalized_log.png', sep=''), width=7, height=10, units='cm', dpi=1200)
