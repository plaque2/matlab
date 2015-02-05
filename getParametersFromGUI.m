function parameters = getParametersFromGUI(handles,type)
%%%%%%%%%%%%%%%%%%%%%%%% PARAMETER AND ERROR HANDLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%General parameters assignment start
%flags

parameters.general.stitchFlag = get(handles.stitchFlag,'Value');
parameters.general.maskFlag = get(handles.maskFlag,'Value');
parameters.general.nucleiFlag = get(handles.nucleiFlag,'Value');
parameters.general.virusFlag = get(handles.virusFlag,'Value');




%Input/Output parameters

%get the input Plate name and remove spaces from it
plateName = (get(handles.plateNameEdit,'String'));
plateName(isspace(plateName)) = [];


parameters.general.processingFolder = get(handles.processingFolderEdit,'String');
parameters.general.fileNamePattern = get(handles.fileNamePatternEdit,'String');
parameters.general.plateName = plateName;
parameters.general.resultOutputFolder = get(handles.resultOutputFolderEdit,'String');

%%%General parameters assignment end


%STITCH
if ( (strcmp(type,'ALL') && parameters.general.stitchFlag) || strcmp(type,'STITCH'))
    
    parameters.stitch.fileNamePattern = (get(handles.stitchFileNamePatternEdit,'String'));
    parameters.stitch.inputFolder = (get(handles.stitchInputFolderEdit,'String'));
    parameters.stitch.xImageNumber = str2num(get(handles.xImageNumberEdit,'String'));
    parameters.stitch.yImageNumber = str2num(get(handles.yImageNumberEdit,'String'));
end



%MASK
if ((strcmp(type,'ALL') && parameters.general.maskFlag)|| strcmp(type,'MASK'))
    
    listOfChannels = get(handles.maskChannelPopup,'String');
    if(length(listOfChannels)~=1)
        parameters.mask.selectedChannel = listOfChannels{get(handles.maskChannelPopup,'Value')};
    else
        parameters.mask.selectedChannel = listOfChannels;
    end
    switch get(handles.maskMethodPopup,'Value')
        
        case 2
            parameters.mask.selectedMaskDefinitionMethod = 'loadCustomMask';
            parameters.mask.customMaskFile = get(handles.customMaskFileEdit,'String');
        case 3
            parameters.mask.selectedMaskDefinitionMethod = 'manualMaskDefinition';
            parameters.mask.customMaskFile = get(handles.customMaskFileEdit,'String');
        case 4
            parameters.mask.selectedMaskDefinitionMethod = 'automaticMaskDefinition';
            %%%%%ADD MASK DETECTED MASK FILE  PATH IF NOT THROW AN ERROR
        otherwise
            %throw an error
            h = errordlg('No Masking method selected');
            error('Mask:NoMethod','No Masking method selected');
            
    end
    
end

if ((strcmp(type,'ALL') && parameters.general.nucleiFlag)|| strcmp(type,'NUCLEI'))
    %NUCLEI
    parameters.nuclei.artifactThreshold = str2num(get(handles.artifactThresholdEdit,'String'));
    
    listOfChannels = get(handles.nucleiChannelPopup,'String');
    
    if(length(listOfChannels)~=1)
        parameters.nuclei.selectedChannel  = listOfChannels{get(handles.nucleiChannelPopup,'Value')};
    else
        parameters.nuclei.selectedChannel  = listOfChannels;
    end
        
    
    switch get(handles.nucleiThresholdingPopup,'Value')
        case 1
            %throw an error
            h = errordlg('No thresholding method selected');
            error('Nuclei:NoMethod','No thresholding method selected');
            
        case 2
            parameters.nuclei.selectedThresholdingMethod = 'manualThresholding';
            parameters.nuclei.manualThreshold = str2num(get(handles.manualThresholdEdit,'String'));
        case 3
            parameters.nuclei.selectedThresholdingMethod = 'globalOtsuThresholding';
            parameters.nuclei.minimalThreshold = str2num(get(handles.minimalThresholdEdit,'String'));
            parameters.nuclei.thresholdCorrectionFactor = str2num(get(handles.thresholdCorrectionFactorEdit,'String'));
        case 4
            parameters.nuclei.selectedThresholdingMethod = 'localOtsuThresholding';
            parameters.nuclei.blockSize = str2num(get(handles.blockSizeEdit,'String'));
            
        otherwise
            %throw an error
    end
    
    parameters.nuclei.minCellArea = str2num(get(handles.minCellAreaNucleiEdit,'String'));
    parameters.nuclei.maxCellArea = str2num(get(handles.maxCellAreaNucleiEdit,'String'));
    
    if(get(handles.illuminationCorrectionFlag,'Value'))
        parameters.nuclei.illuminationCorrectionFlag = get(handles.illuminationCorrectionFlag,'Value');
        parameters.nuclei.correctionBallRadius = str2num(get(handles.correctionBallRadiusEdit,'String'));
    else
        parameters.nuclei.illuminationCorrectionFlag = 0;
    end
end


if ((strcmp(type,'ALL') && parameters.general.virusFlag) || strcmp(type,'VIRUS'))
    %VIRUS
    
    listOfChannels = get(handles.virusChannelPopup,'String');
    
    if(length(listOfChannels)~=1)
        parameters.virus.selectedChannel   = listOfChannels{get(handles.virusChannelPopup,'Value')};
    else
        parameters.virus.selectedChannel   = listOfChannels;
    end
    
    parameters.virus.virusThreshold = str2num(get(handles.virusThresholdEdit,'String'));
    parameters.virus.minPlaqueArea = str2num(get(handles.minPlaqueAreaEdit,'String'));
    parameters.virus.plaqueConnectivity = str2num((get(handles.plaqueConnectivityEdit,'String')));
    
    
    parameters.virus.minCellArea = str2num(get(handles.minCellAreaVirusEdit,'String'));
    parameters.virus.maxCellArea = str2num(get(handles.maxCellAreaVirusEdit,'String'));
    
    
    if(get(handles.plaqueFineDetectionFlag,'Value'))
        parameters.virus.finePlaqueDetectionFlag = get(handles.plaqueFineDetectionFlag,'Value');
        parameters.virus.plaqueGaussianFilterSize =  str2num(get(handles.plaqueGaussianFilterSizeEdit,'String'));
        parameters.virus.plaqueGaussianFilterSigma = str2num(get(handles.plaqueGaussianFilterSigmaEdit,'String'));
        parameters.virus.peakRegionSize = str2num(get(handles.peakRegionSizeEdit,'String'));
    else
        parameters.virus.finePlaqueDetectionFlag = get(handles.plaqueFineDetectionFlag,'Value');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
