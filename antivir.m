%%
%%% usage instructions
% 1- check and correct all paths
% 2- run plaque2GUIpc.m (or other OS) and create stitchingParams.m for correct input
% 3- correct info for association table: correct sequence of plates, optimized plaque parameters


%Define inputs
clc
clear
output = evalc('system(''dir N:\antivir_screen\6-prestwick\6-4_virus_establishment /ad /b /s'')');

allDirs =regexp(output,' ','split');

allDirs =regexp(output,' ','split');

[ind] = regexp(allDirs,'\\TimePoint_\d++$');

ind = find(~cellfun(@isempty,ind));

stitchFolders = naturalSort(allDirs(ind));
%processingFolders = regexprep(stitchFolders,'\\TimePoint_\d++$',[filesep filesep 'stitched'])';
% hard code selected stiching folders for subset of plates
processingFolders{1} = 'N:\antivir_screen\6-prestwick\6-4_virus_establishment\160524-AntiVir-virus1_Plate_2659\stitched'

resultOutputPath='N:\antivir_screen\6-prestwick\6-4_virus_establishment\Results';
mkdir(resultOutputPath);

overviewSavePath = 'N:\antivir_screen\6-prestwick\6-4_virus_establishment\Overviews';
mkdir(overviewSavePath);

% association table 
paramsPrefix= 'N:\antivir_screen\6-prestwick\6-4_virus_establishment\Results\params';
paramsArray = {'iavParams_FG.mat'}';
plateIDArray = {'p12'}';

paramsArray = cellfun(@(x) [paramsPrefix filesep x],paramsArray,'UniformOutput',false);

assocTable = [processingFolders paramsArray plateIDArray];

assocTableSaveFolder = 'N:\antivir_screen\6-prestwick\6-4_virus_establishment\Results\params';

save([assocTableSaveFolder filesep 'assocTable'],'assocTable');

%%
%Stitching
% load('stitchingParams.mat'); 
% parameters.general.fileNamePattern = '.*(?<wellName>[A-Z][0-9]*)_(?<siteName>s[0-9])_(?<channelName>w[0-9]).TIF';
% plateNamePattern = '[0-9]*-AntiVir-confirm-\w*_Plate_[0-9]*';
% 
% 
% 
% parfor i=1:length(stitchFolders)
%     
%     curPath  = strtrim(stitchFolders{i});
%     
%     ind = regexp(curPath,plateNamePattern,'match');
%     
%     if  ~isempty(ind)
%         curPlatename = cell2mat(unique(ind));
%         
%         disp(curPlatename)
%         plaque2(parameters, curPlatename, curPath, processingFolders{i}, resultOutputPath);
%         
%         scalingFactor=0.3;
%         removeStitchFolderFlag =0;
%         pattern = '.*(?<wellName>[A-Z][0-9]*)_(?<siteName>s[0-9]*)_(?<channelName>w[0-9]*).TIF';
%         generateOverviews(processingFolders{i}, curPlatename, pattern, overviewSavePath, scalingFactor, removeStitchFolderFlag);
%         
%     end
%     
%     
% end

%%
% Overviews
% 
% load('stitchingParams.mat'); 
% plateNamePattern = '[0-9]*-AntiVir-confirm-\w*_Plate_[0-9]*';
% 
% 
% 
% parfor i=1:length(processingFolders)
%     
%     curPath  = strtrim(processingFolders{i});
%     
%     ind = regexp(curPath,plateNamePattern,'match');
%     
%     if  ~isempty(ind)
%         curPlatename = cell2mat(unique(ind));
%         
%         disp(curPlatename)
%         
%         scalingFactor=0.3;
%         removeStitchFolderFlag =0;
%         pattern = '.*(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
%         generateOverviews(processingFolders{i}, curPlatename, pattern, overviewSavePath, scalingFactor, removeStitchFolderFlag);
%         
%     end
%     
%     
% end


%%
%Processing

plateNamePattern = '[0-9]*-AntiVir-\w*_Plate_[0-9]*';


parfor i=1:length(processingFolders)
    
    curPath  = processingFolders{i};
    curParams = load(assocTable{i,2});
    
     ind = regexp(curPath,plateNamePattern,'match');
    
     if  ~isempty(ind)
         curPlatename = cell2mat(unique(ind));
         
         disp(curPlatename)
         plaque2(curParams.parameters, curPlatename, curPath, curPath, resultOutputPath);
       
              
    end
    
    
end






