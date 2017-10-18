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
plaqueOutputFile <- 'N:/antivir_screen/6-prestwick/6-14_IAV_titratration/170702-6-14-IAV-p3-frozen_Plate_224/Results/170702-6-14-IAV-p3-frozen_Plate_224_ImageData.csv'
layoutFile <- 'N:/antivir_screen/6-prestwick/6-14_IAV_titratration/170702-6-14-IAV-p3-frozen_Plate_224/Layouts/BafA_frozen_p3_vIAV_dtitration.csv'
plateName = str_match(plaqueOutputFile, '(^.*/(.+)_ImageData.csv$)')[,3]
head(plateName)
virusName = str_match(layoutFile, '(^.*/BafA_frozen_p(.+)_v(.+)_d(.+).csv$)')[,4]
head(virusName)
virusDilution = str_match(layoutFile, '(^.*/BafA_frozen_p(.+)_v(.+)_d(.+?).csv$)')[,5]
head(virusDilution)
establishmentPlateNumber = str_match(layoutFile, '(^.*/BafA_frozen_p(.+)_v(.+)_d(.+).csv$)')[,3]
head(establishmentPlateNumber)
imagingPlateNumber = str_match(plaqueOutputFile, '(^.*/170702-6-14-IAV-p3-frozen_Plate_(.+)_ImageData.csv$)')[,3]
head(imagingPlateNumber)

# Output setup, later only 1:600,000 is plotted
plotTitle = 'BafA: IAV (1:600,000), 1 dpi on A549 ATCC'
outputPlotDirectory <- 'N:/antivir_screen/6-prestwick/6-14_IAV_titratration/170702-6-14-IAV-p3-frozen_Plate_224/Results/postprocessed/Graphs/' 
outputPlotNameBase <- paste(virusName, virusDilution, sep="_")
outputAnalysisDirectory <- 'N:/antivir_screen/6-prestwick/6-14_IAV_titratration/170702-6-14-IAV-p3-frozen_Plate_224/Results/postprocessed/'

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
plaqueOut$virus = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)_d(\\d*)')[,2]
plaqueOut$drug = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)_d(\\d*)')[,3]
plaqueOut$conc = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)_d(\\d*)')[,4]
plaqueOut$dilution = str_match(plaqueOut$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)_d(\\d*)')[,5]
head(plaqueOut)

# Exclude wells with treatment = exclude that shall be excluded from further analysis
plaqueOut <- plaqueOut[plaqueOut$treatment!='exclude',]
head(plaqueOut)

# Reorder and rename drugs for ploting
unique(plaqueOut$drug)
plaqueOut$drug <- factor(plaqueOut$drug, levels=c('PBS', 'DMSO','BafA'))
levels(plaqueOut$drug) <- c('Mock', 'DMSO', 'BafA')

# Reorder concentrations
require('gtools')
plaqueOut$conc <- factor(plaqueOut$conc, levels = c(rev(mixedsort(unique(plaqueOut$conc)))))

# # log10 concentrations
# plaqueOut$logConc = 0
# plaqueOut[plaqueOut$conc!=0, 'logConc'] = log10(as.numeric(plaqueOut[plaqueOut$conc!='0', 'conc']))
# plaqueOut$logConc <- factor(plaqueOut$logConc, levels=c('0', '-4', '-3', '-2', '-1', '1'))
# levels(plaqueOut$logConc)=c('mock', '-4', '-3', '-2', '-1', '1')
# unique(plaqueOut$logConc)
# str(plaqueOut)

# Rename virus flag
unique(plaqueOut$virus)
plaqueOut$virus <- factor(plaqueOut$virus, levels=c('0', '1'))
levels(plaqueOut$virus) <- c('non-infected', 'infected')

# Separate infected and non-infected poopulation
# Alternatively, use plaqueOut$relInfected <- plaqueOut$numberOfInfectedNuclei[plaqueOut$virus=='1',]/plaqueOut$numberOfNuclei[plaqueOut$virus=='1',]
# Only analyze highest conc
plaqueOut_infected <- plaqueOut[plaqueOut$dilution=='600000',]
plaqueOut_noninfected <- plaqueOut[plaqueOut$virus=='non-infected',]

# Calculations ------------------------------------------------------------------------------------------------------------------------------

## Solvent toxicity

