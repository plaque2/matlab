%%
%%% Usage instructions for multiple parameters per plate
% 1- check and correct all paths
% 2- run plaque2GUIpc.m (or other OS) to create parameters.mat file containing the well selection regex
% 3- run plaque2GUIpc.m (or other OS) to create stitchingParams.m for site pattern
% 4- correct info for association table: correct sequence of plates, especially for different parameters per plate

%%% NO !!!! Since it runs on rolling ball processed images, it's turned off in segmentplaque.m

%%
% To do
% - Insert RB processing
% - Insert overviews on RB

%%
%Define inputs
clc
clear

output = evalc('system(''dir N:\antivir_screen\6-nelfinavir\28_180912_Uphill\180918-Nelf-Uphill /ad /b /s'')');
root = 'N:\antivir_screen\6-nelfinavir\28_180912_Uphill\';

% Select plates to be processed
plateNamePattern = '180918-Nelf-Uphill';
% plateNamePattern = '[0-9]*-9-1-1[A|B]-[0-9][0-9][0-9]hpi_Plate_[0-9]*';

% Well selection, mind tif vs. TIF
wellNamePattern = '(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).tif';
% wellNamePattern = '(?<wellName>[A-H](01|07|08|09|10|11|12))_(?<channelName>w[0-9]*).tif';

% Select wells for overview
overviewPattern = '.*(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';

% Define prefix for overviews
outputPrefix = '';

% Define stitching and overview parameterfile, mind number of sites is taken from this
stitchParamFile = 'stitchingParams_2x2tif.mat';

% Define analysis paramfile
analysisParamFile = 'placeholder.mat';

% Select timepoints to analyze, needs to be uncommented further down in code (for multiple ones write array and itterate over it)
% timePointPattern = 'TimePoint_25';

% Define prefix for analysis output
analysisPrefix = '_';

%%
% Preprocessing
allDirs =regexp(output,' ','split');
% [ind] = regexp(allDirs,'\\Plate_\d++$');
[ind] = regexp(allDirs,'\\TimePoint_\d++$');
ind = find(~cellfun(@isempty,ind));

stitchFolders = allDirs(ind);

% timepointList = regexp(stitchFolders,'Plate_\d++','match'); 
timepointList = regexp(stitchFolders,'TimePoint_\d++','match'); 
timepointList = [timepointList{:}];
[~,sortedIndex] =  naturalSort(timepointList);

stitchFolders = stitchFolders(sortedIndex);

processingFolders = cellfun(@(x) [x filesep 'Stitched'],stitchFolders,'UniformOutput',false)';
% processingFolders = cellfun(@(x) [x filesep 'RollingBall'],stitchFolders,'UniformOutput',false)';

for i=1:length(processingFolders)
    mkdir(processingFolders{i,1});
end
% processingFolders = regexprep(stitchFolders,'\\TimePoint_\d++$',[filesep filesep 'Stitched'])';

%hard code selected stiching folders for subset of plates, use {1} if only one folder:
% processingFolders{1} = 'P:\Fanny_Georgi\9-1_VirusSpread\20170516_9-1-1_SpreadQuantification\Plate_1B\20170516-9-1-1B-002hpi_Plate_4094\TimePoint_1\Stitched'
% mkdir(processingFolders{1});

resultOutputPath = strcat(root,'Results');
% processFolders = naturalSort(allDirs(ind));
% resultOutputPath = regexprep(processFolders,'\\TimePoint_\d++$',[filesep filesep 'Results'])';
mkdir(resultOutputPath);

overviewSavePath = strcat(root,'Overviews');
mkdir(overviewSavePath);

% association table 
paramsPrefix= strcat(root,'Parameters');

% params including well selection 
% paramsArray = {'9-1-8_pV.mat'}
% paramsArray = {'HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', ...
%    'HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', ...
%    'HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', ...
%    'HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat','HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', 'HSV-1_w3.mat', ...
%    'HSV-1_w3.mat','HSV-1_w3.mat'...
%    }';

for i=1:length(stitchFolders)
    disp(i);
    paramsArray{i,1} = analysisParamFile;
    disp(paramsArray{i,1});
end
paramsArray = cellfun(@(x) [paramsPrefix filesep x],paramsArray,'UniformOutput',false);

