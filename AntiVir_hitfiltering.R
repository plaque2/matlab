#################################################################################
##################### Hit Filtering for the AntiVir screen ######################
########## Written by Luca Murer and Fanny Georgi, University of Zurich #########
################################### March 2020 ##################################
#################################################################################

# Load dependencies -------------------------------------------------------
library(dplyr)
library(ggplot2)
library(scales)
library(gtools)
library(stringr)

# Define Functions  -----------------------------------------------------------------------------------------------------------------------

CalcFudgeAxisAV = function(y1, y2=y1) {
  ylim1 <- c(min(y1), max(y1))
  ylim2 <- c(min(y2), max(y2))    
  yf <- rescale(y2, to = c(ylim1[1], ylim1[2]))
  scalingFactor <<- (max(yf)-min(yf))/(max(y2)-min(y2))
  return(yf)
}

assignLayoutAV <- function(cpout, treatment) {
  
  # load layout
  treatment <- read.csv(treatment, header=T, check.names = FALSE)
  
  # assign proper header to layout table
  library(stringr)
  names <- c('row', str_pad(seq(24), 2, pad="0"))
  names(treatment)=names
  
  #assign treatment values to cpout
  for (well in unique(cpout$Metadata_Well)) {
    value <- treatment[treatment$row==substr(well, 1, 1), substr(well, 2, 3)]
    cpout[cpout$Metadata_Well==well, 'treatment'] <- as.character(value)
  }
  cpout$treatment <- factor(cpout$treatment)
  return(cpout)
}


# Input section --------------------------------------------------------

rootFolder <- '.../idr0081/3-Screen/Data_UZH/'
nExperiments <- 4

experimentsToAnalyze <- nExperiments

# Scan rootFolder for the barcodes given above
plates <- grep(pattern = '.*ImageData.csv', list.files(file.path(rootFolder, 'Results'),
                                               recursive = TRUE), value = TRUE)
plates <- file.path(rootFolder, 'Results', plates)
plates <- unique(plates[which(file.exists(plates))])

# plate <- plates[1]
# barcode <- str_match(pattern = 'BSF\\d{6}', string = plate)[1]
# layoutFileName <- grep(pattern = barcode, list.files(file.path(dirname(plate), '..', '..', 'Layouts')), value = TRUE)
# layoutPath <- file.path(rootFolder, 'Layouts', layoutFileName)
wellNames <- paste0(rep(LETTERS[1:16], each = 24), str_pad(string = seq(1, 24), width = 2, side = 'left', pad = '0'))

# Load datasets & assign treatments + plate IDs, bind them into one data.frame
cpout=data.frame()
i=1
for(plate in plates){
  cpout1 <- read.csv(plate)
  cpout1$Metadata_Well <- wellNames
  barcode <- str_match(pattern = 'BSF\\d{6}', string = plate)[1]
  layoutFileName <- grep(pattern = barcode, list.files(file.path(dirname(plate), '..', '..', 'Layouts')), value = TRUE)
  layoutPath <- file.path(rootFolder, '..', 'Layouts', layoutFileName)
  cpout1 <- assignLayoutAV(cpout = cpout1, treatment = layoutPath)
  cpout1 <- cpout1[cpout1$treatment != '',]
  cpout1 <- droplevels(cpout1)
  cpout1['plate'] <- paste('p', i, sep='')
  cpout <- rbind(cpout, cpout1)
  print(paste('Finished plate:', plate, 'nrow(cpout)=', nrow(cpout)))
  i=i+1
}

cpout <- droplevels(cpout)
cpout['replID'] <- rep(seq(1, 4), each = 384*length(experimentsToAnalyze)) # Assign replicate IDs


# Calculations ------------------------------------------------------------------------------------------------------------------------------

# Infection Index
cpout$infectionIndex = cpout$numberOfInfectedNuclei / cpout$numberOfNuclei
cpout$infectionIndexInverse = cpout$numberOfNuclei / cpout$numberOfInfectedNuclei

# Log totalVirusIntensity
cpout$totalVirusIntensityLog = log(cpout$totalVirusIntensity)

# Define parameters to perform subsequent normalization on
columnsToNormalize <- c('numberOfNuclei',
                        'numberOfInfectedNuclei',
                        'infectionIndex',
                        'numberOfPlaques',
                        'totalVirusIntensity')

# Calculate parameters relative to their respective negative control
for(column in columnsToNormalize){
  relColumn = c()
  for(plate in unique(cpout$plate)){
    meanNeg = mean(cpout[cpout$plate == plate & cpout$treatment == 'DMSO', column])
    relColumn = cpout[column]/meanNeg
  }
  cpout[paste(column, 'Rel', sep='')] = relColumn
}

