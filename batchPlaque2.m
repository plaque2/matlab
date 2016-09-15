clc
clear

% % CHANGE THE INPUT FOLDER HERE
% output = evalc('system(''dir Z:\Vardan_Andriasyan\Novartis\Wuxi3b /ad /b /s'')');
output = evalc('system(''dir Y:\ /ad /b /s'')');
%  output = evalc('system(''dir D:\Novartis\run2_4dpi /ad /b /s'')');
%  output = evalc('system(''dir D:\Novartis\run4_4dpi /ad /b /s'')');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  output = evalc('system(''dir D:\Novartis\run3_4dpi /ad /b /s'')');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


allDirs =regexp(output,' ','split');

% [ind] = regexp(allDirs,'\\[0-9]+-[0-9]+-[0-9]+\\[0-9]+$');
[ind] = regexp(allDirs,'\\TimePoint_\d++$');
%D:\AY\Images1\121110-LMBCheckerboard1-1dpi\121110-LMBCheckerboard1-1dpi\2012-11-10\49
%
ind = find(~cellfun(@isempty,ind));

filteredDirs = allDirs(ind);

% filteredDirs{1}

   load('stitchingParams.mat');
 %load('Z:\Vardan_Andriasyan\Novartis\Wuxi3b\Results\16_02_02_parameters.mat');
parameters.general.fileNamePattern = '(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*)';

% SPECIFY THE OUTPUT FOR THE EXCELL FILES HERE
%C:\Users\Vardan\Google Drive\!AY&VA\Novartis\results\run1_4dpi
resultOutputPath='Y:\Analysis\160613-Ackermann-titration\Results';
% %   resultOutputPath='C:\Users\Vardan\Google Drive\!AY&VA\Novartis\results\run2_4dpi';
mkdir(resultOutputPath);
overviewSavePath = 'Y:\Analysis\160613-Ackermann-titration\Overviews';
%  overviewSavePath = 'C:\Users\Vardan\Google Drive\!AY&VA\Novartis\overviews\run2';
mkdir(overviewSavePath);
% overviewFolder='D:\Vardan\131108drugscreen\Overviews';
% mkdir(overviewFolder)

%   [numOfPlaques,plaqueProperties,virBW,peakCoordinates] =  segmen0tplaque(imagePathVirus,minCometArea,thresholdVirusSignal,conDist,enableFineDetection,gaussSize,gaussSigma,peakThresholdFactor);

%%%%% INPUT IMAGES %%%%%%%%%


numberOfPlates =0;

parfor i=1:length(filteredDirs)
    % for i=1:length(filteredDirs)
    curPath  = strtrim(filteredDirs{i});
    %   disp(curPath);
    %ADV
    % % ind = regexp(curPath,'[0-9]*-Novartis-\w*-[0-9]-[0-9]dpi_\w*_[0-9]*','match');
    % 140925-Novartis-Batch2-Run2-1-1-4dpi_Plate_1107
    % ind = regexp(curPath,'[0-9]*-Novartis-p[0-9]_Plate_[0-9]*','match');
    % 141215-NovRun3-p1-4dpi_Plate_1257
    % 140214-Novartis-plate1-1-1dpi_Plate_423
    %RUN1 151014-Ackerman-20x-batch1-p3_Plate_1805
    %ind = regexp(curPath,'[0-9]*-VA-Wuxi3b-\w*-plq-3dpi_Plate_[0-9]*','match');
    ind = regexp(curPath,'160613-Ackermann-titration-\w*-\w*-[0-9]*hpi_Plate_[0-9]*','match');
    ind = regexp(curPath,'160613-Ackermann-titration-dTK-GCV-48hpi_Plate_[0-9]*','match');
%      ind = regexp(curPath,'160613-Ackermann-titration-dTK-GCV-24hpi_Plate_2761','match');
    %RUN2
    % 140925-Novartis-Batch2-Run2-1-1-4dpi_Plate_1107
    % ind = regexp(curPath,'[0-9]*-Novartis-Batch2-Run2-[0-9]-[0-9]-4dpi_\w*_[0-9]*','match');
    
    % ind = regexp(curPath,'[0-9]*-NovRun3-p[0-9]-4dpi_Plate_[0-9]*','match');
    % ind = regexp(curPath,'[0-9]*-NovRun3-p[0-9]-4dpi_Plate_[0-9]*','match');
    % VACV
    %1400202-VACV-ara-C-H-p1_Plate_377
    
    %%%%%%%%%%%% CHANGE THE REGEXP FOR THE PLATE NAMES
    % 140809-PMP-FreezeThawInfectEtOh-1dpi_Plate_979
    % 140813-FreezeThaw-GCA-p1-1dpi_Plate_1004
    %140911-HKF-on-WI38-1hps-reseeding-p1_Plate_1074
    %140925-Novartis-Batch2-Run2-1-1-4dpi_Plate_1107
    %141001-HAdV3-CellLibraryInfection-1-1dpi_Plate_1126
    %14-09-30-Demonstration-Plate-4X-2_Plate_1120
    %14-10-03-Demonstration-PlateReimage-1-4X_Plate_1141
    %D:\Vardan\BIO321\14-10-03-CellLibrary-fixed4X-1-4dpi_Plate_1147
    %  ind = regexp(curPath,'[0-9]*-[0-9]*-[0-9]*-CellLibrary-fixed4X-[0-9]-[0-9]dpi_Plate_[0-9]*','match');
    %141002-HAdV3-CellLibrary-1-2dpi_Plate_1132
    %130216-AY-JM-VACV-spread-TC-4x_Plate_10
    %  ind = regexp(curPath,'130216-AY-JM-VACV-spread-TC-4x_Plate_10','match');
    % if ~isempty(ind)
    % numberOfPlates=numberOfPlates+1;
    % % disp(ind);
    % end
    if  ~isempty(ind)
        numberOfPlates=numberOfPlates+1;
        curPlatename = cell2mat(unique(ind));
        % curPlatename = ['T' num2str(i)];
        disp(curPlatename)
%         plaque2(parameters,curPlatename, curPath,[curPath filesep 'Stitched'],resultOutputPath);
        
        scalingFactor=0.1;
        removeStitchFolderFlag =0;
        pattern = '.*(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
        generateOverviews([curPath filesep 'Stitched'],curPlatename,pattern,overviewSavePath,scalingFactor,removeStitchFolderFlag);
        
    end
    
    
end


% %

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

