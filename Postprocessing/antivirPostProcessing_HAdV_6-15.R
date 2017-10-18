# Postprocessing of AntiVir Plaque 2.0 analysis and plotting
# Written by Luca Murer and Fanny Georgi
# Last edit 20170612 by Fanny Georgi


#######
# There is a bug with the CalcFudge that changes the actual values! This needs urgent fixing!
#######


# Prerequisites: 
# install.packages('gtools')
# 1- Run Plaque 2.0 analysis
# 2- Generate plate layout file
# 3- Run R functions assignLayoutAntiVir and CalcFudgeAxis first

# To do:
# - add output csv
# - include  calculations on GFP
# - calculate statistics for treatments for overview
# - export overview numbers to .csv

# Possible ad-ons:
# - total plaque area as parameter

# Groundwork ------------------------------------------------------------------------------------------------------------------------------
library(stringr)

# User input
plaqueOutputFile <- 'N:/antivir_screen/6-prestwick/6-15_HAdV_titration/170630-6-15-HAdV_Plate_200/Results/170630-6-15-HAdV_Plate_200_ImageData.csv'
layoutFile <- 'N:/antivir_screen/6-prestwick/6-15_HAdV_titration/170630-6-15-HAdV_Plate_200/Layouts/PBS_p6_vHAdV_dtitration.csv'
plateName = str_match(plaqueOutputFile, '(^.*/(.+)_ImageData.csv$)')[,3]
head(plateName)
virusName = str_match(layoutFile, '(^.*/PBS_p(.+)_v(.+)_d(.+).csv$)')[,4]
head(virusName)
virusDilution = str_match(layoutFile, '(^.*/PBS_p(.+)_v(.+)_d(.+?).csv$)')[,5]
head(virusDilution)
establishmentPlateNumber = str_match(layoutFile, '(^.*/PBS_p(.+)_v(.+)_d(.+).csv$)')[,3]
head(establishmentPlateNumber)
imagingPlateNumber = str_match(plaqueOutputFile, '(^.*/170630-6-15-HAdV_Plate_Plate_(.+)_ImageData.csv$)')[,3]
head(imagingPlateNumber)

plotTitle = 'HAdV Titration, 3 dpi on A549 ATCC'
outputPlotDirectory <- 'N:/antivir_screen/6-prestwick/6-15_HAdV_titration/170630-6-15-HAdV_Plate_200/Results/postprocessed/Graphs/' 
outputPlotNameBase <- paste(virusName, virusDilution, sep="_")
outputAnalysisDirectory <- 'N:/antivir_screen/6-prestwick/6-15_HAdV_titration/170630-6-15-HAdV_Plate_200/Results/postprocessed/'

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
plaqueOut$virus = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_d(\\d*)')[,2]
plaqueOut$drug = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_d(\\d*)')[,3]
plaqueOut$dilution = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_d(\\S*)')[,4]
head(plaqueOut)

# Reorder and rename drugs for ploting
unique(plaqueOut$drug)
plaqueOut$drug <- factor(plaqueOut$drug, levels=c('mock'))
levels(plaqueOut$drug) <- c('PBS')

# reorder and rename dilutions for ploting
unique(plaqueOut$dilution)
plaqueOut$dilution <- factor(plaqueOut$dilution, levels=c('0', '25e4', '5e5', '1e6'))
levels(plaqueOut$dilution) <- c('PBS', '1:250,000', '1:500,000', '1:1,000,000')

# Rename virus flag
unique(plaqueOut$virus)
plaqueOut$virus <- factor(plaqueOut$virus, levels=c('0', '1'))
levels(plaqueOut$virus) <- c('non-infected', 'infected')

# Separate infected and non-infected poopulation
# Alternatively, use plaqueOut$relInfected <- plaqueOut$numberOfInfectedNuclei[plaqueOut$virus=='1',]/plaqueOut$numberOfNuclei[plaqueOut$virus=='1',]
# Only analyze highest conc
plaqueOut_infected <- plaqueOut[plaqueOut$virus=='infected',]
plaqueOut_noninfected <- plaqueOut[plaqueOut$virus=='non-infected',]

# Calculations ------------------------------------------------------------------------------------------------------------------------------

# Means Mock
nucleiMockMean_noninfected = mean(plaqueOut_noninfected[plaqueOut_noninfected$dilution=='PBS', 'numberOfNuclei'])

plaques25e4Mean = mean(plaqueOut_infected[plaqueOut_infected$dilution=='1:250,000', 'numberOfPlaques'])
plaques5e5Mean = mean(plaqueOut_infected[plaqueOut_infected$dilution=='1:500,000', 'numberOfPlaques'])
plaques1e6Mean = mean(plaqueOut_infected[plaqueOut_infected$dilution=='1:1,000,000', 'numberOfPlaques'])

