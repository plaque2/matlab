function [numOfPlaques,plaqueRegionProperties,BW,peakMap,filteredLabeledBW] =  segmentplaque(inputImage,virusParams)



function roundness = calculateRoundness(bwImage)
    
    props = regionprops(bwImage,'Area','Perimeter')

    area = props.Area
    perimeter = props.Perimeter
     
    roundness =  (4 * pi * area)./(perimeter .^ 2);
    
end


%ToDo code needs refactoring and better commenting
minPlaqueArea = virusParams.minPlaqueArea;
virusThreshold =virusParams.virusThreshold;
plaqueConnectivity = virusParams.plaqueConnectivity;

enableFineDetection = virusParams.finePlaqueDetectionFlag;
if(enableFineDetection)
    gaussSize = virusParams.plaqueGaussianFilterSize;
    gaussSigma = virusParams.plaqueGaussianFilterSigma;
    peakRegionSize = virusParams.peakRegionSize ;
end
%%%%%%%%%%%%%%%%%%%%%%%%CHANGES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% threshold the input image with the specified threshold

%     se = strel('ball',5,5);
 % bcg = imopen((inputImage),strel('disk',80)); 
%  bcg = imread('bcg.tif');
% inputImage = imgaussfilt(inputImage,10)-bcg;%(inputImage-bcg);
% imshow(imgaussfilt(inputImage,50)-bcg,[]);
%  inputImage = adapthisteq(im2uint8(inputImage),'Distribution','rayleigh','Alpha',0.8);


%%%%%%%%%%%%%%%%%%%%%%%%%ROLLING BALL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% correctionBallRadius = 30; 
% bcg = imopen((inputImage),strel('ball',correctionBallRadius,correctionBallRadius));
% inputImage = inputImage - bcg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


BW = im2bw(inputImage,virusThreshold);
%mask = imread('Y:\Analysis\160329-Nelli-plates-1-3\16_05_23_mask_p2.tif');
%  BW = (imbinarize((inputImage),'adaptive','Sensitivity',virusThreshold,'ForegroundPolarity','dark'));
%BW(~mask)=0;
numOfPlaques = 0;

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (any(BW(:)))
    
    %Connect nearly conected neighbors
    BW2 = bwdist(BW) <= plaqueConnectivity;
    
    LblMat = labelmatrix(bwconncomp(BW2));
    %Remove ellements from the label matrix which where not present in the
    %original B&W image
    LblMat(~BW) = 0;
    
    
    
    %Calculate various region properties of the image
    imageProps = regionprops(LblMat,'ConvexImage','Image' ,'Centroid','BoundingBox','ConvexArea','Area','MajorAxisLength','MinorAxisLength','Eccentricity');
%     imageProps = regionprops(LblMat,'all');%
    %%%%%%%%%%%%%%%%%%%%%%%%CHANGES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plaqueRegionProperties = imageProps;
    % get only objects with larger area than minCometArea
    ind = [imageProps.Area] >=minPlaqueArea ;
    
    maxPlaqueArea = 6*10^7;
   
    plaqueRegionProperties = plaqueRegionProperties(ind);
    
    ind = [plaqueRegionProperties.Area] <= maxPlaqueArea ;
    
    plaqueRegionProperties = plaqueRegionProperties(ind);
    
    
    % compute the roundness metric
       
    roundness = num2cell(cellfun(@calculateRoundness,{plaqueRegionProperties.ConvexImage}));
    [plaqueRegionProperties.Roundness]  = roundness{:};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (length(plaqueRegionProperties)~=0)
        
        
        numberOfPeaks = num2cell(ones(1,length(plaqueRegionProperties)));
        [plaqueRegionProperties.numberOfPeaks]  = numberOfPeaks{:};
        
        % % FINE DETECTION
        if (enableFineDetection)
            
            
            
            %Initialize the blurring  gaussian filter for  the image
            filter =  fspecial('gaussian', gaussSize,gaussSigma);
            
            
            %if the  area of the plaque is more than 3/4 of the convex area
            %then then consider plaque segmentation not possible and return the
            %center of the plaque as peakMap
            
            plaqueDetectionLimitCoefficient = 1; % hardcoded parameter
            
            if (length(plaqueRegionProperties) == 1 && plaqueRegionProperties.Area > plaqueDetectionLimitCoefficient *plaqueRegionProperties.ConvexArea)
                numOfPlaques =1;
                peakMap= false(size(inputImage));
                peakMap(round(plaqueRegionProperties.Centroid)) = 1;
                filteredLabeledBW = BW;
            else
                % Generate the area filtered black and white image of the
                % well
                
                %create a dummy with same size as the original thresholded
                %Image
                filteredLabeledBW = uint16(zeros(size(BW)));
                peakMap =  false(size(BW));
                
                
                %TODO: this code probably can be vectorized
                
                %Loop trough detected objects
                for iPlaque=1:length(plaqueRegionProperties)
                    
                    
                    
                   
                    
                    % get the segmented plaque region black and white image
                    % and its boundaries
                    boundariesOfThePlaqueRegion = plaqueRegionProperties(iPlaque).BoundingBox;
                    boundariesOfThePlaqueRegion = uint16(boundariesOfThePlaqueRegion);
                    plaqueBWImage = plaqueRegionProperties(iPlaque).Image;
                    
                    %Calculate the sum of all non-zero pixels in a plaque
                    %region
