function  manualMaskDetection(params,parentMaskEditHandle)
% %Uncomment for testing
% function manualMaskDetection
%
% params.general.processingFolder = 'C:\Users\Vardan\Documents\MATLAB\plaque2.0\src';
% params.general.fileNamePattern = '(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
% params.mask.selectedChannel= 'w1';


manualMaskUIArray.mainHandle = figure('units','pixels',...
    'position',[200 200 410 455],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Manual Masking',...
    'resize','off',...
    'Color',[0.314 0.314 0.314],...
    'BusyAction','cancel',...
    'Interruptible','off');



%%%% Add all the read-only input parameters to the main handle for later
%%%% use
parseOutput =  parseImageFilenames(params.general.processingFolder,params.general.fileNamePattern);
setappdata(manualMaskUIArray.mainHandle,'parseOutput',parseOutput);
setappdata(manualMaskUIArray.mainHandle,'params',params);
setappdata(manualMaskUIArray.mainHandle,'parentMaskEditHandle',parentMaskEditHandle);


manualMaskUIArray.inputImageHolder = axes('units','pixels',...
    'Parent',manualMaskUIArray.mainHandle,...
    'position',[5 25  400 400],...
    'xtick',[],'ytick',[],'box','on','XColor',[0.512 0.512 0.512],'YColor', [0.512 0.512 0.512],'TickDir','in');

title(manualMaskUIArray.inputImageHolder,'Select image for masking','FontName','Arial','FontSize',16,'Color',[1 1 1]);

% %%%%%WELL SELECTION

manualMaskUIArray.wellRowPopup = uicontrol('Style', 'popup',...
    'Parent',manualMaskUIArray.mainHandle,...
    'String',{'N/A'},...
    'units','pixels',...
    'position',[20 45 50 25],...
    'UserData','Row',...
    'fonts',10,...
    'CreateFcn',{@wellRowCollumnCreateFcn,manualMaskUIArray});
if(ismac)
    set(manualMaskUIArray.wellRowPopup,'position',[0 0 65 25]);
else
    set(manualMaskUIArray.wellRowPopup,'position',[5 0 50 25]);%    set(manualMaskUIArray.wellRowPopup,'position',[20 45 50 25]);
end
manualMaskUIArray.wellCollumnPopup = uicontrol('Style', 'popup',...
    'Parent',manualMaskUIArray.mainHandle,...
    'String','N/A',...
    'units','pixels',...
    'position',[70 45 50 25],...
    'UserData','Collumn',...
    'fonts',10,...
    'CreateFcn',{@wellRowCollumnCreateFcn,manualMaskUIArray});
if(ismac)
    set(manualMaskUIArray.wellCollumnPopup,'position',[50 0 65 25]);
else
    set(manualMaskUIArray.wellCollumnPopup,'position',[55 0 50 25]);
end



manualMaskUIArray.autoScaleCheckBox = uicontrol('Style','checkbox',...
    'Parent',manualMaskUIArray.mainHandle,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'Units','pixels','Position',[170 7 150 12],'FontName','Arial','FontSize',8,'FontWeight','bold','String','Auto Scale Images','Value',1);

%%%GO TO WELL BUTTON
manualMaskUIArray.goToWellBtn = uicontrol('Style', 'push',...
    'Parent',manualMaskUIArray.mainHandle,...
    'String','Go to',...
    'units','pixels',...
    'position',[105 0 50 26],...
    'fonts',10,...
    'BackgroundColor',[0.314 0.314 0.314],...
    'ForegroundColor',[1 1 1],...
    'Callback',{@goToImage,manualMaskUIArray});



function wellRowCollumnCreateFcn(handle,event,manualMaskUIArray)
params = getappdata(manualMaskUIArray.mainHandle,'params');

try
            
    
    inputPath =  params.general.processingFolder;
    pattern  = params.general.fileNamePattern;
    channel = params.mask.selectedChannel;
    
    parseOutput = getappdata(manualMaskUIArray.mainHandle,'parseOutput');
    
    if strcmp(get(handle,'UserData'),'Row')
        set(handle,'String',parseOutput.wellRows);
    else
        set(handle,'String',parseOutput.wellCollumns);
    end
    
catch ErrorMessage
    error('NoFilesFound','No files Found matching the specified pattern');
    errordlg('No files Found matching the specified pattern','Parse Error');
    %     errordld('','unable to parse ')
    disp(ErrorMessage);
end



function  goToImage(handle,event,manualMaskUIArray)
params = getappdata(manualMaskUIArray.mainHandle,'params');

        
    pattern  = params.general.fileNamePattern;
    channel = params.mask.selectedChannel;
  

parseOutput = getappdata(manualMaskUIArray.mainHandle,'parseOutput');
rowStrings = get(manualMaskUIArray.wellRowPopup,'String');
collumnStrings = get(manualMaskUIArray.wellCollumnPopup,'String');
selectedFilePath = getFileListForWell(parseOutput.matchedFileNames,pattern,rowStrings{get(manualMaskUIArray.wellRowPopup,'Value')},collumnStrings{get(manualMaskUIArray.wellCollumnPopup,'Value')},channel)

if length(selectedFilePath) == 1
    selectedFilePath = selectedFilePath{:};
else
    error('FileNotFound','ERROR: Selected file not found');
end

fullPathToImage = fullfile(params.general.processingFolder,selectedFilePath);
setappdata(manualMaskUIArray.inputImageHolder,'currentImagePath',fullPathToImage);
currentImage = imread(fullPathToImage);

autoScaleFlag = get(manualMaskUIArray.autoScaleCheckBox,'Value');
if(autoScaleFlag)
    imshow(imadjust(im2uint8(currentImage)),'Parent',manualMaskUIArray.inputImageHolder);
else
    imshow((im2uint8(currentImage)),'Parent',manualMaskUIArray.inputImageHolder);
end
title(manualMaskUIArray.inputImageHolder,'Double click to save','FontName','Arial','FontSize',16,'Color',[1 1 1]);
createEllipse(manualMaskUIArray);


function createEllipse(manualMaskUIArray)

ellipseHandle = imellipse(manualMaskUIArray.inputImageHolder);
wait(ellipseHandle);

BW = createMask(ellipseHandle);
imshow(BW)
title(manualMaskUIArray.inputImageHolder,'Mask to save','FontName','Arial','FontSize',16,'Color',[1 1 1]);
maskFileName = [datestr(now,'yy_mm_dd') '_mask.tif'];

if(~isempty(BW))
    [filename, pathname] = uiputfile(maskFileName,...
        'Save Image');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User selected Cancel');
    else
        disp(['User selected ',fullfile(pathname,filename)]);
        imwrite(BW,fullfile(pathname,filename),'tif');      
        set(getappdata(manualMaskUIArray.mainHandle,'parentMaskEditHandle'),'String',fullfile(pathname,filename));
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