# create dataset solvents for convenient calculations, where only Mock and DMSO 0.16 are included
plaqueOut_solvents <- plaqueOut_noninfected[plaqueOut_noninfected$drug %in% c('Mock', 'DMSO') ,]
# Create dataset drugs
plaqueOut_drugs <- plaqueOut_noninfected[plaqueOut_noninfected$drug %in% c('BafA') ,]
# normalize cell numbers in solvent controls by mock
plaqueOut_solvents$normMockRelNuclei <- plaqueOut_solvents$numberOfNuclei/mean(plaqueOut_solvents[plaqueOut_solvents$drug=='Mock', 'numberOfNuclei'])
# Calculate mean tox of solvents
toxDMSOMean = mean(plaqueOut_solvents[plaqueOut_solvents$drug=='DMSO', 'normMockRelNuclei'])
toxDMSOStd = sd(plaqueOut_solvents[plaqueOut_solvents$drug=='DMSO', 'normMockRelNuclei'])
nucleiDMSOMean = mean(plaqueOut_solvents[plaqueOut_solvents$drug=='DMSO', 'numberOfNuclei'])
infectedDMSOMean = mean(plaqueOut_solvents[plaqueOut_solvents$drug=='DMSO', 'numberOfInfectedNuclei'])
plaquesDMSOMean = mean(plaqueOut_solvents[plaqueOut_solvents$drug=='DMSO', 'numberOfPlaques'])

## Drug toxicity normalized to solvent

# Normalize non-infected treated numberOfNuclei by corresponding solvents
#plaqueOut_drugs$normSolventRelNuclei <- Inf
plaqueOut_drugs[plaqueOut_drugs$drug=='BafA', 'normSolventRelNuclei'] <- plaqueOut_drugs[plaqueOut_drugs$drug=='BafA', 'numberOfNuclei']/nucleiDMSOMean

## Solvent effect on infection

# create dataset solvents for convenient calculations, where only Mock and DMSO are included
plaqueOut_solventsInfected <- plaqueOut_infected[plaqueOut_infected$drug %in% c('Mock', 'DMSO') ,]
# Normalize number of infected cells in solvent wells to infected Mock
plaqueOut_solventsInfected$normMockRelInfectedNuclei <- plaqueOut_solventsInfected$numberOfInfectedNuclei/mean(plaqueOut_solventsInfected[plaqueOut_solventsInfected$drug=='Mock', 'numberOfInfectedNuclei'])
# Calculate means etc.
nucleiInInfectedMockMean = mean(plaqueOut_solventsInfected[plaqueOut_solventsInfected$drug=='Mock', 'numberOfNuclei'])
nucleiInInfectedDMSOMean = mean(plaqueOut_solventsInfected[plaqueOut_solventsInfected$drug=='DMSO', 'numberOfNuclei'])
infectedInInfectedMockMean = mean(plaqueOut_solventsInfected[plaqueOut_solventsInfected$drug=='Mock', 'numberOfInfectedNuclei'])
infectedInInfectedDMSOMean = mean(plaqueOut_solventsInfected[plaqueOut_solventsInfected$drug=='DMSO', 'numberOfInfectedNuclei'])
infectionIndexInInfectedDMSOMean = infectedInInfectedDMSOMean / nucleiInInfectedDMSOMean
plaquesInInfectedMockMean = mean(plaqueOut_solventsInfected[plaqueOut_solventsInfected$drug== 'Mock', 'numberOfPlaques'])
plaquesInInfectedDMSOMean = mean(plaqueOut_solventsInfected[plaqueOut_solventsInfected$drug=='DMSO', 'numberOfPlaques'])

## Drug effects on infection normalized to solvent

# Create dataset drugsInfected
plaqueOut_drugsInfected <- plaqueOut_infected[plaqueOut_infected$drug %in% c('BafA') ,]
# Normalize infected treated numberOfNuclei by corresponding solvents
#plaqueOut_drugsInfected$normSolventRelNuclei <- Inf
plaqueOut_drugsInfected[plaqueOut_drugsInfected$drug=='BafA', 'normSolventRelNuclei'] <- plaqueOut_drugsInfected[plaqueOut_drugsInfected$drug=='BafA', 'numberOfNuclei']/nucleiInInfectedDMSOMean
# Normalize infected treated numberOfInfectedNuclei by corresponding solvents
#plaqueOut_drugsInfected$normSolventRelInfectedNuclei <- Inf
plaqueOut_drugsInfected[plaqueOut_drugsInfected$drug=='BafA', 'normSolventRelInfectedNuclei'] <- plaqueOut_drugsInfected[plaqueOut_drugsInfected$drug=='BafA', 'numberOfInfectedNuclei']/infectedInInfectedDMSOMean
# Normalize infected treated numberOfPlaques by corresponding solvents
#plaqueOut_drugsInfected$normSolventRelPlaques <- Inf
plaqueOut_drugsInfected[plaqueOut_drugsInfected$drug=='BafA', 'normSolventRelPlaques'] <- plaqueOut_drugsInfected[plaqueOut_drugsInfected$drug=='BafA', 'numberOfPlaques']/plaquesInInfectedDMSOMean