%                     plaqueRegionProperties(iPlaque).rawArea =  sum(plaqueBWImage(:));
                    
                    % get the coordinates of the plaque
                    xRange = (boundariesOfThePlaqueRegion(2):boundariesOfThePlaqueRegion(2)+boundariesOfThePlaqueRegion(4)-1);
                    yRange = (boundariesOfThePlaqueRegion(1):boundariesOfThePlaqueRegion(1)+boundariesOfThePlaqueRegion(3)-1);
                    
                    
                    %Get the original non-black and white image of the
                    %plaque and mask it with the b&w filtered plaque region
                    switch class(inputImage)
                        case 'uint8'
                            plaqueImage = inputImage(xRange,yRange).*uint8(plaqueBWImage);
                            
                        case 'uint16'
                            plaqueImage = inputImage(xRange,yRange).*uint16(plaqueBWImage);
                            
                        otherwise
                            error('WrongInputType','input image is not 8 or 16 bit grayscale tif');
                    end
                    
                    
                    %apply the filter to the area filtered Image
                    filteredImage =  uint16(imfilter(single(plaqueImage),filter));
                    %find peaks with specified region size
                    currentRegionPeakMap   = imextendedmax(filteredImage,peakRegionSize);
                    
                    labelPeakMaps = bwlabel(currentRegionPeakMap);
                    numberOfPeaks = max(labelPeakMaps(:));
                    plaqueRegionProperties(iPlaque).numberOfPeaks = numberOfPeaks;
                    
                    numOfPlaques = numOfPlaques + numberOfPeaks;
                    %layout the detected objects on the black and white
                    %filtered Image
                    filteredLabeledBW(xRange,yRange)= filteredLabeledBW(xRange,yRange) + uint16(plaqueBWImage).*iPlaque;
                    
                    peakMap(xRange,yRange) = peakMap(xRange,yRange) + currentRegionPeakMap;
                end
                
            end
            
        else
            filteredLabeledBW = uint16(zeros(size(BW)));
            
            for iPlaque=1:length(plaqueRegionProperties)
                
                % get the segmented plaque region black and white image
                % and its boundaries
                boundariesOfThePlaqueRegion = plaqueRegionProperties(iPlaque).BoundingBox;
                boundariesOfThePlaqueRegion = uint16(boundariesOfThePlaqueRegion);
                plaqueBWImage = plaqueRegionProperties(iPlaque).Image;
                
                
                %Calculate the sum of all non-zero pixels in a plaque
                %region
%                 plaqueRegionProperties(iPlaque).rawArea =  sum(plaqueBWImage(:));
                %
                % get the coordinates of the plaque
                xRange = (boundariesOfThePlaqueRegion(2):boundariesOfThePlaqueRegion(2)+boundariesOfThePlaqueRegion(4)-1);
                yRange = (boundariesOfThePlaqueRegion(1):boundariesOfThePlaqueRegion(1)+boundariesOfThePlaqueRegion(3)-1);
                
                %Get the original non-black and white image of the
                %plaque and mask it with the b&w filtered plaque region
                switch class(inputImage)
                    case 'uint8'
                        plaqueImage = inputImage(xRange,yRange).*uint8(plaqueBWImage);
                        
                    case 'uint16'
                        plaqueImage = inputImage(xRange,yRange).*uint16(plaqueBWImage);
                        
                    otherwise
                        error('WrongInputType','input image is not 8 or 16 bit grayscale tif');
                end
                
                %layout the detected objects on the black and white
                %filtered Image
                filteredLabeledBW(xRange,yRange)= filteredLabeledBW(xRange,yRange) + uint16(plaqueBWImage).*iPlaque;
                
            end
            
            
            peakMap =0;
            numOfPlaques = length(plaqueRegionProperties);
        end
        
    else
        numOfPlaques =0;
        plaqueRegionProperties = [];
        peakMap=0;
        filteredLabeledBW=0;
    end
else
    numOfPlaques =0;
    plaqueRegionProperties = [];
    peakMap=0;
    filteredLabeledBW = 0;
end



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