clc
clear

% % CHANGE THE INPUT FOLDER HERE
% output = evalc('system(''dir Z:\Vardan_Andriasyan\Novartis\Wuxi3b /ad /b /s'')');
output = evalc('system(''dir Z:\Vardan_Andriasyan\Clusters\TimeCourse_pV\170206-VA-PV-timelapse /ad /b /s'')');
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
 %[A-Z][0-9]*)
parameters.general.fileNamePattern = '(?<wellName>[BCDEFG][0][78])_(?<channelName>w[0-9]*)';
parameters.stitch.fileNamePattern = '(?<wellName>[BCDEFG][0][78])_(?<siteName>s[0-9]*)_(?<channelName>w[0-9]*)_thumb.tif';
parameters.stitch.yImageNumber = 8;
parameters.stitch.xImageNumber = 8;

% SPECIFY THE OUTPUT FOR THE EXCELL FILES HERE
%C:\Users\Vardan\Google Drive\!AY&VA\Novartis\results\run1_4dpi
resultOutputPath='Z:\Vardan_Andriasyan\Clusters\TimeCourse_pV\170206-VA-PV-timelapse\Results';
% %   resultOutputPath='C:\Users\Vardan\Google Drive\!AY&VA\Novartis\results\run2_4dpi';
mkdir(resultOutputPath);
overviewSavePath = 'Z:\Vardan_Andriasyan\Clusters\TimeCourse_pV\170206-VA-PV-timelapse\Overviews';
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
   
    
%      if  ~isempty(ind)
%          numberOfPlates=numberOfPlates+1;
%          curPlatename = cell2mat(unique(ind));
         curPlatename = ['T' num2str(i)];
%          curPlatename='pV';
         disp(curPlatename)
         plaque2(parameters,curPlatename, curPath,[curPath filesep 'Stitched'],resultOutputPath);
        
          scalingFactor=1;
          removeStitchFolderFlag =0;
          pattern = '.*(?<wellName>[BCDEFG][0][78])_(?<channelName>w[0-9]*).TIF';
        generateOverviews([curPath filesep 'Stitched'],curPlatename,pattern,overviewSavePath,scalingFactor,removeStitchFolderFlag);
        
%      end
    
    
end


% % n 

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