# Calculate infection index
plaqueOut_drugsInfected$relInfected <- plaqueOut_drugsInfected$numberOfInfectedNuclei/plaqueOut_drugsInfected$numberOfNuclei

## All wells (infected and non-infected)

# Infection index
plaqueOut$relInfected <- plaqueOut$numberOfInfectedNuclei/plaqueOut$numberOfNuclei
# Infection index normalized by mean Mock Infection index = non-treated, infected and non-infected
plaqueOut$normRelInfected <- plaqueOut$relInfected/mean(plaqueOut[plaqueOut$drug=='Mock', 'relInfected'])

## Non-infected wells
# Infection index
plaqueOut_noninfected$relInfected <- plaqueOut_noninfected$numberOfInfectedNuclei/plaqueOut_noninfected$numberOfNuclei
# Infection index normalized by mean Mock Infection index = non-treated, non-infected
plaqueOut_noninfected$normRelInfected <- plaqueOut_noninfected$relInfected/mean(plaqueOut_noninfected[plaqueOut_noninfected$drug=='Mock', 'relInfected'])
# Number of nuclei normalized to mean Mock number of nuclei = non-treated, non-infected
plaqueOut_noninfected$normRelNuclei <- plaqueOut_noninfected$numberOfNuclei/mean(plaqueOut_noninfected[plaqueOut_noninfected$drug=='Mock', 'numberOfNuclei'])

## Infected wells normalized to solvent
# Infection index
plaqueOut_infected$relInfected <- plaqueOut_infected$numberOfInfectedNuclei/plaqueOut_infected$numberOfNuclei
# Infection index normalized by mean Mock Infection index = non-treated, non-infected
plaqueOut_infected$normRelInfected <- plaqueOut_infected$relInfected/mean(plaqueOut_infected[plaqueOut_infected$drug=='DMSO', 'relInfected'])
# Number of nuclei normalized to mean Mock number of nuclei = non-treated, non-infected
plaqueOut_infected$normRelNuclei <- plaqueOut_infected$numberOfNuclei/mean(plaqueOut_noninfected[plaqueOut_noninfected$drug=='DMSO', 'numberOfNuclei']) 
# Number of Plaques normalized to mean Mock number of plaques = non-treated, infected
plaqueOut_infected$normRelPlaques <- plaqueOut_infected$numberOfPlaques/mean(plaqueOut_infected[plaqueOut_infected$drug=='DMSO', 'numberOfPlaques'])
#do.call(data.frame,lapply(plaqueOut_infected, function(x) replace(x, is.infinite(x),NA)))

## Control Compound Mean 
plaquesBafA_40nM_mean = mean(plaqueOut_infected[plaqueOut_infected$drug=='BafA' & plaqueOut_infected$conc=='40', 'numberOfPlaques'])
plaquesBafA_40nM_mean_normalized = mean(plaqueOut_infected[plaqueOut_infected$drug=='BafA' & plaqueOut_infected$conc=='40', 'normRelPlaques'])

normInfectionIndexBafA_40nM_mean = mean(plaqueOut_infected[plaqueOut_infected$drug=='BafA' & plaqueOut_infected$conc=='40', 'normRelInfected'])
normNumberOfNucleiBafA_40nM_mean = mean(plaqueOut_infected[plaqueOut_infected$drug=='BafA' & plaqueOut_infected$conc=='40', 'normRelNuclei'])



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

## Solvent toxicity

# Solvent relative number of nuclei to Mock
ggplot(plaqueOut_solvents, aes(y=normMockRelNuclei, x=conc))+
  geom_jitter(width=0.2, col='#0066cc')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  ylab('Number of Nuclei (Normalized to Mock)\n')+
  xlab('\nConcentration [nM]')+
  scale_colour_discrete(name='Compound\nConcentration')+
  scale_y_continuous(labels=comma, limits=c(0, 1.1), breaks=c(0, 0.5, 1) )+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, colour='blue')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='blue')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='blue'), axis.text.y=element_text(colour='blue'))+  
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))+
  geom_hline(yintercept = 1, col='darkgrey')
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_SolventTox.png', sep=''), width=6, height=10, units='cm', dpi=300)

