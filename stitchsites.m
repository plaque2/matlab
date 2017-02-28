% Artur Yakimovich and Vardan Andriasyan
% University of Zurich. Copyright (C) 2012. Simple No-overlap-stitichng Function.
function  output = stitchsites(parameters,testWellSitesFilenames)

if nargin <1
    error('NoParametersSpecified','ERROR:No parameters specified');
    
end

if nargin <2
    testMode = 0;
else
    testMode = 1;
end


xNumber =parameters.stitch.xImageNumber;
yNumber = parameters.stitch.yImageNumber;


if(~testMode)
    
    
    inputFolder = parameters.stitch.inputFolder;
    saveFolder =    parameters.general.processingFolder;
    filenamePattern = parameters.stitch.fileNamePattern;
    
    if(~isdir(saveFolder))
        mkdir(saveFolder)
    end
    
    
    parseOutput  = parseImageFilenames(inputFolder,filenamePattern);
    try
        matchedFileNames = parseOutput.matchedFileNames;
        if(isfield(parseOutput,'channelNames'));
        numberOfChannels = length(parseOutput.channelNames);
        else
         numberOfChannels=1;
        end
        numberOfRows =length(parseOutput.wellRows);
        numberOfCollumns =length(parseOutput.wellCollumns);
    catch errorMsg
        
        error('Stitch:ParseError','Can not parse images with the current pattern');
        
    end
    for iChannel= 1:numberOfChannels
        for iRow = 1:numberOfRows
            for iCollumn = 1:numberOfCollumns
                
                
                outputFileList=  getFileListForWell(matchedFileNames,filenamePattern,parseOutput.wellRows{iRow},parseOutput.wellCollumns{iCollumn},parseOutput.channelNames{iChannel});
                %Check if aborted by user from GUI
                if isappdata(0,'isAnalysisRunning')
                    drawnow;
                    if (getappdata(0,'isAnalysisRunning')==0)
                    error('STITCH:AbortedByUser','Aborted by User');
                    end
                end
                disp([parseOutput.wellRows{iRow},parseOutput.wellCollumns{iCollumn},parseOutput.channelNames{iChannel}]);
                if (length(outputFileList) ~=xNumber*yNumber)
                    error('Stitch:DimensionMismatch','Incorrect number of images to be stitched');
                end
                    
                currentWellImage = stitchWell(fullfile(inputFolder,outputFileList),xNumber,yNumber);
                output = 'Succesfully stitched';
                
                imwrite(currentWellImage,fullfile(saveFolder,[parseOutput.wellRows{iRow} parseOutput.wellCollumns{iCollumn} '_' parseOutput.channelNames{iChannel} '.TIF']));
             
            end
        end
    end
    
    
else
    
    output = stitchWell(testWellSitesFilenames,xNumber,yNumber);
    
end

function wellImage = stitchWell(wellSitesFilenames,xNumber,yNumber)

if(xNumber*yNumber ~= length(wellSitesFilenames))
    error('Stitch:WrongNumberOfSites','Number of sites is inconsistent with specified Horizontal and Vetical image numbers');
end

ImgCounter = 1;
for y = 1:yNumber
    for x =  1:xNumber
        StitchedCell{y,x} = imread(wellSitesFilenames{ImgCounter});
        ImgCounter = ImgCounter +1;
    end
end
wellImage = cell2mat(StitchedCell(:,:));



%     Plaque2.0 - a virological assay reloaded
%     Copyright (C) 2014  Artur Yakimovich, Vardan Andriasyan
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.