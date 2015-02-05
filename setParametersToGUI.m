function setParametersToGUI(parameters,handles)
%%%%%%%%%%%%%%%%%%%%%%%% PARAMETER AND ERROR HANDLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% PARAMETER AND ERROR HANDLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%General parameters assignment start
%flags

set(handles.stitchFlag,'Value',parameters.general.stitchFlag);
set(handles.maskFlag,'Value',parameters.general.maskFlag);
set(handles.nucleiFlag,'Value',parameters.general.nucleiFlag);
set(handles.virusFlag,'Value',parameters.general.virusFlag);




%Input/Output parameters
set(handles.processingFolderEdit,'String',parameters.general.processingFolder);
set(handles.fileNamePatternEdit,'String',parameters.general.fileNamePattern);
set(handles.plateNameEdit,'String',parameters.general.plateName);
set(handles.resultOutputFolderEdit,'String',parameters.general.resultOutputFolder);

%%%General parameters assignment end


%STITCH
if ( parameters.general.stitchFlag)
    
    set(handles.stitchFileNamePatternEdit,'String',parameters.stitch.fileNamePattern); 
    set(handles.stitchInputFolderEdit,'String',parameters.stitch.inputFolder);
    set(handles.xImageNumberEdit,'String',parameters.stitch.xImageNumber);
    set(handles.yImageNumberEdit,'String',parameters.stitch.yImageNumber);
end



%MASK
if (parameters.general.maskFlag)
    
    
%     set(handles.maskChannelPopup,'String',parameters.mask.selectedChannel);
    
    switch get(handles.maskMethodPopup,'Value')
        
        case 'loadCustomMask'
            
             set(handles.customMaskFileEdit,'String',parameters.mask.customMaskFile);
        case 'manualMaskDefinition'
%             parameters.mask.selectedMaskDefinitionMethod = 'manualMaskDefinition';
%             parameters.mask.customMaskFile = get(handles.customMaskFileEdit,'String');
        case 'automaticMaskDefinition';
%             parameters.mask.selectedMaskDefinitionMethod = 'automaticMaskDefinition';
            %%%%%ADD MASK DETECTED MASK FILE  PATH IF NOT THROW AN ERROR
    
    end
    
end

if (parameters.general.nucleiFlag)
    %NUCLEI
    set(handles.artifactThresholdEdit,'String',parameters.nuclei.artifactThreshold);
    
%     set(handles.nucleiChannelPopup,'String',parameters.nuclei.selectedChannel);
        
    
    switch parameters.nuclei.selectedThresholdingMethod 
                  
        case 'manualThresholding'
           set(handles.manualThresholdEdit,'String',parameters.nuclei.manualThreshold);
        case 'globalOtsuThresholding'
           
            set(handles.minimalThresholdEdit,'String',parameters.nuclei.minimalThreshold);
            set(handles.thresholdCorrectionFactorEdit,'String',parameters.nuclei.thresholdCorrectionFactor);
        case 'localOtsuThresholding'
            
            set(handles.blockSizeEdit,'String',parameters.nuclei.blockSize);
            
        otherwise
            %throw an error
              %throw an error
         
    end
    
    set(handles.minCellAreaNucleiEdit,'String',parameters.nuclei.minCellArea);
    set(handles.maxCellAreaNucleiEdit,'String',parameters.nuclei.maxCellArea);
    
    if(parameters.nuclei.illuminationCorrectionFlag)
        set(handles.illuminationCorrectionFlag,'Value',parameters.nuclei.illuminationCorrectionFlag);
       
        set(handles.correctionBallRadiusEdit,'String',parameters.nuclei.correctionBallRadius);
    else
         set(handles.illuminationCorrectionFlag,'Value',parameters.nuclei.illuminationCorrectionFlag);
    end
end


if (parameters.general.virusFlag)
    %VIRUS
    
    
%     set(handles.virusChannelPopup,'String',parameters.virus.selectedChannel);
    
    set(handles.virusThresholdEdit,'String',parameters.virus.virusThreshold);
    set(handles.minPlaqueAreaEdit,'String',parameters.virus.minPlaqueArea);
    set(handles.plaqueConnectivityEdit,'String',parameters.virus.plaqueConnectivity);
    
    
    set(handles.minCellAreaVirusEdit,'String',parameters.virus.minCellArea);
   set(handles.maxCellAreaVirusEdit,'String',parameters.virus.maxCellArea);
    
    
    if(parameters.virus.finePlaqueDetectionFlag)
        set(handles.plaqueFineDetectionFlag,'Value',parameters.virus.finePlaqueDetectionFlag);
       set(handles.plaqueGaussianFilterSizeEdit,'String',parameters.virus.plaqueGaussianFilterSize );
        set(handles.plaqueGaussianFilterSigmaEdit,'String',parameters.virus.plaqueGaussianFilterSigma);
        set(handles.peakRegionSizeEdit,'String',parameters.virus.peakRegionSize);
    else
       set(handles.plaqueFineDetectionFlag,'Value', parameters.virus.finePlaqueDetectionFlag);
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
