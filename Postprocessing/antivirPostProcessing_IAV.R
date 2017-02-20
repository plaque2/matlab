# Postprocessing of AntiVir Plaque 2.0 analysis and plotting
# Written by Luca Murer and Fanny Georgi
# Last edit 20170217 by Fanny Georgi

# Prerequisites: 
# 1- Run Plaque 2.0 analysis
# 2- Generate plate layout file
# 3- Run R functions assignLayoutAntiVir and CalcFudgeAxis first

# Comment: Due to lack of uninfected wells, no solvent normalization etc. is possible

# Groundwork ------------------------------------------------------------------------------------------------------------------------------
library(stringr)

# user input
plaqueOutputFile <- 'N:/antivir_screen/6-prestwick/6-4_virus_establishment/Results/160524-AntiVir-virus1_Plate_2659_ImageData.csv'
layoutFile <- 'N:/antivir_screen/6-prestwick/6-4_virus_establishment/Layouts/Est_p12_vIAV_d24e5.csv'
plateName = str_match(plaqueOutputFile, '(^.*/(.+)_ImageData.csv$)')[,3]
head(plateName)
virusName = str_match(layoutFile, '(^.*/Est_p(.+)_v(.+)_d(.+).csv$)')[,4]
head(virusName)
virusDilution = str_match(layoutFile, '(^.*/Est_p(.+)_v(.+)_d(.+).csv$)')[,5]
head(virusDilution)
establishmentPlateNumber = str_match(layoutFile, '(^.*/Est_p(.+)_v(.+)_d(.+).csv$)')[,3]
head(establishmentPlateNumber)
imagingPlateNumber = str_match(plaqueOutputFile, '(^.*/160524-AntiVir-virus1_Plate_(.+)_ImageData.csv$)')[,3]
head(imagingPlateNumber)

# output setup
plotTitle = 'IAV (1:240,000), 1 dpi on A549 ATCC'
outputPlotDirectory <- 'N:/antivir_screen/6-prestwick/6-4_virus_establishment/Results/postprocessed/Graphs/' 
outputPlotNameBase <- paste(virusName, virusDilution, sep="_")
outputAnalysisDirectory <- 'N:/antivir_screen/6-prestwick/6-4_virus_establishment/Results/postprocessed/'

# data input
plaqueOut <- read.csv(plaqueOutputFile)
head(plaqueOut)  

# generate well name column
library(stringr)
plaqueOut['well'] <- str_match(plaqueOut$NucleiImageName, pattern = '(\\w\\d{2})_w\\d.TIF')[,2]
head(plaqueOut)

# assign layout
plaqueOut <- assignLayoutAntiVir(plaqueOut, layoutFile)
head(plaqueOut)

# # only keep relevant colums
# cpout <- data.frame(cpout$well, cpout$numberOfNuclei, cpout$numberOfInfectedNuclei, cpout$numberOfPlaques)
# names(cpout)=c('well', 'numberOfNuclei', 'numberOfInfectedNuclei', 'numberOfPlaques')

# read treatment conditions
plaqueOut$virus = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,2]
plaqueOut$drug = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,3]
plaqueOut$conc = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,4]
head(plaqueOut)

# reorder and rename drugs for ploting
unique(plaqueOut$drug)
plaqueOut$drug <- factor(plaqueOut$drug, levels=c('mock', 'dmso', 'meoh', 'arac', 'dft', 'baf', 'nicl', 'brefa'))
levels(plaqueOut$drug) <- c('Mock', 'DMSO', 'MeOH', 'ara-C', 'DFT', 'Baf', 'Nicl', 'BrefA')

# # log10 concentrations
# plaqueOut$logConc = 0
# plaqueOut[plaqueOut$conc!=0, 'logConc'] = log10(as.numeric(plaqueOut[plaqueOut$conc!='0', 'conc']))
# plaqueOut$logConc <- factor(plaqueOut$logConc, levels=c('0', '-4', '-3', '-2', '-1', '1'))
# levels(plaqueOut$logConc)=c('mock', '-4', '-3', '-2', '-1', '1')
# unique(plaqueOut$logConc)
# str(plaqueOut)

# rename virus flag
unique(plaqueOut$virus)
plaqueOut$virus <- factor(plaqueOut$virus, levels=c('0', '1'))
levels(plaqueOut$virus) <- c('non-infected', 'infected')

