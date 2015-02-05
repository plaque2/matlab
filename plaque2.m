function plaque2(varargin)

% CometsAssay('C:\Users\SPIM\Desktop\cometsassay\Sampledata\','C:\Users\SPIM\Desktop\cometsassay\','testPlate')





%Load parameter structure from the first argument
parameters = varargin{1};

callFromGUIFlag=false;

%handles if starting with GUI
if nargin  == 2
    handles = varargin{2};
    callFromGUIFlag = true;
end

%Batch processing
if nargin == 5
    
    
    
    parameters.general.plateName = varargin{2};
    parameters.stitch.inputFolder = varargin{3};
    parameters.general.processingFolder = varargin{4} ;
    parameters.general.resultOutputFolder =  varargin{5};
    
    
    
end


% disp('Starting...');

if(exist('handles'))
    writeinlog(handles.logEdit,'Starting...');
end







%These flags indicate which modules are activated
stitchFlag = parameters.general.stitchFlag;
maskFlag = parameters.general.maskFlag;
nucleiFlag = parameters.general.nucleiFlag;
virusFlag = parameters.general.virusFlag;




%Input/Output parameters  same for all the modules
plateName = parameters.general.plateName;
processingPattern = parameters.general.fileNamePattern;
processingFolder = parameters.general.processingFolder; % indicates the processing ready image folder
resultOutputFolder = parameters.general.resultOutputFolder; % this where all the output files are save xls/csv/mat .. etc.


% if either mask,nuclei,virus modules are active parse the processing
% folder files with given pattern
if(maskFlag||nucleiFlag||virusFlag)
    
    parseOutput = parseImageFilenames(processingFolder,processingPattern);
    
end



%STITCH
if (stitchFlag)
    disp('Stitching in progress...' );
    if(callFromGUIFlag)
        writeinlog(handles.logEdit,'Stitching in progress...')
    end
    
    mkdir(processingFolder);
    h = stitchsites(parameters);
    
    
    if(callFromGUIFlag)
        writeinlog(handles.logEdit,'Stitching successfull');
    end
    
end



%MASK
if (maskFlag)
    
    
    
    
    % determines the well mask if the masking module is enabled
    if (strcmp(parameters.mask.selectedMaskDefinitionMethod,'loadCustomMask'))
        
        maskOfTheWell = (imread(parameters.mask.customMaskFile));
        disp('Mask Loaded');
    elseif (strcmp(parameters.mask.selectedMaskDefinitionMethod,'manualMaskDefinition'))
        maskOfTheWell = (imread(parameters.mask.customMaskFile));
        
    elseif (strcmp(parameters.mask.selectedMaskDefinitionMethod,'automaticMaskDefinition'))
        %set auto mask detection
        maskOfTheWell = 'auto'; % ifuint16(detectMaskAutomatically(imread(fullfile(processingFolder,sortedNucleiImages{1}))));
        %get the list of files to be used to calculate mask for each well
        AllMaskingImages = getFileListForWell(parseOutput.matchedFileNames,processingPattern,parameters.mask.selectedChannel);
    else
        error('No masking method specified');
    end
else
    maskOfTheWell = 1;
end



%NUCLEI
if (nucleiFlag)
    
    %get Nuclei images
    [allNucleiImages allRows allCollumns] = getFileListForWell(parseOutput.matchedFileNames,processingPattern,parameters.nuclei.selectedChannel);
    
    numberOfImages = length(allNucleiImages);
    
end




%VIRUS
if (virusFlag)
    
    
    
    %get Nuclei images
    [allVirusImages allRows allCollumns] = getFileListForWell(parseOutput.matchedFileNames,processingPattern,parameters.virus.selectedChannel);
    
    numberOfImages = length(allVirusImages);
    
    
end


%%%check if number of images in two channels are equal if
%%%not return an error
if(nucleiFlag&&virusFlag)
    if(length(allVirusImages) ~=  length(allNucleiImages))
        error('ImageNumberMismatch','Number of images in plaque and nuclei channels are not equal');
    end
end
%%%%%%%



% Main analysis loop

if(nucleiFlag|| virusFlag)
    
    if(virusFlag)
        %Initiate a counter for total number of plaques
        totalNumberOfPlaquesDetected = 0;
    end
    
    
    for currentImageIndex = 1:numberOfImages
        
        
        
        
        
        disp(strcat('Plate:',plateName,' well : ',num2str(currentImageIndex)));
        
        if(nucleiFlag)
            
            %Check if aborted by user from GUI
            if isappdata(0,'isAnalysisRunning')
                drawnow;
                if (getappdata(0,'isAnalysisRunning')==0)
                    error('STITCH:AbortedByUser','Aborted by User');
                end
            end
            
            
            if(callFromGUIFlag)
                writeinlog(handles.logEdit,strcat('Plate:',plateName,' nuclei : ',num2str(currentImageIndex)));
            end
            
            
            
            
            %Write current image name to Image Data structure
            ImageDataArray(currentImageIndex).NucleiImageName = allNucleiImages{currentImageIndex};
            
            %Write current well ID to Image Data structure
            ImageDataArray(currentImageIndex).wellRow  = allRows{currentImageIndex};
            ImageDataArray(currentImageIndex).wellCollumn  = allCollumns{currentImageIndex};
            
            
            %Load the Image
            currentNucleiImagePath =fullfile(processingFolder,allNucleiImages{currentImageIndex});
            currentNucleiImage = imread(currentNucleiImagePath);
            
            
            %Mask the image with the provided mask
            if(maskFlag)
            if strcmp(maskOfTheWell,'auto')
                maskOfTheWell = imread(fullfile(processingFolder,AllMaskingImages{currentImageIndex}));
                maskOfTheWell = detectMaskAutomatically(maskOfTheWell);
            end
            
            if(isa(currentNucleiImage,'uint16'))
                maskOfTheWell = uint16(maskOfTheWell);
            elseif(isa(currentNucleiImage,'uint8'))
                maskOfTheWell = uint8(maskOfTheWell);
            else
                error('WrongInputType','input image is not 8 or 16 bit grayscale tif');
            end
            end
            currentNucleiImage =  currentNucleiImage.*maskOfTheWell;
            
            % calculate max,total and mean intensities
            ImageDataArray(currentImageIndex).maxNucleiIntensity = max(currentNucleiImage(:));
            ImageDataArray(currentImageIndex).totalNucleiIntensity = sum(currentNucleiImage(:));
            ImageDataArray(currentImageIndex).meanNucleiIntensity = mean(currentNucleiImage(:));
            
            %Nuclei, the segmentation error and B&W threshholded image
            [numberOfNuclei,nucleiBWImage] = segmentnuclei(currentNucleiImage,parameters.nuclei);
            
            
            %Write the segmentation results in Image Data Array
            ImageDataArray(currentImageIndex).numberOfNuclei = numberOfNuclei;
            
            
        end
        
        if(virusFlag)
            
            %Check if aborted by user from GUI
            if isappdata(0,'isAnalysisRunning')
                drawnow;
                if (getappdata(0,'isAnalysisRunning')==0)
                    error('STITCH:AbortedByUser','Aborted by User');
                end
            end
            
            
            if(callFromGUIFlag)
                writeinlog(handles.logEdit,strcat('Plate:',plateName,' virus : ',num2str(currentImageIndex)));
            end
            
            
            
            
            %Write current image name to Image Data structure
            ImageDataArray(currentImageIndex).VirusImageName = allVirusImages{currentImageIndex};
            
            %Write current well ID to Image Data structure
            ImageDataArray(currentImageIndex).wellRow  =  allRows{currentImageIndex};
            ImageDataArray(currentImageIndex).wellCollumn  = allCollumns{currentImageIndex};
            
            
            %Load the Image
            currentVirusImagePath =fullfile(processingFolder,allVirusImages{currentImageIndex});
            currentVirusImage = imread(currentVirusImagePath);
            
            
            %Mask the image with the provided mask
            if(maskFlag)
            if strcmp(maskOfTheWell,'auto')
                maskOfTheWell = imread(fullfile(processingFolder,AllMaskingImages{currentImageIndex}));
                maskOfTheWell = detectMaskAutomatically(maskOfTheWell);
            end
            
            if(isa(currentVirusImage,'uint16'))
                maskOfTheWell = uint16(maskOfTheWell);
            elseif(isa(currentVirusImage,'uint8'))
                maskOfTheWell = uint8(maskOfTheWell);
            else
                error('WrongInputType','input image is not 8 or 16 bit grayscale tif');
            end
            end
            currentVirusImage =  currentVirusImage.*maskOfTheWell;
            
            ImageDataArray(currentImageIndex).maxVirusIntensity = max(currentVirusImage(:));
            ImageDataArray(currentImageIndex).totalVirusIntensity = sum(currentVirusImage(:));
            ImageDataArray(currentImageIndex).meanVirusIntensity = mean(currentVirusImage(:));
            
            [numberOfPlaques,plaqueProperties,virusBWImage,peakCoordinates,filteredLabeledBW] =  segmentplaque(currentVirusImage,parameters.virus);
            
            
            
            ImageDataArray(currentImageIndex).numberOfPlaques = numberOfPlaques;
            
            
            % find number of infected cell if the nuclear channel is
            % enabled
            if(nucleiFlag)
                
                
                
                
                maskedBW = nucleiBWImage.*virusBWImage;
                
                [numberOfInfectedNuclei] = countcells(maskedBW,parameters.nuclei.minCellArea,parameters.nuclei.maxCellArea);
                ImageDataArray(currentImageIndex).numberOfInfectedNuclei = numberOfInfectedNuclei;
            else
                %No Nuclei signal case
                [numberOfInfectedNuclei] = countcells(virusBWImage,parameters.virus.minCellArea,parameters.virus.maxCellArea);
                ImageDataArray(currentImageIndex).numberOfInfectedNuclei = numberOfInfectedNuclei;
            end
            
            if(~isempty(plaqueProperties))
                %
                
                
                %Loop  Through all the detected Objectss
                for iPlaque=1:length(plaqueProperties)
                    
                    
                    %Check if aborted by user from GUI
                    if isappdata(0,'isAnalysisRunning')
                        drawnow;
                        if (getappdata(0,'isAnalysisRunning')==0)
                            error('STITCH:AbortedByUser','Aborted by User');
                        end
                    end
                    
                    totalNumberOfPlaquesDetected = totalNumberOfPlaquesDetected+1;
                    
                    %Initiliaze a blank image with same size as the current Plaque image
                    resizedPlaqueImage=zeros(size(currentVirusImage));
                    
                    %Get the bounding box and convex image of the object
                    plaqueBoundingBox = plaqueProperties(iPlaque).BoundingBox;
                    plaqueBoundingBox = uint16(plaqueBoundingBox);
                    plaqueImage = currentVirusImage(plaqueBoundingBox(2):plaqueBoundingBox(2)+plaqueBoundingBox(4)-1,plaqueBoundingBox(1):plaqueBoundingBox(1)+plaqueBoundingBox(3)-1);
                    plaqueBWImage = plaqueProperties(iPlaque).Image;
                    plaqueProperties(iPlaque).BWImage = plaqueBWImage;
                    plaqueProperties(iPlaque).Image = plaqueImage;
                    plaqueConvexImage = plaqueProperties(iPlaque).ConvexImage;
                    
                    
                    if(nucleiFlag)
                        
                        
                        
                        
                        % create a mask containing only the convex region under the
                        % object
                        resizedPlaqueImage(plaqueBoundingBox(2):plaqueBoundingBox(2)+plaqueBoundingBox(4)-1,plaqueBoundingBox(1):plaqueBoundingBox(1)+plaqueBoundingBox(3)-1)= plaqueConvexImage;
                        resizedPlaqueImage = logical(resizedPlaqueImage);
                        
                        
                        
                        %apply the mask to the Monolayer and Plaque B&W
                        %images
                        maskedMonolayerBWImage  = nucleiBWImage.*resizedPlaqueImage;
                        maskedPlaqueBWImage = virusBWImage.*resizedPlaqueImage;
                        %
                        %
                        %Calculate number of nuclei and segmentation error in the object region
                        [numOfNuclei] = countcells(maskedMonolayerBWImage,parameters.nuclei.minCellArea,parameters.nuclei.maxCellArea);
                        [numOfInfectedNuclei] = countcells(maskedPlaqueBWImage.*maskedMonolayerBWImage,parameters.nuclei.minCellArea,parameters.nuclei.maxCellArea);
                        
                        
                        
                        %write the resulting nuclei values in the current
                        %well plaque properties
                        plaqueProperties(iPlaque).numberOfNucleiInPlaque = numOfNuclei;
                        plaqueProperties(iPlaque).numberOfInfectedNucleiInPlaque = numOfInfectedNuclei;
                        
                    else
                        
                        
                        %No Nuclei signal case
                        
                        resizedPlaqueImage(plaqueBoundingBox(2):plaqueBoundingBox(2)+plaqueBoundingBox(4)-1,plaqueBoundingBox(1):plaqueBoundingBox(1)+plaqueBoundingBox(3)-1)= plaqueConvexImage;
                        resizedPlaqueImage = logical(resizedPlaqueImage);
                        maskedPlaqueBWImage = virusBWImage.*resizedPlaqueImage;
                        %Calculate number of nuclei in the object region
                        [numOfNuclei] = countcells(maskedPlaqueBWImage,parameters.virus.minCellArea,parameters.virus.maxCellArea);
                        %Write the well ID and number of nuclei in the Object to gfpImageProps structure
                        plaqueProperties(iPlaque).numberOfNucleiInPlaque = numOfNuclei;
                        
                    end
                    
                    
                    plaqueProperties(iPlaque).wellRow =   allRows{currentImageIndex};
                    plaqueProperties(iPlaque).wellCollumn =   allCollumns{currentImageIndex};
                    
                    
                    
                    %%%%ENTHROPY
%                     plaqueProperties(iPlaque).shannonEnthropy  = wentropy(plaqueImage,'shannon');
%                     plaqueProperties(iPlaque).logEnergyEnthropy  = wentropy(plaqueImage,'log energy');
%                     
                    %Calculate Max, Total and Mean Intensities of the region under the object and write them
                    %to gfpImageProps structure
                    plaqueProperties(iPlaque).maxIntensityGFP = max(plaqueImage(:));
                    plaqueProperties(iPlaque).totalIntensityGFP = sum(plaqueImage(:));
                    
                    %             nonZeroElem = maskedDAPIImage(maskedDAPIImage>0);
                    plaqueProperties(iPlaque).meanIntensity = mean(plaqueImage(:));
                    
                    %Write Comet properties structure to Object Data Structure
                    ObjectDataArray(totalNumberOfPlaquesDetected)= plaqueProperties(iPlaque);
                    
                    
                    
                    iPlaque=iPlaque+1;
                    %
                    %
                end
            end
            %                 %
            
            
            
            
            
            
            
            
            
        end
        %
        
        
    end
    
    disp('Analysis Complete');
    if(callFromGUIFlag)
        writeinlog(handles.logEdit,'Analysis completed successfully');
        writeinlog(handles.logEdit,'Saving Results...');
    end
    mkdir(resultOutputFolder);
    %Save Image data structure and Object data structure  to xls files
    
    
    % cell2mat(plt)
    
    
    ImageData = struct2dataset(ImageDataArray(:));
    
    
    writetable(dataset2table(ImageData),fullfile(resultOutputFolder,[plateName '_ImageData.csv']));
    if(exist('ObjectDataArray') == 1)
        
        %remove unnecessary fields from ObjectDataArray
        ObjectDataArray = rmfield(ObjectDataArray,'Image');
        ObjectDataArray = rmfield(ObjectDataArray,'BWImage');
        ObjectDataArray = rmfield(ObjectDataArray,'ConvexImage');
        ObjectData = struct2dataset(ObjectDataArray(:));
        %     export(ObjectData,'XLSFile',fullfile(resultOutputPath,[plateName '_ObjectData.xlsx']));
        %    export(ObjectData,'File',fullfile(resultOutputFolder,[plateName '_ObjectData.csv']),'Delimiter',',');
        writetable(dataset2table(ObjectData),fullfile(resultOutputFolder,[plateName '_ObjectData.csv']));
        save(fullfile(resultOutputFolder,plateName),'ImageDataArray','ObjectDataArray');
    else
        save(fullfile(resultOutputFolder,plateName),'ImageDataArray');
    end
    if(callFromGUIFlag)
        writeinlog(handles.logEdit,'Saving Successful');
        writeinlog(handles.logEdit,'Finished');
        setappdata(0,'isAnalysisRunning',0);
        drawnow;
    end
    display('Finished');
    
    % toc
    
    %
    
    
    
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