# Define compound class (test or control)
cpout$class <- 'test'
cpout[grepl('^\\D', cpout$treatment) , 'class'] <- 'control'


# Identify compound names -------------------------------------------------

compoundNames <- read.csv(file.path(rootFolder, '..', 'Layouts', 'AnalysisSkeleton.csv'), header = T)[,c('compoundName', 'compoundIdentifier', 'compoundcatalogID')]
compoundNames[compoundNames$compoundcatalogID == 'D235475', 'compoundIdentifier'] <- 'DFT'
compoundNames[compoundNames$compoundcatalogID == '', 'compoundIdentifier'] <- 'DMSO'

# Repeat the compound names data frame as often as replicates are provided
compoundNames = bind_rows(replicate(length(experimentsToAnalyze), compoundNames, simplify = FALSE))

# Merge the data frames
cpout <- cbind(cpout, compoundNames[, c('compoundName', 'compoundIdentifier', 'compoundcatalogID')])

# Export ----------------------------------------------------------------------------------------------------------------------------------

# Check whether the 'Analysis' subfolder exists. If not, create one
if(!file.exists(file.path(dirname(plates[1]), '..', 'Analysis'))){
  dir.create(file.path(dirname(plates[1]), '..', 'Analysis'))
}

# Write cpout as a csv. Uncomment if this is desired
write.table(x = cpout, file = file.path(dirname(plates[1]), '..', 'Analysis', 'analysis.tsv'), sep='\t', row.names = F, quote = F)


# Z' scores ---------------------------------------------------------------

cpoutDensity <- cpout[cpout$class == 'control',] # subset the data frame to only include controls

# Define a function that calculates z' scores for individual plates
zprime <- function(column){
  zp <- c()
  
  for(replicate in unique(cpoutDensity$plate)){
    posControl <- cpoutDensity[cpoutDensity$compoundIdentifier == 'DFT' & cpoutDensity$plate == replicate, column]
    negControl <- cpoutDensity[cpoutDensity$compoundIdentifier == 'DMSO' & cpoutDensity$plate == replicate, column]
    zp <- append(zp, 1-(3*sd(posControl)+3*sd(negControl))/abs(mean(posControl)-mean(negControl)))
  }
  
  return(zp)
}

# Prime data frame
zscores <- data.frame('plateID' = seq(1, 4*length(experimentsToAnalyze)))

# Calculate and bind the data frame
zscores <- cbind(zscores, sapply(FUN = zprime, X = columnsToNormalize))

# Write the file. Uncomment if this is desired
write.table(x = zscores, file = file.path(dirname(plates[1]), '..', 'Analysis', 'zscores.tsv'), sep='\t', row.names = F, quote = F)


# Quality control plots ----------------------------------------------------------------------------------------------------------------------------------

# Density plots for controls only
densityColors <- c('#007a00ff', '#00a500ff', '#00cd00ff', '#00ef00ff', #greens
                   '#303030ff', '#4f4f4fff', '#6e6e6eff', '#909090ff') #greys

cpoutDensity <- cpout[cpout$class == 'control',]
cpoutDensity['treatment_replID'] <- paste(cpoutDensity$treatment, cpoutDensity$replID, sep = ' ')

# numberOfInfectedNuclei, infectionIndex, numberOfPlaques
for(column in columnsToNormalize[2:4]){
  ggplot(cpoutDensity, aes(x = eval(as.name(column)), col = treatment_replID, fill = treatment_replID))+
    geom_density(alpha = 0.5)+
    scale_y_continuous(expand = c(0, 0))+
    scale_x_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE))+
    scale_color_manual(values = densityColors)+
    scale_fill_manual(values = densityColors)+
    ylab('Density [ ]')+ xlab(label = column)+
    theme_bw()+
    theme(legend.title = element_blank())+
    theme(axis.ticks = element_line(color = 'black'), panel.grid = element_blank())+
    theme(panel.border = element_blank(), axis.line = element_line(), axis.text = element_text(colour = 'black'))
  ggsave(file.path(dirname(plates[1]), '..', 'Analysis', paste('pretty_density_', column, '.png', sep='')), height = 7, width = 16, units = 'cm', dpi = 600)
}

# Special case numberOfNuclei
ggplot(cpoutDensity, aes(x = numberOfNuclei, col = treatment_replID, fill = treatment_replID))+
  geom_density(alpha = 0.5)+
  scale_y_continuous(expand = c(0, 0))+
  scale_x_continuous(limits = c(0, max(cpoutDensity$numberOfNuclei)), labels = function(x) format(x, big.mark = ",", scientific = FALSE))+
  scale_color_manual(values = densityColors)+
  scale_fill_manual(values = densityColors)+
  ylab('Density [ ]')+
  theme_bw()+
  theme(legend.title = element_blank())+
  theme(axis.ticks = element_line(color = 'black'), panel.grid = element_blank())+
  theme(panel.border = element_blank(), axis.line = element_line(), axis.text = element_text(colour = 'black'))