# Calculations ------------------------------------------------------------------------------------------------------------------------------

## Infected wells

# Exclude non-relevant solvent concentrations
plaqueOut_drugs_a <- plaqueOut[plaqueOut$drug %in% c('Mock', 'DMSO', 'MeOH') & plaqueOut$conc != 0.01 ,]
plaqueOut_drugs_b <- plaqueOut[plaqueOut$drug %in% c('ara-C', 'DFT', 'Baf', 'Nicl', 'BrefA') ,]
plaqueOut_drugs <- rbind(plaqueOut_drugs_a, plaqueOut_drugs_b)

# Infection index
plaqueOut_drugs$relInfected <- plaqueOut_drugs$numberOfInfectedNuclei/plaqueOut_drugs$numberOfNuclei

# Calculate means in controls
nucleiMockMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'numberOfNuclei'])
nucleiDMSOMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'numberOfNuclei'])
nucleiMeOHMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'numberOfNuclei'])
infectedMockMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'numberOfInfectedNuclei'])
infectedDMSOMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'numberOfInfectedNuclei'])
infectedMeOHMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'numberOfInfectedNuclei'])
plaqueMockMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'numberOfPlaques'])
plaqueDMSOMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'numberOfPlaques'])
plaqueMeOHMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'numberOfPlaques'])
relInfectedMockMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'relInfected'])
relInfectedDMSOMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'relInfected'])
relInfectedMeOHMean <- mean(plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'relInfected'])

# Infection index normalized by mean Mock Infection index = non-treated, infected and non-infected
plaqueOut_drugs$normRelInfected <- plaqueOut_drugs$relInfected/mean(plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'relInfected'])

# Infection index normalized by corresponding solvent
plaqueOut_drugs$normSolventRelInfected <- Inf
plaqueOut_drugs[plaqueOut_drugs$drug== 'Mock', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'relInfected']/ relInfectedMockMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DMSO', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'relInfected']/ relInfectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'MeOH', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'relInfected']/ relInfectedMeOHMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'ara-C', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='ara-C', 'relInfected']/ relInfectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DFT', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DFT', 'relInfected']/ relInfectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Baf', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Baf', 'relInfected']/ relInfectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Nicl', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Nicl', 'relInfected']/ relInfectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'BrefA', 'normSolventRelInfected'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='BrefA', 'relInfected']/ relInfectedMeOHMean

# Number of nuclei normalized by corresponding solvent
plaqueOut_drugs$normSolventRelNuclei <- Inf
plaqueOut_drugs[plaqueOut_drugs$drug== 'Mock', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'numberOfNuclei']/ nucleiMockMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DMSO', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'numberOfNuclei']/ nucleiDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'MeOH', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'numberOfNuclei']/ nucleiMeOHMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'ara-C', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='ara-C', 'numberOfNuclei']/ nucleiDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DFT', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DFT', 'numberOfNuclei']/ nucleiDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Baf', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Baf', 'numberOfNuclei']/ nucleiDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Nicl', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Nicl', 'numberOfNuclei']/ nucleiDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'BrefA', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='BrefA', 'numberOfNuclei']/ nucleiMeOHMean

# Number of Plaques normalized to mean Mock number of plaques = non-treated, infected
plaqueOut$normRelPlaques <- plaqueOut$numberOfPlaques/mean(plaqueOut[plaqueOut$drug=='Mock', 'numberOfPlaques'])
# Normalize infected cells to corresponding solvent
plaqueOut$normSolventRelInfectedNuclei <- Inf
plaqueOut_drugs[plaqueOut_drugs$drug== 'Mock', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'numberOfInfectedNuclei']/ infectedMockMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DMSO', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'numberOfInfectedNuclei']/ infectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'MeOH', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'numberOfInfectedNuclei']/ infectedMeOHMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'ara-C', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='ara-C', 'numberOfInfectedNuclei']/ infectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DFT', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DFT', 'numberOfInfectedNuclei']/ infectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Baf', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Baf', 'numberOfInfectedNuclei']/ infectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Nicl', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Nicl', 'numberOfInfectedNuclei']/ infectedDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'BrefA', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='BrefA', 'numberOfInfectedNuclei']/ infectedMeOHMean

