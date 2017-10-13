# Postprocessing for AntiVir data plotting
# Written by Luca Murer, adapted by Fanny Georgi

# run function assignLayoutAntiVir first

# data input
cpout <- read.csv('N:/antivir_screen/6-prestwick/6-4_virus_establishment/Results/160524-AntiVir-virus1_Plate_2669_ImageData.csv')
head(cpout)  

# generate well name column
library(stringr)
cpout['well'] <- str_match(cpout$NucleiImageName, pattern = '(\\w\\d{2})_w\\d.TIF')[,2]

# extract relevant columns
cpout <- data.frame(cpout$well, cpout$numberOfNuclei, cpout$numberOfInfectedNuclei, cpout$numberOfPlaques)
names(cpout)=c('well', 'numberOfNuclei', 'numberOfInfectedNuclei', 'numberOfPlaques')

# assign layout
cpout <- assignLayoutAntiVir(cpout, 'N:/antivir_screen/6-prestwick/6-4_virus_establishment/Layouts/Est_p7_vHRV_d139e4.csv')
head(cpout)

cpout$virus = str_match(cpout$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,2]
cpout$drug = str_match(cpout$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,3]
cpout$conc = str_match(cpout$treatment, 'v(\\d*)_n(\\w*)_m(\\d*.?\\d*)')[,4]

# reorder Drugs
unique(cpout$drug)
cpout$drug <- factor(cpout$drug, levels=c('mock', 'dmso', 'meoh', 'arac', 'dft', 'baf', 'nicl', 'brefa'))
levels(cpout$drug) <- c('Mock', 'DMSO', 'MeOH', 'ara-C', 'DFT', 'Baf', 'Nicl', 'BrefA')

# # log10 concentrations
# cpout$logConc = 0
# cpout[cpout$conc!=0, 'logConc'] = log10(as.numeric(cpout[cpout$conc!='0', 'conc']))
# cpout$logConc <- factor(cpout$logConc, levels=c('0', '-4', '-3', '-2', '-1', '1'))
# levels(cpout$logConc)=c('mock', '-4', '-3', '-2', '-1', '1')
# unique(cpout$logConc)
# str(cpout)

# calculate infection indices
cpout$relInfected <- cpout$numberOfInfectedNuclei/cpout$numberOfNuclei
cpout$normRelInfected <- cpout$relInfected/mean(cpout[cpout$drug=='mock', 'relInfected'])

# plots -------------------------------------------------------------------
library(ggplot2)
library(scales)

# relInfected
ggplot(cpout, aes(y=relInfected, x=drug, col=as.factor(conc)))+
  geom_point(position=position_jitterdodge(dodge.width=0.6, jitter.width=0.1))+
  ylab('Infection Index\n')+xlab('\nCompound')+
  scale_colour_discrete(name='Compound\nConcentration')+
  theme_bw()+
  theme(legend.title=element_text())

ggplot(cpout, aes(y=relInfected, x=conc))+
  geom_jitter(width=0.2)+
  facet_grid(.~drug, scales='free_x')+
  ylab('Infection Index\n')+xlab('\nConcentration (uM)')+
  scale_colour_discrete(name='Compound\nConcentration')+
  theme_bw()+
  theme(strip.background=element_blank())

# normRelInfected
ggplot(cpout, aes(y=normRelInfected, x=drug, col=as.factor(conc)))+
  geom_point(position=position_jitterdodge(dodge.width=0.6, jitter.width=0.1))+
  ylab('Infection Index (Normalized to Mock Treated)\n')+xlab('\nCompound')+
  scale_colour_discrete(name='Compound\nConcentration')+
  theme_bw()+
  theme(legend.title=element_text())

