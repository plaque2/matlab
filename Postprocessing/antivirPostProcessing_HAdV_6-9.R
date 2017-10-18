# Postprocessing of AntiVir Plaque 2.0 analysis and plotting
# Written by Luca Murer and Fanny Georgi
# Last edit 20170622 by Fanny Georgi

# Prerequisites: 
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
plaqueOutputFile <- 'N:/antivir_screen/6-prestwick/6-9_adeno_StockComparison/Results/170502-AntiVir-AdenoStock_Plate_4054_ImageData.csv'
layoutFile <- 'N:/antivir_screen/6-prestwick/6-9_adeno_StockComparison/Layouts/StockComp_p2_vHAdV_dtitration.csv'
plateName = str_match(plaqueOutputFile, '(^.*/(.+)_ImageData.csv$)')[,3]
head(plateName)
virusName = str_match(layoutFile, '(^.*/StockComp_p(.+)_v(.+)_d(.+).csv$)')[,4]
head(virusName)
virusDilution = str_match(layoutFile, '(^.*/StockComp_p(.+)_v(.+)_d(.+).csv$)')[,5]
head(virusDilution)
establishmentPlateNumber = str_match(layoutFile, '(^.*/StockComp_p(.+)_v(.+)_d(.+).csv$)')[,3]
head(establishmentPlateNumber)
imagingPlateNumber = str_match(plaqueOutputFile, '(^.*/.*_Plate_(.+)_ImageData.csv$)')[,3]
head(imagingPlateNumber)

# Output setup
plotTitle = 'HAdV (Stock comparison), 3 dpi on A549 ATCC'
outputPlotDirectory <- 'N:/antivir_screen/6-prestwick/6-9_adeno_StockComparison/Results/postprocessed/Graphs/' 
outputPlotNameBase <- paste(virusName, virusDilution, sep="_")
outputAnalysisDirectory <- 'N:/antivir_screen/6-prestwick/6-9_adeno_StockComparison/Results/postprocessed/'

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
plaqueOut$virus = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_d(\\d*.?\\d*)')[,2]
plaqueOut$drug = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_d(\\d*.?\\d*)')[,3]
plaqueOut$dilution = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_d(\\d*.?\\d*)')[,4]
head(plaqueOut)

# Reorder and rename drugs for ploting
unique(plaqueOut$drug)
plaqueOut$drug <- factor(plaqueOut$drug, levels=c('mock', 'stockA', 'stockB'))
levels(plaqueOut$drug) <- c('Mock', 'StockA', 'StockB')

# reorder and rename dilutions for ploting
unique(plaqueOut$dilution)
plaqueOut$dilution <- factor(plaqueOut$dilution, levels=c('0', '1e6', '2e6', '4e6', '8e6', '12e6'))
levels(plaqueOut$dilution) <- c('Mock', '1:1,000,000', '1:2,000,000', '1:4,000,000', '1:8,000,000', '1:12,000,000')

# Rename virus flag
unique(plaqueOut$virus)
plaqueOut$virus <- factor(plaqueOut$virus, levels=c('0', '1'))
levels(plaqueOut$virus) <- c('non-infected', 'infected')

# Separate infected and non-infected poopulation
# Alternatively, use plaqueOut$relInfected <- plaqueOut$numberOfInfectedNuclei[plaqueOut$virus=='1',]/plaqueOut$numberOfNuclei[plaqueOut$virus=='1',]
plaqueOut_infected <- plaqueOut[plaqueOut$virus=='infected',]
plaqueOut_noninfected <- plaqueOut[plaqueOut$virus=='non-infected',]

# Separate stocks
plaqueOut_stockA <- plaqueOut_infected[plaqueOut_infected$drug=='StockA',]
plaqueOut_stockB <- plaqueOut_infected[plaqueOut_infected$drug=='StockB',]

# Calculations ------------------------------------------------------------------------------------------------------------------------------

# Means Mock
nucleiMockMean_noninfected = mean(plaqueOut_noninfected[plaqueOut_noninfected$dilution=='Mock', 'numberOfNuclei'])