ggsave(file.path(dirname(plates[1]), '..', 'Analysis', paste('pretty_density_', 'numberOfNuclei', '.png', sep='')), height = 7, width = 16, units = 'cm', dpi = 600)

# Special case totalVirusIntensity
ggplot(cpoutDensity, aes(x = totalVirusIntensity, col = treatment_replID, fill = treatment_replID))+
  geom_density(alpha = 0.5)+
  scale_y_continuous(expand = c(0, 0))+
  scale_x_continuous(labels = function(x) format(x, big.mark = ",", scientific = TRUE))+
  scale_color_manual(values = densityColors)+
  scale_fill_manual(values = densityColors)+
  ylab('Density [ ]')+
  theme_bw()+
  theme(legend.title = element_blank())+
  theme(axis.ticks = element_line(color = 'black'), panel.grid = element_blank())+
  theme(panel.border = element_blank(), axis.line = element_line(), axis.text = element_text(colour = 'black'))
ggsave(file.path(dirname(plates[1]), '..', 'Analysis', paste('pretty_density_', 'totalVirusIntensity', '.png', sep='')), height = 7, width = 16, units = 'cm', dpi = 600)


# Hit filtering & plotting ------------------------------------------------

# loop for generating a plot for each parameter defined above (in columnsToNormalize)
# calculate the means between the replicates

for (column in paste(columnsToNormalize, 'Rel', sep='')){
  #for (column in columnsToNormalize){ # Use this line instead, if the raw (non-normalized) parameters should be used
  meanColumnName <- paste('mean_', column, sep='')
  for(compound in unique(cpout$treatment)){
    cpout[cpout$treatment == compound, meanColumnName] <- mean(cpout[cpout$treatment == compound, column])
  }
  ## Order the data frame according to the means
  cpout$treatment <- factor(cpout$treatment, levels = unique(cpout$treatment[order(cpout[meanColumnName])]))
  
  ## Rescale numberOfNuclei to the range of the first y axis
  cpout['fudgeNumberOfNuclei'] = NULL
  cpout['fudgeNumberOfNuclei'] <- CalcFudgeAxisAV(cpout[column], cpout$numberOfNuclei)
  
  ### Subset the data frame to exclude data points within the range of the negative control
  negCtrl <- cpout[cpout$treatment == 'DMSO', column] # Define the data points of the negative control
  sdNeg <- sd(negCtrl) # Calclate sd and mean
  meanNeg <- mean(negCtrl)
  
  ## Calculate the mean of the technical replicates and check if they are in the
  ## mean +- 3*sd range of the negctrl
  subCpout <- data.frame(cpout[1,]) # Prime the data frame
  for(compound in unique(cpout$treatment)){
    if(mean(cpout[cpout$treatment == compound, column]) > meanNeg + 3*sdNeg |
       mean(cpout[cpout$treatment == compound, column]) < meanNeg - 3*sdNeg){
      subCpout = rbind(subCpout, cpout[cpout$treatment == compound,])
      }
  }
  subCpout <- subCpout[2:nrow(subCpout),] # Remove the first row that was used to prime the data frame
  subCpout = rbind(subCpout, cpout[cpout$treatment == 'DMSO',]) # Include DMSO control
  
  ## Cell tox: discard data points with cell numbers below mean-2*sd of the negative control
  negCtrl <- cpout[cpout$treatment == 'DMSO', 'numberOfNuclei']
  sdNeg <- sd(negCtrl)
  meanNeg <- mean(negCtrl)
  for(compound in unique(subCpout$treatment)){
    if(mean(subCpout[subCpout$treatment == compound, 'numberOfNuclei']) < meanNeg - 2*sdNeg){
      subCpout = subCpout[!(subCpout$treatment == compound),]
    }
  }
  
  ### Plot
  ggplot(subCpout, aes(x = treatment, y = eval(as.name(column))))+
    geom_point(aes(x = treatment, y = fudgeNumberOfNuclei), size = 1, alpha = 0.3, col = 'blue3', position = position_jitter(width = 0.1))+
    geom_point(size = 1, alpha = 0.3, position = position_jitter(width = 0.1), col = 'grey20')+
    scale_y_continuous(expand=c(0, 0), sec.axis=sec_axis((~rescale(., to = c(min(subCpout$numberOfNuclei), max(subCpout$numberOfNuclei)))), name = 'Cell Count'), name = paste(column, '\n (normalized to DMSO)', sep=''))+
    scale_x_discrete(name = 'Compound ID')+
    theme_classic()+
    theme(strip.background = element_blank(), axis.line = element_line())+
    theme(axis.text.y.right = element_text(colour = 'blue3'), axis.title.y.right = element_text(colour = 'blue3'))+
    theme(axis.text.x = element_text(angle = 45, hjust = 1, colour = 'black'))
    theme(axis.ticks = element_line(colour = 'black'))
  ggsave(filename = file.path(dirname(plates[1]), '..', 'Analysis', paste(column, '.png', sep='')), width = 2+length(unique(subCpout$treatment))*2, height = 7, units = 'cm', dpi = 600)
  
  ## Write a csv including all the compounds that qualify as hits
  write.table(x = subCpout[subCpout$class != 'control',], file = file.path(dirname(plates[1]), '..', 'Analysis', paste0(column, '_hits.tsv')), sep = '\t', row.names = FALSE, quote = FALSE)
  
  ## Print hit compound names to console
  hits <- droplevels(unique(subCpout$treatment))
  print(paste('Parameter: ', column, sep=''))
  for(hit in hits){
    print(paste(hit, ': ', unique(subCpout[subCpout$treatment == hit, 'compoundName']), sep=''))
  }
}


