function visualizeWell(varargin)

if nargin < 3
    testWindowHandleArray = varargin{1};
else
    testWindowHandleArray = varargin{3};
end
currentWellData = getappdata(testWindowHandleArray.imageHolder,'currentWellData');
typeOfVisualization = getappdata(testWindowHandleArray.mainHandle,'testType');

if(isfield(currentWellData,'contrastLimits'))
    inputImage =imadjust(currentWellData.inputImage,currentWellData.contrastLimits./currentWellData.bitDepth,[0 1]);
else
    inputImage = imadjust(currentWellData.inputImage);
end


%%% disable contrast button
if(get(testWindowHandleArray.contrastPanel,'visible'))
    set(testWindowHandleArray.contrastPanel,'visible','off');
    set(testWindowHandleArray.contrastToggleButton,'value',0);
end



switch typeOfVisualization
    
    case 'stitch'
        imshow(convert2RGB(inputImage,[1 1 1]),'Parent',testWindowHandleArray.imageHolder);
    case 'mask'
        
        overlayRGB= convert2RGB(inputImage,[1 1 1]);
        if(get(testWindowHandleArray.maskOverlayCheckBox,'Value'))
            maskOverlayRGB = convert2RGB(currentWellData.maskOfTheWell ,[1 0 0]);
            overlayRGB(maskOverlayRGB>0) = maskOverlayRGB(maskOverlayRGB>0);
        end
        imshow(overlayRGB,'Parent',testWindowHandleArray.imageHolder);
    case 'virus'
        
        overlayRGB=convert2RGB(inputImage,[1 1 1]);
        if(get(testWindowHandleArray.thresholdedImageOverlayCheckBox,'Value'))
            virusOverlayRGB = convert2RGB(currentWellData.virusBWImage,[0.01 1 0.01]);
            overlayRGB(virusOverlayRGB>0) = virusOverlayRGB(virusOverlayRGB >0);
            plaquePerimeterOverlayRGB = currentWellData.labeledPerimetersOfPlaqueRegions;
            overlayRGB(plaquePerimeterOverlayRGB>0) = plaquePerimeterOverlayRGB(plaquePerimeterOverlayRGB >0);
        end
        if(isfield(testWindowHandleArray,'localMaximaOverlayCheckBox'))
            if(get(testWindowHandleArray.localMaximaOverlayCheckBox,'Value'))
                localMaximaOverlayRGB = convert2RGB(currentWellData.peakMap,[1 0.01 0.01]);
                overlayRGB(localMaximaOverlayRGB>0) = localMaximaOverlayRGB(localMaximaOverlayRGB>0);
            end
        end
        imshow(overlayRGB,'Parent',testWindowHandleArray.imageHolder);
        
    case 'nuclei'
        
        overlayRGB=convert2RGB(inputImage,[1 1 1]);
        if(get(testWindowHandleArray.thresholdedImageOverlayCheckBox,'Value'))
            nucleiOverlayRGB = convert2RGB(currentWellData.nucleiBWImage,[0.01 0.01 1]);
            overlayRGB(nucleiOverlayRGB>0) = nucleiOverlayRGB(nucleiOverlayRGB >0);
        end
        imshow(overlayRGB,'Parent',testWindowHandleArray.imageHolder);
    otherwise
        error('VisualizationTypeNotSpecified','ERROR: Vizualization type not specified');
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