# drug relative number of nuclei to solvent
ggplot(plaqueOut_drugs, aes(y=normSolventRelNuclei, x=conc))+
  geom_jitter(width=0.2, col='#0066cc')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  ylab('Number of Nuclei (Normalized to Solvent)\n')+
  xlab('\nConcentration [nM]')+
  scale_colour_discrete(name='Compound\nConcentration')+
  scale_y_continuous(labels=comma, limits=c(0, 1.1), breaks=c(0, 0.5, 1) )+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, colour='blue')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='blue')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='blue'), axis.text.y=element_text(colour='blue'))+ 
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))+
  geom_hline(yintercept = 0.8, col='darkgrey')
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_DrugTox.png', sep=''), width=11, height=10, units='cm', dpi=1200)

## Solvent effect on infection

# Solvent relative number of infected nuclei to Mock
ggplot(plaqueOut_solventsInfected, aes(y=normMockRelInfectedNuclei, x=conc))+
  geom_jitter(width=0.2, col='#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  ylab('Number of Infected Nuclei (Normalized to Mock)\n')+
  xlab('\nConcentration [nM]')+
  scale_colour_discrete(name='Compound\nConcentration')+
  scale_y_continuous(labels=comma, limits=c(0, 1.5), breaks=c(0, 0.5, 1) )+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, colour='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))+
  geom_hline(yintercept = 1, col='darkgrey')
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_SolventEffectInfected.png', sep=''), width=6, height=10, units='cm', dpi=300)

# drug relative number of infected nuclei to solvent
ggplot(plaqueOut_drugsInfected, aes(y=normSolventRelInfectedNuclei, x=conc))+
  geom_jitter(width=0.2, col='#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  ylab('Number of Infected Nuclei (Normalized to Solvent)\n')+
  xlab('\nConcentration [nM]')+
  scale_colour_discrete(name='Compound\nConcentration')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, colour='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+ 
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))+
  geom_hline(yintercept = 0.8, col='darkgrey')
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_DrugEffectInfected.png', sep=''), width=11, height=10, units='cm', dpi=1200)

# drug relative number of plaques to solvent
ggplot(plaqueOut_drugsInfected, aes(y=normSolventRelPlaques, x=conc))+
  geom_jitter(width=0.2, col='#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  ylab('Number of Plaques (Normalized to Solvent)\n')+
  xlab('\nConcentration [nM]')+
  scale_colour_discrete(name='Compound\nConcentration')+
  scale_y_continuous(labels=comma, limits=c(0, 1.25), breaks=c(0, 0.5, 1) )+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, colour='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+ 
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))+
  geom_hline(yintercept = 0.8, col='darkgrey')
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_DrugEffectPlaques.png', sep=''), width=11, height=10, units='cm', dpi=1200)

# double y axis plot - infection index for infected wells only
plaqueOut_infected['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_infected$relInfected, y2=plaqueOut_infected$normRelNuclei)$yf
ggplot(plaqueOut_infected, aes(x=conc, y=relInfected))+
  # There is a bug in CalcFudgeAxis leading to 3.5x right y axis values therefore /3.5
  geom_boxplot(aes(x=conc, y=fudgeTotal/3.5), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_infected$normRelNuclei)/max(plaqueOut_infected$relInfected), name='Normalized Number of Nuclei\n'), name='Infection Index\n')+
  #scale_x_discrete(limits=c(rev(mixedsort(unique(plaqueOut$conc)))))+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  ylab('Infection Index\n')+
  xlab('\nConcentration [nM]')+
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

# cell numbers dependant on durg, solvent in non-infected
ggplot(plaqueOut, aes(y=numberOfNuclei, x=conc))+
  geom_jitter(width=0.2, col='#0066cc')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  ylab('Number of Nuclei\n')+
  xlab('\nConcentration [nM]')+
  scale_colour_discrete(name='Compound\nConcentration')+
  scale_y_continuous(labels=comma)+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, colour='blue')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='blue')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y=element_text(colour='blue'), axis.text.y=element_text(colour='blue'))+ 
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))+
  geom_hline(yintercept = 0.8, col='darkgrey')
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Nuclei_non-inf.png', sep=''), width=11, height=10, units='cm', dpi=1200)

