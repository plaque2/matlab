function [numOfPlaques,plaqueRegionProperties,BW,peakMap,filteredLabeledBW] =  segmentplaque(inputImage,virusParams)


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

% threshold the input image with the specified threshold
BW = im2bw(inputImage,virusThreshold);
numOfPlaques = 0;



if (any(BW(:)))
    
    %Connect nearly conected neighbors
    BW2 = bwdist(BW) <= plaqueConnectivity;
    
    LblMat = labelmatrix(bwconncomp(BW2));
    %Remove ellements from the label matrix which where not present in the
    %original B&W image
    LblMat(~BW) = 0;
    
    
    
    %Calculate various region properties of the image
    imageProps = regionprops(LblMat,'ConvexImage','Image' ,'Centroid','BoundingBox','ConvexArea','Area','MajorAxisLength','MinorAxisLength','Eccentricity');%'EquivDiameter'
    
    
    plaqueRegionProperties = imageProps;
    % get only objects with larger area than minCometArea
    ind = [imageProps.Area] >=minPlaqueArea ;
    
    plaqueRegionProperties = plaqueRegionProperties(ind);
    
    if (length(plaqueRegionProperties)~=0)
        
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
                    %plaque and mask it with the b&w filtered palque region
                    switch class(inputImage)
                        case 'uint8'
                            plaqueImage = inputImage(xRange,yRange).*uint8(plaqueBWImage);
                            
                        case 'uint16'
                            plaqueImage = inputImage(xRange,yRange).*uint16(plaqueBWImage);
                            
                        otherwise
                            error('WrongInputTYpe','input image is not 8 or 16 bit grayscale tif');
                    end
                    
                    
                    %apply the filter to the area filtered Image
                    filteredImage =  uint16(imfilter(single(plaqueImage),filter));
                    %find peaks with specified region size
                    currentRegionPeakMap   = imextendedmax(filteredImage,peakRegionSize);
                    
                    %layout the detected objects on the black and white
                    %filtered Image
                    filteredLabeledBW(xRange,yRange)= filteredLabeledBW(xRange,yRange) + uint16(plaqueBWImage).*iPlaque;
                    
                    peakMap(xRange,yRange) = peakMap(xRange,yRange) + currentRegionPeakMap;
                end
                %label the detected peaks
                labelPeakMaps = bwlabel(peakMap);
                %get the number of detected peaks
                numOfPlaques = max(labelPeakMaps(:));
                
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
                %plaque and mask it with the b&w filtered palque region
                switch class(inputImage)
                    case 'uint8'
                        plaqueImage = inputImage(xRange,yRange).*uint8(plaqueBWImage);
                        
                    case 'uint16'
                        plaqueImage = inputImage(xRange,yRange).*uint16(plaqueBWImage);
                        
                    otherwise
                        error('WrongInputTYpe','input image is not 8 or 16 bit grayscale tif');
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
