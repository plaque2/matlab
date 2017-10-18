%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plaque 2.0 bulk processing for the ANtiVir screen
%%% Written by Fanny Georgi, Vardan Andriasyan, University of Zurich

% Current experiment: 6-20


%%% Usage instructions
% 1- check and correct all paths
% 2- run plaque2GUIpc.m (or other OS) and create stitchingParams.m for correct input
% 3- correct info for association table: correct sequence of plates, optimized plaque parameters

clc
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define inputs

rootFolder = 'N:\antivir_screen\6-prestwick\6-20-22_HAdV_Z_a-b';

% Imaging outpu folder, multiple time points as folders "TimePoints_i"
output = evalc('system(''dir 'rootFolder ' /ad /b /s'')');
allDirs =regexp(output,' ','split');
[ind] = regexp(allDirs,'\\TimePoint_\d++$');
ind = find(~cellfun(@isempty,ind));
stitchFolders = naturalSort(allDirs(ind));

% Stitching not necessary with IXM-C, keep loading parameters as scaffold
% If no path is given, file must be saved in same folder as this script
stitchParams = 'stitchingParams_IXM1_2x3.mat'

% Define where stitched images are saved
% processingFolders = cellfun(@(x) [x filesep 'Stitched'],stitchFolders,'UniformOutput',false)';
% for i=1:length(processingFolders)
%     mkdir(processingFolders{i,1});
% end
% If no stitching needs to be performed, stitching and processing folders are the same
processingFolders = stitchFolders.';

% Hard code selected stiching folders for subset of plates, use {1} if only one folder:
% processingFolders{1} = 'N:\antivir_screen\6-prestwick\6-18_IAV_preZ\170901-6-18-IAV-preZ_Plate_706\TimePoint_1';
% mkdir(processingFolders{1});

resultOutputPath = strcat(rootFolder,'Results');
mkdir(resultOutputPath);

overviewSavePath = strcat(rootFolder,'Overviews');
mkdir(overviewSavePath);

% Association table parameters
paramsPrefix = strcat(rootFolder,'Parameters');
% Number of parameter files and plate IDs must be identical and must correspond to the number of folders in the imaging output folder
paramsArray = {'HAdV-6-20.mat', 'HAdV-6-20.mat'}';
plateIDArray = {'HAdV_6-20', 'HAdV_6-22'}';

% Alternatively, automatically fill arrays with identical parameters
% for i=1:length(processingFolders)
%     paramsArray{i,1} = 'HAdV-6-20.mat';
% end
% for i=1:length(processingFolders)
%     plateIDArray{i,1} = strcat('TimePoint_',i);
% end

paramsArray = cellfun(@(x) [paramsPrefix filesep x],paramsArray,'UniformOutput',false);
assocTable = [processingFolders paramsArray plateIDArray];
assocTableSaveFolder = paramsPrefix

% Well selection using regular expressions
wellNamePattern = '(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
% Plate selection using regular expressions
plateNamePattern = '[0-9]*-6-[0-9][0-9]-HAdV-pZ-[a|b]_Plate_[0-9]*';
% Save association table
save([assocTableSaveFolder filesep 'assocTable'],'assocTable');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Stitching
% Always has to be performed first and in separate run from Overviews and Analysis
% Not necessary if imaged at 4x using IXM-C

% load(stitchParams); 
% parameters.general.fileNamePattern = '.*(?<wellName>[A-Z][0-9]*)_(?<siteName>s[0-9])_(?<channelName>w[0-9]).TIF';
% 
% [r,c] = size(stitchFolders);
% parfor i=1:c %length(stitchFolders)
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
%         pattern = wellNamePattern
%         generateOverviews(processingFolders{i}, curPlatename, pattern, overviewSavePath, scalingFactor, removeStitchFolderFlag);
%         
%     end
%    
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Overviews

% Stitch parameters not needed, merely data frame if IXM-C 4x imaged
load(stitchParams); 

[r,c] = size(processingFolders);
parfor i=1:r %length(processingFolders)
    
    curPath  = strtrim(processingFolders{i});
    
    ind = regexp(curPath,plateNamePattern,'match');
    
    if  ~isempty(ind)
        curPlatename = cell2mat(unique(ind));

        disp(curPlatename)
        
        scalingFactor=0.3;
        removeStitchFolderFlag =0;
        pattern = wellNamePattern
        generateOverviews(processingFolders{i}, curPlatename, pattern, overviewSavePath, scalingFactor, removeStitchFolderFlag);
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Processing

[r,c] = size(processingFolders);
parfor i=1:r %length(processingFolders)
    
    curPath  = strtrim(processingFolders{i});
    % curOutput = resultOutputPath{i};
    curParams = load(assocTable{i,2});

     ind = regexp(curPath,plateNamePattern,'match');
     
     if  ~isempty(ind)
         curPlatename = cell2mat(unique(ind));
         plateSaveName = strcat(curPlatename,'_',cell2mat(plateIDArray(i)));
         disp(plateSaveName)
         
         plaque2(curParams.parameters, plateSaveName, curPath, curPath, resultOutputPath, wellNamePattern); % curOutput);
       
    end
    
end