# double y axis plot - infection index separated infected and non-infecetd: facet_grid(virus~drug, ...
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$relInfected, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=relInfected))+
  # There is a bug in CalcFudgeAxis leading to 3.5x right y axis values therefore /3.5
  geom_boxplot(aes(x=conc, y=fudgeTotal/3.5), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(virus~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$relInfected), name='Cell Count\n'), name='Infection Index\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  ylab('Infection Index\n')+
  xlab('\nConcentration [nM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0.5))
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfInd_sep.png', sep=''), width=15, height=10, units='cm', dpi=1200)

# double y axis plot - normalized infection index infected wells only
plaqueOut_infected['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_infected$normRelInfected, y2=plaqueOut_infected$normRelNuclei)$yf
ggplot(plaqueOut_infected, aes(x=conc, y=normRelInfected))+
  # There is a bug in CalcFudgeAxis leading to 3.5x right y axis values therefore /3.5
  geom_boxplot(aes(x=conc, y=fudgeTotal/3.5), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_infected$normRelNuclei)/max(plaqueOut_infected$normRelInfected), name='Cell Count (Normalized)\n'), name='Infection Index (Normalized)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [nM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90, vjust = 0))
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_InfInd_norm.png', sep=''), width=15, height=10, units='cm', dpi=1200)

# double y axis plot - plaque number separated infected and non-infecetd: facet_grid(virus~drug, ...
plaqueOut['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut$numberOfPlaques, y2=plaqueOut$numberOfNuclei)$yf
ggplot(plaqueOut, aes(x=conc, y=numberOfPlaques))+
  # There is a bug in CalcFudgeAxis leading to 3.5x right y axis values therefore /3.5
  geom_boxplot(aes(x=conc, y=fudgeTotal/3.5), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
  facet_grid(virus~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut$numberOfNuclei)/max(plaqueOut$numberOfPlaques), name='Cell Count\n'), name='Plaque Number\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
  stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
  xlab('\nConcentration [nM]')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
  labs(title = plotTitle) + 
  theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(strip.text=element_text(angle=90))
ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Pleaque_sep.png', sep=''), width=15, height=10, units='cm', dpi=1200)

  # double y axis plot - plaque number for infected wells only
  plaqueOut_infected['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_infected$numberOfPlaques, y2=plaqueOut_infected$numberOfNuclei)$yf
  ggplot(plaqueOut_infected, aes(x=conc, y=numberOfPlaques))+
    # There is a bug in CalcFudgeAxis leading to 3.5x right y axis values therefore /3.5
    geom_boxplot(aes(x=conc, y=fudgeTotal/3.5), col='blue', width=0.4, outlier.colour = NA)+
    geom_point(position=position_jitter(width=0.2), size=0.2, col = '#6BB100')+
    facet_grid(.~drug, scales='free_x', space = 'free_x')+
    scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_infected$numberOfNuclei)/max(plaqueOut_infected$numberOfPlaques), name='Cell Count\n'), name='Plaque Number\n')+
    geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
    stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
    xlab('\nConcentration [nM]')+
    theme_bw()+
    theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
    theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
    theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
    labs(title = plotTitle) + 
    theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
    theme(plot.title = element_text(hjust = 0.5))+
    theme(strip.text=element_text(angle=90, vjust = 0))
  ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaque.png', sep=''), width=15, height=10, units='cm', dpi=1200)

  # double y axis plot - normalized plaque number infected wells only
  plaqueOut_infected['fudgeTotal'] <- CalcFudgeAxis(y1=plaqueOut_infected$normRelPlaques, y2=plaqueOut_infected$normRelNuclei)$yf
  ggplot(plaqueOut_infected, aes(x=conc, y=normRelPlaques))+
    # There is a bug in CalcFudgeAxis leading to 3.5x right y axis values therefore /3.5
    geom_boxplot(aes(x=conc, y=fudgeTotal/3.5), col='blue', width=0.4, outlier.colour = NA)+
    geom_point(position=position_jitter(width=0.2, height=0), size=0.2, col = '#6BB100')+
    facet_grid(.~drug, scales='free_x', space = 'free_x')+
    scale_y_continuous(sec.axis=sec_axis(~.*max(plaqueOut_infected$normRelNuclei)/max(plaqueOut_infected$normRelPlaques), name='Cell Count (Normalized)\n'), name='Plaque Number (Normalized)\n')+
    geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1, col='#006600')+
    stat_summary(fun.data= mean_se, geom= 'errorbar', width=0.4, size=0.5, colour='#006600')+
    xlab('\nConcentration [nM]')+
    theme_bw()+
    theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
    theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
    theme(axis.title.y=element_text(colour='#006600'), axis.text.y=element_text(colour='#006600'))+  
    labs(title = plotTitle) + 
    theme(panel.grid.minor.x=element_blank(), panel.grid.major.x=element_blank())+
    theme(plot.title = element_text(hjust = 0.5))+
    theme(strip.text=element_text(angle=90, vjust = 0))
  ggsave(paste(outputPlotDirectory, outputPlotNameBase, '_Plaque_norm.png', sep=''), width=15, height=10, units='cm', dpi=1200)