# double y axis plot - infection index
cpout['fudgeTotal'] <- CalcFudgeAxis(y1=cpout$relInfected, y2=cpout$numberOfNuclei)$yf
ggplot(cpout, aes(x=conc, y=relInfected))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(cpout$numberOfNuclei)/max(cpout$relInfected), name='Cell Count\n'), name='Infection Index\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1)+
  #geom_errorbar(stat='summary', fun.y='mean', width=0.2, aes(y=fudgeTotal, ymax=..y.., ymin=..y..), col='blue', position=position_dodge(width=0.9))+
  ylab('Infection Index\n')+
  #xlab('\nVirus (RVA-16)')+
  xlab('\nConcentration (uM)')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  theme(strip.placement="outside", strip.text=element_text(face='bold'))+
  labs(title = "HRV (1:1 388 889), 2 dpi on HOG") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave('N:/antivir_screen/6-prestwick/6-4_virus_establishment/Results/postprocessed/Graphs/HRV_139e4_InfInd.png', width=15, height=10, units='cm', dpi=1200)

# double y axis plot - normalized infection index (not working if no non-fected wells are there)
cpout['fudgeTotal'] <- CalcFudgeAxis(y1=cpout$normRelInfected, y2=cpout$numberOfNuclei)$yf
ggplot(cpout, aes(x=conc, y=normRelInfected))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2), size=0.2)+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(cpout$numberOfNuclei)/max(cpout$normRelInfected), name='Cell Count\n'), name='Infection Index (Normalized)\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1)+
  #geom_errorbar(stat='summary', fun.y='mean', width=0.2, aes(y=fudgeTotal, ymax=..y.., ymin=..y..), col='blue', position=position_dodge(width=0.9))+
  #xlab('\nVirus (RVA-16)')+
  xlab('\nLog10 Concentration (uM)')+
  labs(title = "HRV (1:1 388 889), 2 dpi on HOG") +
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))

# double y axis plot - plaque number
cpout['fudgeTotal'] <- CalcFudgeAxis(y1=cpout$numberOfPlaques, y2=cpout$numberOfNuclei)$yf
ggplot(cpout, aes(x=conc, y=numberOfPlaques))+
  geom_boxplot(aes(x=conc, y=fudgeTotal), col='blue', width=0.4, outlier.colour = NA)+
  geom_point(position=position_jitter(width=0.2), size=0.2, col = '#6BB100')+
  facet_grid(.~drug, scales='free_x', space = 'free_x')+
  scale_y_continuous(sec.axis=sec_axis(~.*max(cpout$numberOfNuclei)/max(cpout$numberOfPlaques), name='Cell Count\n'), name='Plaque Number\n')+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1)+
  #geom_errorbar(stat='summary', fun.y='mean', width=0.2, aes(y=fudgeTotal, ymax=..y.., ymin=..y..), col='blue', position=position_dodge(width=0.9))+
  #xlab('\nControl Compound')+
  xlab('\nConcentration (uM)')+
  theme_bw()+
  theme(strip.background=element_blank(), axis.text.x=element_text(angle=45, hjust=1))+
  theme(axis.title.y.right=element_text(colour='blue'), axis.text.y.right=element_text(colour='blue'))+
  labs(title = "HRV (1:1 388 889), 2 dpi on HOG") +
  theme(plot.title = element_text(hjust = 0.5))
  ggsave('N:/antivir_screen/6-prestwick/6-4_virus_establishment/Results/postprocessed/Graphs/HRV_139e4_Plaque.png', width=15, height=10, units='cm', dpi=1200)

# cell count
ggplot(cpout, aes(y=numberOfNuclei, x=conc))+
  geom_jitter(width=0.2, col='blue')+
  facet_grid(.~drug, scales='free_x')+
  ylab('Number of Nuclei\n')+xlab('\nConcentration (uM)')+
  scale_colour_discrete(name='Compound\nConcentration')+
  scale_y_continuous(labels=comma)+
  geom_errorbar(stat='summary', fun.y='mean', width=0.6, aes(ymax=..y..,ymin=..y..), position=position_dodge(width=1.2), size=1)+
  theme_bw()+
  theme(strip.background=element_blank())
