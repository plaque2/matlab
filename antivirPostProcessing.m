%Postprocessing
clc
clear
close all

%%%Define Environment variables
readFolderPath = 'Z:\antivir_screen\6-prestwick\6-4_virus_establishment\Results';
layoutFolderPath = 'C:\Users\Vardan\Google Drive\!LabGang\Prestwick_Screen\Establishment\Analysis\';
%%Read files
allDataFiles = dir(fullfile(readFolderPath,'*.mat'));
allDataFiles = fullfile(readFolderPath,{allDataFiles.name})';

load('Z:\antivir_screen\6-prestwick\6-4_virus_establishment\Results\params\assocTable.mat');

allLayoutFiles = dir(fullfile(layoutFolderPath,'*.csv'));
allLayoutFiles = fullfile(layoutFolderPath,{allLayoutFiles.name})';

% plateCollumnNames = {'c01','c02','c03','c04','c05','c06','c07','c08','c09','c10','c11',...
%     'c12','c13','c14','c15','c16','c17','c18','c19','c20','c21','c22','c23','c24'};
% plateRowNames = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'};

%%% Aggregate the Plaque 2.0 output into a single table and 
%%%generate a unique ID collumn p{PLATE_NUMBER}_v{VIRUS}_d{VIRUS_DILUTION}_v{INFECTION 1 or 0}_n{DRUG}_m{DRUG CONCENTRATION IN uM}

for iPlate=1:length(allDataFiles)
    
    layoutIndex = find(~cellfun(@isempty,...
        regexp(allLayoutFiles,[assocTable{iPlate,3} '_']))); %get corresponding layout
             
    aggrData = load(allDataFiles{iPlate});
    currentImageData = aggrData.ImageDataArray;
   
    currentLayout  = readtable(allLayoutFiles{layoutIndex},'HeaderLines',0,'ReadVariableNames',1,'ReadRowNames',1);
    
    layoutFileNamePrefix = regexp(allLayoutFiles{layoutIndex},'p[0-9]*_v\w*_d\w*','match');
    
    for iWell = 1:length(currentImageData)
        layoutRow= currentImageData(iWell).wellRow;
        layoutCol = ['x' num2str(str2double(currentImageData(iWell).wellCollumn))]; % Matlab add a prefix 'x' when reading the collumns of the csv
        currentUniqueID(iWell) = strcat(layoutFileNamePrefix{:},'_',currentLayout{layoutRow,layoutCol});
    end
    
    currentImageDataTable = horzcat(struct2table(currentImageData),cell2table(currentUniqueID','VariableNames',{'uniqueID'}));
    if iPlate==1
        aggrImageDataTable = currentImageDataTable;
    else
        aggrImageDataTable = [aggrImageDataTable;currentImageDataTable];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VIRUSES HAdV,HRV,IAV
% CONTROLS    mock,dmso,meoh   
% DRUGS arac,dft,baf,nicl,brefa


mockIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,'p[0-9]*_vHAdV_d\w*_v0_nmock_m\w*')));
mockValues = aggrImageDataTable.uniqueID(mockIndices);
mockNucleiNum = aggrImageDataTable.numberOfNuclei(mockIndices);

% dmso
dmsoIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,'p[0-9]*_vHAdV_d\w*_v0_ndmso_m0.1')));
dmsoValues = aggrImageDataTable.uniqueID(dmsoIndices);
dmsoNucleiNum = aggrImageDataTable.numberOfNuclei(dmsoIndices);

% meoh
meohIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,'p[0-9]*_vHAdV_d\w*_v0_nmeoh_m0.1')));
meohValues = aggrImageDataTable.uniqueID(meohIndices);
meohNucleiNum = aggrImageDataTable.numberOfNuclei(meohIndices);

GRAPHPAD_OUT_SOLVENT_TOX = [mockNucleiNum./mean(mockNucleiNum(:))  dmsoNucleiNum./mean(mockNucleiNum(:)) meohNucleiNum./mean(mockNucleiNum(:))];