# Normalize plaques to corresponding solvent
plaqueOut$normSolventRelPlaques <- Inf
plaqueOut_drugs[plaqueOut_drugs$drug== 'Mock', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Mock', 'numberOfPlaques']/ plaqueMockMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DMSO', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DMSO', 'numberOfPlaques']/ plaqueDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'MeOH', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='MeOH', 'numberOfPlaques']/ plaqueMeOHMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'ara-C', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='ara-C', 'numberOfPlaques']/ plaqueDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'DFT', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='DFT', 'numberOfPlaques']/ plaqueDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Baf', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Baf', 'numberOfPlaques']/ plaqueDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'Nicl', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='Nicl', 'numberOfPlaques']/ plaqueDMSOMean
plaqueOut_drugs[plaqueOut_drugs$drug== 'BrefA', 'normSolventRelPlaques'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='BrefA', 'numberOfPlaques']/ plaqueMeOHMean

# remove Inf and NaN
plaqueOut[mapply(is.infinite, plaqueOut)] <- 0
plaqueOut[mapply(is.na, plaqueOut)] <- 0

# Export ----------------------------------------------------------------------------------------------------------------------------------

write.table(plaqueOut, paste(outputAnalysisDirectory, plateName, '_infected.csv'), sep='\t') 

# Export overview numbers




# Plots ----------------------------------------------------------------------------------------------------------------------------------
library(ggplot2)
library(scales)

# relInfected (not pretty)
ggplot(plaqueOut, aes(y=relInfected, x=drug, col=as.factor(conc)))+
  geom_point(position=position_jitterdodge(dodge.width=0.6, jitter.width=0.1))+
  ylab('Infection Index\n')+
  xlab('\nCompound')+
  scale_colour_discrete(name='Compound\nConcentration')+
  theme_bw()+
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(legend.title=element_text())

#  (not pretty)
ggplot(plaqueOut, aes(y=relInfected, x=conc))+
  geom_jitter(width=0.2)+
  facet_grid(.~drug, scales='free_x')+
  ylab('Infection Index\n')+
  xlab('\nConcentration [uM]')+
  scale_colour_discrete(name='Compound\nConcentration')+
  theme_bw()+
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(strip.background=element_blank())

# double y axis plot - infection index for infected wells only
plaqueOut_drugs['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_drugs$relInfected, y2=plaqueOut_drugs$numberOfNuclei)$yf
ggplot(plaqueOut_drugs, aes(x=conc, y=relInfected))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_drugs$numberOfNuclei)/max(plaqueOut_drugs$relInfected), name='Cell Count\n'), name='Infection Index\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  ylab('Infection Index\n')+
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
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfInd.png', sep=''), width=15, height=10, units='cm', dpi=1200)

# double y axis plot - infection index normalized to solvent for infected wells only
plaqueOut_drugs['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_drugs$normSolventRelInfected, y2=plaqueOut_drugs$normSolventRelNuclei)$yf
ggplot(plaqueOut_drugs, aes(x=conc, y=normSolventRelInfected))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_drugs$normSolventRelNuclei)/max(plaqueOut_drugs$normSolventRelInfected), name='Cell Count (Normalized to Solvent)\n'), name='Infection Index (Normalized to Solvent)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  ylab('Infection Index (Normalized to Solvent)\n')+
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
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfInd_norm.png', sep=''), width=15, height=10, units='cm', dpi=1200)

# double y axis plot - plaque number for infected wells only
plaqueOut_drugs['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_drugs$numberOfPlaques, y2=plaqueOut_drugs$numberOfNuclei)$yf
ggplot(plaqueOut_drugs, aes(x=conc, y=numberOfPlaques))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_drugs$numberOfNuclei)/max(plaqueOut_drugs$numberOfPlaques), name='Cell Count\n'), name='Plaque Number\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaque.png', sep=''), width=15, height=10, units='cm', dpi=1200)

# double y axis plot - plaque number normalized to corresponding solvent for infected wells only
plaqueOut_drugs['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_drugs$normSolventRelPlaques, y2=plaqueOut_drugs$normSolventRelNuclei)$yf
ggplot(plaqueOut_drugs, aes(x=conc, y=normSolventRelPlaques))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_drugs$normSolventRelNuclei)/max(plaqueOut_drugs$normSolventRelPlaques), name='Cell Count (Normalized to Solvent)\n'), name='Plaque Number (Normalized to Solvent)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  xlab('\nConcentration [uM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaque_norm.png', sep=''), width=15, height=10, units='cm', dpi=1200)