# Raw data ----------------------------------------------------

fanny <- data.frame(cpout$compoundIdentifier, cpout$compoundcatalogID, cpout$compoundName, cpout$wellRow,
                    cpout$wellCollumn, cpout$plate, cpout$numberOfNuclei, cpout$numberOfInfectedNuclei, 
                    cpout$infectionIndex, cpout$numberOfPlaques, cpout$totalVirusIntensity)
names(fanny) <- substr(names(fanny), 7, 1000L)

fanny$setplate <- rep(LETTERS[1:4], each = 384)
fanny$replicate <- rep(seq(1, 4), each = 384*4)
fanny$virus <- 'HAdV-C2-dE3B-GFP'
fanny_ordered <- fanny[,c('virus', 'compoundIdentifier', 'setplate', 'replicate', 'wellRow', 
                          'wellCollumn', 'plate', 'numberOfNuclei', 'numberOfInfectedNuclei', 
                          'infectionIndex', 'numberOfPlaques', 'totalVirusIntensity')]

write.table(x = fanny_ordered, paste0(rootFolder, 'Analysis/', 'ScreenRaw.tsv'), sep = '\t', quote = FALSE, row.names = FALSE)

# Collated results --------------------------------------------------

collatedResults <- data.frame(compoundName = unique(cpout$compoundName))

# Calculate the mean of all biological replicates of each compound
for(parameter in columnsToNormalize){
  for(compound in collatedResults$compoundName){
    collatedResults[collatedResults$compoundName == compound, paste0('mean_', parameter)] = mean(cpout[cpout$compoundName == compound, parameter])
    collatedResults[collatedResults$compoundName == compound, paste0('mean_', parameter, 'Rel')] = collatedResults[collatedResults$compoundName == compound, paste0('mean_', parameter)]/mean(cpout[cpout$compoundName == 'DMSO', parameter])
  }
}

# Add the information calculated above to the analysis skeleton
ft <- read.csv(file.path(rootFolder, '..', 'Layouts', 'AnalysisSkeleton.csv'), header = T)[,c('compoundName', 'compoundIdentifier', 'compoundcatalogID')]
ftdmso <- ft[ft$compoundName == 'DMSO',][1,]
ftdft <- ft[ft$compoundcatalogID == 'D235475',][1,]
ft <- ft[!(ft$compoundName == 'DMSO' | ft$compoundcatalogID == 'D235475'),]
ft <- rbind(ft, ftdmso, ftdft)
ft <- ft[with(ft, order(compoundName)),]
collatedResults <- collatedResults[with(collatedResults, order(compoundName)),]

merged <- cbind(ft, collatedResults[,-1])
merged$virus <- 'HAdV-C2-dE3B-GFP'

merged_ordered <- merged[, c('virus', 'compoundIdentifier', 'compoundcatalogID', 'compoundName', 
                             'mean_numberOfNuclei', 'mean_numberOfNucleiRel', 'mean_numberOfInfectedNuclei',
                             'mean_numberOfInfectedNucleiRel', 'mean_infectionIndex', 'mean_infectionIndexRel', 
                             'mean_numberOfPlaques', 'mean_numberOfPlaquesRel', 'mean_totalVirusIntensity',
                             'mean_totalVirusIntensityRel')]

write.table(merged, paste(rootFolder, 'Analysis/ScreenScored.tsv', sep=''), sep='\t', row.names = FALSE, quote = FALSE)