% % arac
% concentrations = {'0.01','0.1','1','10'};
% for iConc = 1:length(concentrations)
% aracIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d\w*_v0_narac_m' concentrations{iConc} '$'])));
% aracValues = aggrImageDataTable.uniqueID(aracIndices);
% aracNucleiNum(iConc,:) = aggrImageDataTable.numberOfNuclei(aracIndices);
% end
% aracNucleiNum = aracNucleiNum./mean(mockNucleiNum(:));
% 
% % dft
% concentrations = {'0.01','0.1','1','10'};
% for iConc = 1:length(concentrations)
% dftIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d\w*_v0_ndft_m' concentrations{iConc} '$'])));
% dftValues = aggrImageDataTable.uniqueID(dftIndices);
% dftNucleiNum(iConc,:) = aggrImageDataTable.numberOfNuclei(dftIndices);
% end
% dftNucleiNum = dftNucleiNum./mean(mockNucleiNum(:));
% 
% 
% % baf
% concentrations = {'0.0001','0.001','0.01','0.1'};
% for iConc = 1:length(concentrations)
% bafIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d\w*_v0_nbaf_m' concentrations{iConc} '$'])));
% bafValues = aggrImageDataTable.uniqueID(bafIndices);
% bafNucleiNum(iConc,:) = aggrImageDataTable.numberOfNuclei(bafIndices);
% end
% bafNucleiNum = bafNucleiNum./mean(mockNucleiNum(:));
% 
% 
% % nicl
% concentrations = {'0.01','0.1','1','10'};
% for iConc = 1:length(concentrations)
% niclIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d\w*_v0_nnicl_m' concentrations{iConc} '$'])));
% niclValues = aggrImageDataTable.uniqueID(niclIndices);
% niclNucleiNum(iConc,:) = aggrImageDataTable.numberOfNuclei(niclIndices);
% end
% niclNucleiNum = niclNucleiNum./mean(mockNucleiNum(:));
% 
% % brefa
% concentrations = {'0.01','0.1','1','10'};
% for iConc = 1:length(concentrations)
% brefaIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d\w*_v0_nbrefa_m' concentrations{iConc} '$'])));
% brefaValues = aggrImageDataTable.uniqueID(brefaIndices);
% brefaNucleiNum(iConc,:) = aggrImageDataTable.numberOfNuclei(brefaIndices);
% end
% brefaNucleiNum = brefaNucleiNum./mean(mockNucleiNum(:));
% 
% GRAPHPAD_OUT_DRUG_TOX =  [aracNucleiNum dftNucleiNum bafNucleiNum niclNucleiNum brefaNucleiNum];




%HAdV at  dilution d8e6

   curIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d8e6_v1_nmock_m\w*'])));
   curValues = aggrImageDataTable.uniqueID(curIndices);

mockControlINFIND =  aggrImageDataTable.numberOfInfectedNuclei(curIndices)./aggrImageDataTable.numberOfNuclei(curIndices);
mockControlTGFP = aggrImageDataTable.totalVirusIntensity(curIndices);
mockControlPlaqueNumber = aggrImageDataTable.numberOfPlaques(curIndices);
    drugs = {'arac','dft','baf','nicl','brefa'};
%     concentrations = {'0.01','0.1','1','10'};
for iDrug = 1:length(drugs)

    if strcmp(drugs{iDrug},'baf')
        concentrations = {'0.0001','0.001','0.01','0.1'};
    else
        concentrations = {'0.01','0.1','1','10'};
    end
   for iConc = 1:length(concentrations)
   curIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d8e6_v1_n' drugs{iDrug} '_m' concentrations{iConc} '$'])));
   curValues = aggrImageDataTable.uniqueID(curIndices);
   GRAPHPAD_OUT_INFIND_HADV(iConc,:,iDrug) = aggrImageDataTable.numberOfInfectedNuclei(curIndices)./aggrImageDataTable.numberOfNuclei(curIndices);
   GRAPHPAD_OUT_TGFP_HADV(iConc,:,iDrug) = aggrImageDataTable.totalVirusIntensity(curIndices);
   GRAPHPAD_OUT_PLAQUENUM_HADV(iConc,:,iDrug) = aggrImageDataTable.numberOfPlaques(curIndices);
   curIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d8e6_v0_n' drugs{iDrug} '_m' concentrations{iConc} '$'])));
   curValues = aggrImageDataTable.uniqueID(curIndices);
   GRAPHPAD_OUT_CELLNUM_HADV(iConc,:,iDrug) = aggrImageDataTable.numberOfNuclei(curIndices);
  
   
   
   end
    
    
end
GRAPHPAD_OUT_INFIND_HADV = reshape(GRAPHPAD_OUT_INFIND_HADV,4,40)./mean(mockControlINFIND(:)); 
GRAPHPAD_OUT_TGFP_HADV = reshape(GRAPHPAD_OUT_TGFP_HADV,4,40)./mean(mockControlTGFP(:)); 
GRAPHPAD_OUT_CELLNUM_HADV = reshape(GRAPHPAD_OUT_CELLNUM_HADV,4,40)./mean(mockNucleiNum(:)); 
GRAPHPAD_OUT_THERIND = GRAPHPAD_OUT_CELLNUM_HADV./GRAPHPAD_OUT_INFIND_HADV;
GRAPHPAD_OUT_PLAQUENUM_HADV = reshape(GRAPHPAD_OUT_PLAQUENUM_HADV,4,40)./mean(mockControlPlaqueNumber(:)); 
% 
% 
% 
% curIndices = find(~cellfun(@isempty,regexp(aggrImageDataTable.uniqueID,['p[0-9]*_vHAdV_d\w*_v1_nmock_m\w*'])));
% curValues = aggrImageDataTable.uniqueID(curIndices);
% [curValues,sortIndex] =  naturalSort(curValues);
% curIndices = curIndices(sortIndex);
% infectionIndex = reshape(aggrImageDataTable.numberOfInfectedNuclei(curIndices)./aggrImageDataTable.numberOfNuclei(curIndices),8,4)';
% plaqueNumber = reshape(aggrImageDataTable.numberOfPlaques(curIndices),8,4)';
% totalGFPIntensity = reshape(aggrImageDataTable.totalVirusIntensity(curIndices),8,4)';
% %HRV
% 
% %IAV

