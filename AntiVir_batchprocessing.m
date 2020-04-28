%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plaque2.0 batch processing for the AntiVir screen
%%% Written by Fanny Georgi and Vardan Andriasyan, University of Zurich,
%%% March 2020

clc
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User inputs
rootFolder = '...\\idr0081\\3-Screen\\Data_UZH\\';
experimentName = 'AntiVirHAdV';

% Since wells are imaged in a single site, no stitching has to be
% performed. To batch stitching, save a Plaque2.0 parameter file with an
% active stitching tab indicating the stitch dimension.s
%stitchParams = strcat(rootFolder,'Parameters','\\','stitching_2x2.mat'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ground work
plateFolder = strcat(rootFolder,'Screen');
inputCommand = 'system(''dir plateFolder /ad /b /s'')';
inputCommand = regexprep(inputCommand,'plateFolder',plateFolder);
output = evalc(inputCommand);

allDirs =regexp(output,' ','split');
[ind] = regexp(allDirs,'\\BSF[0-9]*-[0-9][A-Z]$');
ind = find(~cellfun(@isempty,ind));
processingFolders = allDirs(ind);

resultOutputPath = strcat(rootFolder,'Results');
mkdir(resultOutputPath);
overviewSavePath = strcat(rootFolder,'Overviews');
mkdir(overviewSavePath);

% Association table parameters
paramsPrefix = strcat(rootFolder,'Parameters');
plaque20ParamsArray = {'Screen_1A.mat','Screen_1B.mat','Screen_1C.mat','Screen_1D.mat',...
    'Screen_2A.mat','Screen_2B.mat','Screen_2C.mat','Screen_2D.mat',...
    'Screen_3A.mat','Screen_3B.mat','Screen_3C.mat','Screen_3D.mat',...
    'Screen_4A.mat','Screen_4B.mat','Screen_4C.mat','Screen_4D.mat',}';
plateFolderArray = dir([plateFolder]);
plateNames = {plateFolderArray.name};
plateIDArray = plateNames (3:end)';
paramsArray = cellfun(@(x) [paramsPrefix filesep x],plaque20ParamsArray,'UniformOutput',false);
assocTable = [processingFolders' paramsArray plateIDArray];
assocTableSaveFolder = paramsPrefix;

% Well selection using regular expressions
wellNamePattern = 'BSF[0-9]*-[0-9][A-Z]_(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
% Plate selection using regular expressions
plateNamePattern = 'BSF[0-9]*-[0-9][A-Z]';
% Save association table
save([assocTableSaveFolder filesep 'assocTable'],'experimentName');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Stitching
%  
% disp('Started stitching');
% load(stitchParamFile); 
% [r,c] = size(stitchFolders);
% parfor i=1:(c) 
%
%     curPath  = strtrim(stitchFolders{i});
%     ind = regexp(curPath,plateNamePattern,'match');
%     
%     if  ~isempty(ind)
%         curPlatename = cell2mat(unique(ind));
%         disp(curPlatename)
%         disp(processingFolders{i})
%         plaque2(parameters, curPlatename, curPath, processingFolders{i}, resultOutputPath);
%               
%     end
%     
% end
%
% disp('Finished stitching');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Overviews

% disp('Started generating overviews');
% load(stitchParams); 
% [r,c] = size(processingFolders);
%
% parfor i=1:r 
%     
%     curPath  = strtrim(processingFolders{i});
%     ind = regexp(curPath,plateNamePattern,'match');
%     
%     if  ~isempty(ind)
%         curPlatename = cell2mat(unique(ind));
%         disp(curPlatename)
%         scalingFactor=0.3;
%         removeStitchFolderFlag =0;
%         pattern = wellNamePattern
%         generateOverviews(processingFolders{i}, curPlatename, pattern, overviewSavePath, scalingFactor, removeStitchFolderFlag);
%         
%     end
%     
% end
%
% disp('Finished generating overviews');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Processing

disp('Started scoring infection');
[r,c] = size(processingFolders);

parfor i=1:c 
    
    curPath  = strtrim(processingFolders{i});

    curParams = load(assocTable{i,2});

     ind = regexp(curPath,plateNamePattern,'match');
     
     if  ~isempty(ind)
         curPlatename = cell2mat(unique(ind));
         plateSaveName = cell2mat(plateIDArray(i));
         disp(plateSaveName)
         plaque2(curParams.parameters, plateSaveName, curPath, curPath, resultOutputPath, wellNamePattern); 
       
    end
    
end

disp('Finished scoring infection');






