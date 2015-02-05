function [numOfNuclei,BW] = segmentnuclei(inputImage,nucleiParams)
% INPUTS:
% varargin -   
% Output: [numOfNuclei,BW]
% ToDo: add description




  
   artifactThreshold =  nucleiParams.artifactThreshold; % upper threshold for artifact cleaning to enhance otsu thresholding
%     
%apply the artifact threshold
   inputImage(inputImage>2^16*artifactThreshold) = min(inputImage(:));






if (nucleiParams.illuminationCorrectionFlag)
%     gaussSize = length(inputImage)/2;
%     gaussSigma = nucleiParams.correctionGaussianSigma;
%     gaussianFilter =  fspecial('gaussian', gaussSize,gaussSigma);
% 
%     fun = @(block_struct) ...
%         imfilter(block_struct.data,gaussianFilter,'conv');
%     filteredImage = blockproc(inputImage,[gaussSize gaussSize],fun);
%     
%     
%     
%     
%   filteredImage  =inputImage -filteredImage;
%     %
%   filteredImage = uint16(medfilt2(filteredImage,[3 3]));
%     
%     inputImage = histeq(filteredImage);
    
   
    se = strel('ball',nucleiParams.correctionBallRadius,nucleiParams.correctionBallRadius);
    inputImage = imtophat(inputImage,se);

end




switch nucleiParams.selectedThresholdingMethod
    case 'manualThresholding'
        
        manualThreshold = nucleiParams.manualThreshold;
       
        %create a B&W using the calculated level
        BW = im2bw(inputImage,manualThreshold);
   
    case 'globalOtsuThresholding'
         
        threshodlCorrectionFactor =  nucleiParams.thresholdCorrectionFactor;
        minimalThreshold =  nucleiParams.minimalThreshold;
     
        level = graythresh(inputImage);
       
        if level < minimalThreshold
            level = minimalThreshold;
        end
         disp(['level: ',num2str(level)]);
        
        %create a B&W using the calculated level
        BW = im2bw(inputImage,level*threshodlCorrectionFactor);

    case 'localOtsuThresholding'
       
        blockSize =  nucleiParams.blockSize;
        BW = thresholdLocally(inputImage,blockSize);
    otherwise
        error('No valid method selected');
        %throw an error
end

numOfNuclei = countcells(BW,nucleiParams.minCellArea,nucleiParams.maxCellArea);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     Plaque2.0 - a virological assay reloaded
%     Copyright (C) 2015  Artur Yakimovich, Vardan Andriasyan
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