% plateIDArray = {'TimePoint_46'}
% workaround since natsort doesn' work
% plateIDArray = {'TimePoint_02', 'TimePoint_03', 'TimePoint_04', 'TimePoint_05', 'TimePoint_06', 'TimePoint_07', 'TimePoint_08', 'TimePoint_09', 'TimePoint_10', ...
%    'TimePoint_11', 'TimePoint_12', 'TimePoint_13', 'TimePoint_14', 'TimePoint_15', 'TimePoint_16', 'TimePoint_17', 'TimePoint_18', 'TimePoint_19', 'TimePoint_20', ...
%    'TimePoint_21', 'TimePoint_22', 'TimePoint_23', 'TimePoint_24', 'TimePoint_25', 'TimePoint_26', 'TimePoint_27', 'TimePoint_28', 'TimePoint_29', 'TimePoint_30', ...
%    'TimePoint_31', 'TimePoint_32', 'TimePoint_33', 'TimePoint_34', 'TimePoint_35', 'TimePoint_36', 'TimePoint_37', 'TimePoint_38', 'TimePoint_39', 'TimePoint_40', ...
%    'TimePoint_41', 'TimePoint_42', 'TimePoint_43', 'TimePoint_44', 'TimePoint_45', 'TimePoint_46', 'TimePoint_47', 'TimePoint_48', 'TimePoint_49', 'TimePoint_50', ...
%    'TimePoint_51', 'TimePoint_52', 'TimePoint_53', 'TimePoint_54', 'TimePoint_55', 'TimePoint_56', 'TimePoint_57', 'TimePoint_58', 'TimePoint_59', 'TimePoint_60', ...
%    'TimePoint_61', 'TimePoint_62', 'TimePoint_63', 'TimePoint_64', 'TimePoint_65', 'TimePoint_66', 'TimePoint_67', 'TimePoint_68', 'TimePoint_69', 'TimePoint_70', ...
%    'TimePoint_71', 'TimePoint_72', 'TimePoint_73', 'TimePoint_74', 'TimePoint_75', 'TimePoint_76', 'TimePoint_77', 'TimePoint_78', 'TimePoint_79', 'TimePoint_80', ...
%    'TimePoint_81', 'TimePoint_82', 'TimePoint_83', 'TimePoint_84', 'TimePoint_85', 'TimePoint_86', 'TimePoint_87', 'TimePoint_88', 'TimePoint_89', 'TimePoint_90', ...
%    'TimePoint_91', 'TimePoint_92', 'TimePoint_93', 'TimePoint_94', 'TimePoint_95', 'TimePoint_01'...
% }';

for i=1:length(stitchFolders)
    disp(i);
    plateIDArray{i,1} = strcat(outputPrefix,num2str(i));
    disp(plateIDArray{i,1});
end

assocTable = [processingFolders paramsArray plateIDArray];
assocTableSaveFolder = strcat(root,'Parameters');
save([assocTableSaveFolder filesep 'assocTable'],'assocTable');

%%
% Stitching

% disp('Started stitching');
% load(stitchParamFile); 
% 
% [r,c] = size(stitchFolders);
% parfor i=1:(c) %length(stitchFolders)
%     
%     curPath  = strtrim(stitchFolders{i});
%     ind = regexp(curPath,plateNamePattern,'match');
%     
%     if  ~isempty(ind)
%         curPlatename = cell2mat(unique(ind));
%         
%         disp(curPlatename)
%         disp(processingFolders{i})
%         plaque2(parameters, curPlatename, curPath, processingFolders{i}, resultOutputPath);
%               
%     end
%     
% end

%%
% Overviews

disp('Started generating overviews');
load(stitchParamFile); 

[r,c] = size(stitchFolders);
for i=1:length(stitchFolders)
    
    curPath  = strtrim(processingFolders{i});
    
    ind = regexp(curPath,plateNamePattern,'match');
    
    if  ~isempty(ind)

        %for live experiments, it's better to add plateID as suffix
        curPlatename = cell2mat(unique(ind));
        plateSaveName = strcat(curPlatename,'_',cell2mat(plateIDArray(i)));
        disp(plateSaveName)
        
        pattern = overviewPattern;
        
        scalingFactor=0.3;
        removeStitchFolderFlag =0;
        
        generateOverviews(processingFolders{i}, plateSaveName, pattern, overviewSavePath, scalingFactor, removeStitchFolderFlag);
        
    end
    
end


%%
% Processing


% disp('Started processing');
% [r,c] = size(processingFolders);
% 
% %parfor is a bitch
% for i = 1:r
% %for i = 1:2
% %     
% %     %if cell2mat(plateIDArray(i)) == timePointPattern
%         
%         curPath  = strtrim(processingFolders{i});
%         % curOutput = resultOutputPath{i};
%         curParams = load(assocTable{i,2});
% 
%          ind = regexp(curPath,plateNamePattern,'match');
% 
% 
%          if  ~isempty(ind)
%              %for live experiments, it's better to add plateID as suffix
%              curPlatename = cell2mat(unique(ind));
%              plateSaveName = strcat(curPlatename,analysisPrefix,cell2mat(plateIDArray(i)));
%              disp(plateSaveName)
% 
%              plaque2(curParams.parameters, plateSaveName, curPath, curPath, resultOutputPath, wellNamePattern); % curOutput);
% 
%          end
%     %end
%     
% end