# STDs
nucleiMockStd_noninfected = sd(plaqueOut_noninfected[plaqueOut$dilution=='PBS', 'numberOfNuclei'])

plaques25e4Std = sd(plaqueOut_infected[plaqueOut_infected$dilution=='1:250,000', 'numberOfPlaques'])
plaques5e5Std = sd(plaqueOut_infected[plaqueOut_infected$dilution=='1:500,000', 'numberOfPlaques'])
plaques1e6Std = sd(plaqueOut_infected[plaqueOut_infected$dilution=='1:1,000,000', 'numberOfPlaques'])

# Infection index
plaqueOut$relInfected <- plaqueOut$numberOfInfectedNuclei/plaqueOut$numberOfNuclei
# Infection index normalized by mean Mock Infection index = non-treated, non-infected
plaqueOut$normRelInfected <- plaqueOut$relInfected/mean(plaqueOut[plaqueOut$dilution=='PBS', 'relInfected'])
# Number of nuclei normalized to mean Mock number of nuclei = non-treated, non-infected
plaqueOut$normRelNuclei <- plaqueOut$numberOfNuclei/mean(plaqueOut[plaqueOut$dilution=='PBS', 'numberOfNuclei']) 


# Export ----------------------------------------------------------------------------------------------------------------------------------

write.table(plaqueOut_drugs, paste(outputAnalysisDirectory, plateName, '_drugs.csv'), sep='\t') 
write.table(plaqueOut_drugsInfected, paste(outputAnalysisDirectory, plateName, '_drugsInfected.csv'), sep='\t') 
write.table(plaqueOut_solvents, paste(outputAnalysisDirectory, plateName, '_solvents.csv'), sep='\t') 
write.table(plaqueOut_solventsInfected, paste(outputAnalysisDirectory, plateName, '_solventsInfected.csv'), sep='\t') 
write.table(plaqueOut_noninfected, paste(outputAnalysisDirectory, plateName, '_noninfected.csv'), sep='\t') 
write.table(plaqueOut_infected, paste(outputAnalysisDirectory, plateName, '_infected.csv'), sep='\t') 

# Plots ----------------------------------------------------------------------------------------------------------------------------------
library(ggplot2)
library(scales)
require('gtools')
  
# double y axis plot - infected cells
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfInfectedNuclei, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=numberOfInfectedNuclei))+
  # There is a bug in CalcFudgeAxis leading to 2.2x right y axis values therefore /2.2
  geom_boxplot(aes(x=dilution, y=fudgeTotal/2.2), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/(max(plaqueOut$numberOfInfectedNuclei)), name='Cell Count\n'), name='Infected Cells\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  ylab('Infected Cells\n')+
  xlab('\nVirus Dilution')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfCells.png', sep=''), width=10, height=10, units='cm', dpi=300)

# double y axis plot - infection index
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$relInfected, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=relInfected))+
  # There is a bug in CalcFudgeAxis leading to 2.2x right y axis values therefore /2.2
  geom_boxplot(aes(x=dilution, y=fudgeTotal/2.2), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$relInfected), name='Cell Count\n'), name='Infection Index\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  ylab('Infection Index\n')+
  xlab('\nVirus Dilution')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfInd.png', sep=''), width=10, height=10, units='cm', dpi=300)

# double y axis plot - relative number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$normRelNuclei, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=normRelNuclei))+
  geom_boxplot(aes(x=dilution, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$normRelNuclei), name='Cell Count\n'), name='Number of infected Nuclei (normalized to Mock)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  ylab('Number of Nuclei (normalized to Mock)\n')+
  xlab('\nVirus Dilution')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  #theme(strip.placement="outside", strip.text=element_text(face='bold'))+ # print drugs bold
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0)) # turn drugs 90 degrees
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Nuclei_norm.png', sep=''), width=10, height=10, units='cm', dpi=300)

# double y axis plot - plaque number 
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfPlaques, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=numberOfPlaques))+
  # There is a bug in CalcFudgeAxis leading to 2.2x right y axis values therefore /2.2
  geom_boxplot(aes(x=dilution, y=fudgeTotal/2.2), col='blue', width=0.4, outlier.colour = NA)+  geom_point(position=position_jitter(width=0.2), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$numberOfPlaques), name='Cell Count\n'), name='Plaque Number\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  xlab('\nVirus Dilution')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaque.png', sep=''), width=10, height=10, units='cm', dpi=300)
