function generateOverviews(processingFolder,plateName,fileNamePattern,outputFolder,scalingFactor,removeStitchFolderFlag)
%DESCRIPTION - Generates rectangular overviews of plates for each channel


% plateName ='DMSO_Initial';
% plateName ='DMSO_Cleaned';

removeStitchFolderFlag =0;
% processingFolder = 'Z:\Vardan_Andriasyan\Novartis\Wuxi3b\160125-VA-Wuxi3b-DMSO-plq-3dpi_Plate_2118\TimePoint_1\Stitched';
% plateName = 'HADV';
%  
%   fileNamePattern = '(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
%   outputFolder = 'C:\Users\Vardan\Desktop\WUXI_EMAIL';
% %  resizedImages = [];
%  scalingFactor = 0.2;
% 



    parseOutput = parseImageFilenames(processingFolder,fileNamePattern);
    

for iChannel = 1:length(parseOutput.channelNames)
    
%     fileList = getFileListForWell(parseOutput.matchedFileNames,processingPattern,parameters.virus.selectedChannel);
      [currentChannelAllImages allRows allCollumns] = getFileListForWell(parseOutput.matchedFileNames,fileNamePattern,parseOutput.channelNames{iChannel});
    
      
for iFileName=1:length(currentChannelAllImages)

currentImage = imread(fullfile(processingFolder,currentChannelAllImages{iFileName}));
currentImage = imresize(currentImage,scalingFactor);

resizedImages{iFileName} = currentImage;


% imsave(h)
end

 resizedImages = (reshape(resizedImages,length(unique(allCollumns)),length(unique(allRows)))');
 imwrite((cell2mat(resizedImages)),fullfile(outputFolder,[plateName '_' parseOutput.channelNames{iChannel} '.tif']),'tif'); 
  

% imwrite(cell2mat(resizedImages(1:12)),fullfile(outputFolder,[plateName '_' parseOutput.channelNames{iChannel} '.tif']),'tif'); 


%  overviewHandle = imshow(cell2mat(resizedImages),[0 6000]);
% % colormap('gray'); 
% 
% overviewImage = getimage(overviewHandle);
end
if removeStitchFolderFlag
rmdir(processingFolder,'s');
end
%
% %     Plaque2.0 - a virological assay reloaded
% %     Copyright (C) 2014  Artur Yakimovich, Vardan Andriasyan
% % 
% %     This program is free software: you can redistribute it and/or modify
% %     it under the terms of the GNU General Public License as published by
% %     the Free Software Foundation, either version 3 of the License, or
% %     (at your option) any later version.
% % 
% %     This program is distributed in the hope that it will be useful,
% %     but WITHOUT ANY WARRANTY; without even the implied warranty of
% %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