stockA_plaques1e6Mean = mean(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:1,000,000', 'numberOfPlaques'])
stockA_plaques2e6Mean = mean(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:2,000,000', 'numberOfPlaques'])
stockA_plaques4e6Mean = mean(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:4,000,000', 'numberOfPlaques'])
stockA_plaques8e6Mean = mean(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:8,000,000', 'numberOfPlaques'])
stockA_plaques12e6Mean = mean(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:12,000,000', 'numberOfPlaques'])

stockB_plaques1e6Mean = mean(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:1,000,000', 'numberOfPlaques'])
stockB_plaques2e6Mean = mean(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:2,000,000', 'numberOfPlaques'])
stockB_plaques4e6Mean = mean(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:4,000,000', 'numberOfPlaques'])
stockB_plaques8e6Mean = mean(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:8,000,000', 'numberOfPlaques'])
stockB_plaques12e6Mean = mean(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:12,000,000', 'numberOfPlaques'])

# STDs
nucleiMockStd_noninfected = sd(plaqueOut_noninfected[plaqueOut$dilution=='Mock', 'numberOfNuclei'])

stockA_plaques1e6Std = sd(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:1,000,000', 'numberOfPlaques'])
stockA_plaques2e6Std = sd(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:2,000,000', 'numberOfPlaques'])
stockA_plaques4e6Std = sd(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:4,000,000', 'numberOfPlaques'])
stockA_plaques8e6Std = sd(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:8,000,000', 'numberOfPlaques'])
stockA_plaques12e6Std = sd(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:12,000,000', 'numberOfPlaques'])

stockA_plaques1e6Std = sd(plaqueOut_stockA[plaqueOut_stockA$dilution=='1:1,000,000', 'numberOfPlaques'])
stockB_plaques2e6Std = sd(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:2,000,000', 'numberOfPlaques'])
stockB_plaques4e6Std = sd(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:4,000,000', 'numberOfPlaques'])
stockB_plaques8e6Std = sd(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:8,000,000', 'numberOfPlaques'])
stockB_plaques12e6Std = sd(plaqueOut_stockB[plaqueOut_stockB$dilution=='1:12,000,000', 'numberOfPlaques'])

# Infection index
plaqueOut$relInfected <- plaqueOut$numberOfInfectedNuclei/plaqueOut$numberOfNuclei
# Infection index normalized by mean Mock Infection index = non-treated, non-infected
plaqueOut$normRelInfected <- plaqueOut$relInfected/mean(plaqueOut[plaqueOut$dilution=='Mock', 'relInfected'])
# Number of nuclei normalized to mean Mock number of nuclei = non-treated, non-infected
plaqueOut$normRelNuclei <- plaqueOut$numberOfNuclei/mean(plaqueOut[plaqueOut$dilution=='Mock', 'numberOfNuclei']) 
# Number of Plaques normalized to mean Mock number of plaques = non-treated, infected
plaqueOut$normRelPlaques <- plaqueOut$numberOfPlaques/mean(plaqueOut[plaqueOut$dilution=='Mock', 'numberOfPlaques'])

# Plots ----------------------------------------------------------------------------------------------------------------------------------
library(ggplot2)
library(scales)

### !!! Mind that cell count is off in plots, but correct in data

# double y axis plot - infected cells
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfInfectedNuclei, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=numberOfInfectedNuclei))+
  geom_boxplot(aes(x=dilution, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
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
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfCells.png', sep=''), width=10, height=10, units='cm', dpi=1200)

# double y axis plot - infection index
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$relInfected, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=relInfected))+
  geom_boxplot(aes(x=dilution, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
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
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfInd.png', sep=''), width=10, height=10, units='cm', dpi=1200)

# double y axis plot - relative number of nuclei
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$normRelNuclei, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=normRelNuclei))+
  geom_boxplot(aes(x=dilution, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$normRelNuclei), name='Cell Count\n'), name='Number of Nuclei (normalized to Mock)\n')+
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
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Nuclei_norm.png', sep=''), width=10, height=10, units='cm', dpi=1200)

# double y axis plot - plaque number 
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfPlaques, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=dilution, y=numberOfPlaques))+
  geom_boxplot(aes(x=dilution, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2), size=0.2, col = '#6BB100')+
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
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaque.png', sep=''), width=10, height=10, units='cm', dpi=1200)
