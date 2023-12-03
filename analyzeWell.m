function  currentWellData  = analyzeWell(inputImagePath,params,typeOfAnalysis)%parentAxesHandle


switch typeOfAnalysis
    
    case 'stitch'
        
        currentWellData.inputImage = stitchsites(params,inputImagePath);
        currentWellData.outputMessage{1} ='Stitching Successful';
        
    case 'mask'
        
        inputImage = imread(inputImagePath);
        currentWellData.inputImage = inputImage;
        maskingMethod = params.mask.selectedMaskDefinitionMethod;
        
        if ( strcmp(maskingMethod,'loadCustomMask')||strcmp(maskingMethod,'manualMaskDefinition'))
            
            currentWellData.maskOfTheWell = logical(imread(params.mask.customMaskFile));
            
        elseif strcmp(maskingMethod,'automaticMaskDefinition')
            currentWellData.maskOfTheWell = detectMaskAutomatically(inputImage);
        else
            error('Mask:NoMethodSelected' ,'ERROR: No Method Selected');
        end
        currentWellData.outputMessage{1} ='Masking Successful';
        
        
        
    case 'virus'
        %%%%%%%%%%%%%% VIRUS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %get the mask for the current well
        if isfield(params,'mask')
            if isfield(params.mask,'customMaskFile')
                maskOfTheWell =  (imread(params.mask.customMaskFile));
            else
                maskOfTheWell = (detectMaskAutomatically(imread(inputImagePath)));
            end
        else
            %if the mask is not defined
            maskOfTheWell =1;
        end
        inputImage = imread(inputImagePath);
        if(isa(inputImage,'uint16'))
            maskOfTheWell = uint16(maskOfTheWell);
        elseif(isa(inputImage,'uint8'))
            maskOfTheWell = uint8(maskOfTheWell);
        else
            error('WrongInputType','input image is not 8 or 16 bit grayscale tif');
        end
        
        
        inputImage = inputImage.*maskOfTheWell;
        currentWellData.inputImage = inputImage;
        % perform the analysis on the single well
        [numOfPlaques,plaqueProperties,virusBWImage,peakMap,filteredLabeledBW] =  segmentplaque(inputImage,params.virus);
        
        if(any(virusBWImage(:)))
            
            currentWellData.virusBWImage = virusBWImage;
            %get area filtered B&W image of the well
            labeledPerimetersOfPlaqueRegions = filteredLabeledBW;
            
            %connect neighbours using distance transform
            labeledPerimetersOfPlaqueRegions = bwdist(labeledPerimetersOfPlaqueRegions) <=   params.virus.plaqueConnectivity;
            %fill the holes inside objects
            labeledPerimetersOfPlaqueRegions = imfill(labeledPerimetersOfPlaqueRegions,'holes');
            
            
            %get perimeter of the whole objects
            labeledPerimetersOfPlaqueRegions= bwperim(labeledPerimetersOfPlaqueRegions,8);
            %labelthe calculated perimeters
            labeledPerimetersOfPlaqueRegions = bwlabel(labeledPerimetersOfPlaqueRegions);
            %thicken the outlines
            labeledPerimetersOfPlaqueRegions=imdilate(double(labeledPerimetersOfPlaqueRegions),strel('disk',3));
            
            %convert the resulting labeled image to color-coded  RGB image
            currentWellData.labeledPerimetersOfPlaqueRegions = label2rgb(labeledPerimetersOfPlaqueRegions, 'jet', [0 0 0],'shuffle');
            
            
            if(any(peakMap(:)))
                currentWellData.peakMap = peakMap;
            end
            
            %calculate the amount of infected cells in the virus Image
            %without overlayig to the Nuclear Image
            numOfInfectedNuclei = countcells(virusBWImage,params.virus.minCellArea,params.virus.maxCellArea);
            
            currentWellData.outputMessage{1} = ['Number of Infected Nuclei:' num2str(numOfInfectedNuclei)] ;
            currentWellData.outputMessage{2} = ['Number of Plaque Regions:'  num2str(length(plaqueProperties))] ;
            currentWellData.outputMessage{3} = ['Number of Plaques:'  num2str(numOfPlaques)] ;
           
           
        else
             currentWellData.outputMessage{1} = ['Number of Infected Nuclei: 0' ] ;
            currentWellData.outputMessage{2} = ['Number of Plaque Regions: 0' ] ;
            currentWellData.outputMessage{3} = ['Number of Plaques: 0'] ;
           
           
        end
        %%%%%%%%%%%
    case 'nuclei'
        if isfield(params,'mask')
            if isfield(params.mask,'customMaskFile')
                
                maskOfTheWell =  imread(params.mask.customMaskFile);
            else
                maskOfTheWell = (detectMaskAutomatically(imread(inputImagePath)));
            end
            
        else
            %if the mask is not defined
            maskOfTheWell =1;
        end
        
        
        inputImage = imread(inputImagePath);
        
        if(isa(inputImage,'uint16'))
            maskOfTheWell = uint16(maskOfTheWell);
        elseif(isa(inputImage,'uint8'))
            maskOfTheWell = uint8(maskOfTheWell);
        else
            error('WrongInputType','input image is not 8 or 16 bit grayscale tif');
        end
        inputImage = inputImage.*maskOfTheWell;
        
        currentWellData.inputImage = inputImage;
        [numOfNuclei,nucleiBWImage] = segmentnuclei(inputImage,params.nuclei);
        currentWellData.nucleiBWImage = nucleiBWImage;
        currentWellData.outputMessage{1} = (['Number of Nuclei:' num2str(numOfNuclei)]);
        
        
    otherwise
        error('AnalysisTypeNotSpecified','ERROR: Analysis type not specified');
end

%Determine bitDepth of the current Input Image and write it in
%currentWellData structure
if(isa(currentWellData.inputImage,'uint8'))
    currentWellData.bitDepth = 2^8-1;
end

if(isa(currentWellData.inputImage,'uint16'))
    currentWellData.bitDepth = 2^16-1;
end



end


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