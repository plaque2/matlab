function [numOfNuclei,BW] = segmentnuclei(inputImage,nucleiParams)
% INPUTS:
% varargin -   
% Output: [numOfNuclei,BW]
% ToDo: add description




   processedImage = inputImage;
   artifactThreshold =  nucleiParams.artifactThreshold; % upper threshold for artifact cleaning to enhance otsu thresholding
%     
%apply the artifact threshold
   processedImage(processedImage>2^16*artifactThreshold) = min(processedImage(:));






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
    
 bcg = imopen((processedImage),strel('disk',nucleiParams.correctionBallRadius)); 
%imwrite(bcg,'bcg.tif');
%bcg = imread('bcg.tif');
% figure(10)
% surf(double(bcg(1:100:end,1:100:end))),zlim([0 2000]);
% ax = gca;
% ax.YDir = 'reverse';
% figure(11)
% imshow((processedImage - bcg),[0 6000]);
% figure(12)
% imshow(processedImage,[0 2000]);
% processedImage = (processedImage - bcg,'Distribution','rayleigh');
processedImage = processedImage - bcg;
% K = wiener2(J,[5 5]);

% 
% 
% se = strel('disk',nucleiParams.correctionBallRadius);
% theorPSF = double(se.getnhood);
% processedImage = edgetaper(processedImage,theorPSF);
% % theorPSF = ones(size(PSF));
% processedImage = deconvblind(processedImage,theorPSF,5);
% t1=imsharpen(processedImage,'Radius',2,'Amount',1);
% figure(10)
% imshow(processedImage,[0 6000]);
% figure(11)
% imshow(inputImage,[0 6000]);    
% figure(12)
% imshow(t1,[0 6000]);    
% figure(13)
% im2bw(t1,0.02);        
%     inputImage = imtophat(inputImage,se);

end




switch nucleiParams.selectedThresholdingMethod
    case 'manualThresholding'
        
        manualThreshold = nucleiParams.manualThreshold;
       
        %create a B&W using the calculated level
        BW = im2bw(processedImage,manualThreshold);
   
    case 'globalOtsuThresholding'
         
        threshodlCorrectionFactor =  nucleiParams.thresholdCorrectionFactor;
        minimalThreshold =  nucleiParams.minimalThreshold;
     
        level = graythresh(processedImage);
       
        if level < minimalThreshold
            level = minimalThreshold;
        end
         disp(['level: ',num2str(level)]);
        
        %create a B&W using the calculated level
        BW = imbinarize(processedImage,'adaptive','Sensitivity',threshodlCorrectionFactor);
%         BW = im2bw(processedImage,level*threshodlCorrectionFactor);
 %figure, imshow(BW)
    case 'localOtsuThresholding'
       
        blockSize =  nucleiParams.blockSize;
        BW = thresholdLocally(processedImage,blockSize,'FudgeFactor',nucleiParams.thresholdCorrectionFactor);
    otherwise
        error('No valid method selected');
        %throw an error
end

numOfNuclei = countcells(BW,nucleiParams.minCellArea,nucleiParams.maxCellArea);
end

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