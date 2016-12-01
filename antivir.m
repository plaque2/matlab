%%
%Define inputs
clc
clear
output = evalc('system(''dir Z:\antivir_screen\6-prestwick\6-4_virus_establishment /ad /b /s'')');

allDirs =regexp(output,' ','split');

allDirs =regexp(output,' ','split');

[ind] = regexp(allDirs,'\\TimePoint_\d++$');

ind = find(~cellfun(@isempty,ind));

stitchFolders = naturalSort(allDirs(ind));
processingFolders = regexprep(stitchFolders,'\\TimePoint_\d++$',[filesep filesep 'stitched'])';

resultOutputPath='Z:\antivir_screen\6-prestwick\6-4_virus_establishment\Results';
mkdir(resultOutputPath);

overviewSavePath = 'Z:\antivir_screen\6-prestwick\6-4_virus_establishment\Overviews';
mkdir(overviewSavePath);

% association table 

paramsPrefix= 'Z:\antivir_screen\6-prestwick\6-4_virus_establishment\Results\params';
paramsArray = {'hrvParams.mat','hrvParams.mat',...
'iavParams.mat','iavParams.mat','iavParams.mat','iavParams.mat',...
'hrvParams.mat','hrvParams.mat',...
'hadvParams','hadvParams','hadvParams','hadvParams'}';
plateIDArray = {'p22','p20',...
'p14','p12','p11','p10',...
'p8','p7',...
'p5','p4','p3','p1'}';


paramsArray = cellfun(@(x) [paramsPrefix filesep x],paramsArray,'UniformOutput',false);


assocTable = [processingFolders paramsArray plateIDArray];

assocTableSaveFolder = 'Z:\antivir_screen\6-prestwick\6-4_virus_establishment\Results\params';

save([assocTableSaveFolder filesep 'assocTable'],'assocTable');

%%
%Stitching
% load('stitchingParams.mat');
% parameters.general.fileNamePattern = '(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*)';
% plateNamePattern = '[0-9]*-Antivir-\w*_Plate_[0-9]*';
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
%         plaque2(parameters,curPlatename, curPath,curPath,resultOutputPath);
%         
%         scalingFactor=0.3;
%         removeStitchFolderFlag =0;
%         pattern = '.*(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
%         generateOverviews([curPath 'Stitched'],curPlatename,pattern,overviewSavePath,scalingFactor,removeStitchFolderFlag);
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
%     
     if  ~isempty(ind)
         curPlatename = cell2mat(unique(ind));
         
         disp(curPlatename)
         plaque2(curParams.parameters,curPlatename, curPath,curPath,resultOutputPath);
%        
              
    end
    
    
end






