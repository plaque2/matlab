function testWindowHandleArray = testParameters(parentWindowHandleArray,testType)


%%%PARENT FIGURE INITIALIZATION

testWindowHandleArray.mainHandle = figure('units','pixels',...
    'position',[700 300 700 550],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Test Mode',...
    'resize','off',...
    'Renderer','painters',...
    'Color',[0.314 0.314 0.314],...
    'BusyAction','cancel',...
    'Interruptible','off');

%set test type as a global variable in the current test window
setappdata(testWindowHandleArray.mainHandle,'testType',testType);


%%%%IMAGE HOLDER
testWindowHandleArray.imageHolder = axes('units','pixels',...
    'Parent',testWindowHandleArray.mainHandle,...
    'position',[14 53  490 490],...
    'xtick',[],'ytick',[],'box','on','XColor',[0.512 0.512 0.512],'YColor', [0.512 0.512 0.512],'TickDir','in','SortMethod','childorder');
% whitebg(testWindowHandleArray.mainHandle,[0 0 0]);

%%%%%OUTPUT PANEL
testWindowHandleArray.testWindowOutputPanel = uipanel('Title','Output', ...
    'Parent',testWindowHandleArray.mainHandle,...
    'BackgroundColor',[0.314 0.314 0.314],...
    'ForegroundColor',[1 1 1],...
    'fontSize',9,...
    'Units','pixels', 'Position',[511 148 175 400]);
%%%%%OUTPUT TEXT
testWindowHandleArray.testWindowOutputPanelTextEdit = uicontrol('Style','edit','FontName','Arial','FontSize',9, ...
    'Parent',testWindowHandleArray.testWindowOutputPanel,...
    'Min',0, 'Max',2, 'HorizontalAlignment','left','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'Units','normalized', 'Position',[0 0 1 1],...
    'Enable','Inactive');


%%%%%WELL SELECTION

testWindowHandleArray.wellRowPopup = uicontrol('Style', 'popup',...
    'Parent',testWindowHandleArray.mainHandle,...
    'String',{'N/A'},...
    'units','pixels',...
    'fonts',16);
%     'CreateFcn',{@wellRowCollumnCreateFcn,parentWindowHandleArray,testWindowHandleArray});
if(ismac)
    set(testWindowHandleArray.wellRowPopup,'position',[204 18 80 35]);
else
    
    set(testWindowHandleArray.wellRowPopup,'position',[284 18 50 35]);
end

testWindowHandleArray.wellCollumnPopup = uicontrol('Style', 'popup',...
    'Parent',testWindowHandleArray.mainHandle,...
    'String','N/A',...
    'units','pixels',...
    'position',[334 18 50 35],...
    'fonts',16);
%     'CreateFcn',{@wellRowCollumnCreateFcn,parentWindowHandleArray,testWindowHandleArray});
if(ismac)
    set(testWindowHandleArray.wellCollumnPopup,'position',[274 18 80 35]);
else
    set(testWindowHandleArray.wellCollumnPopup,'position',[334 18 50 35]);
end

testWindowHandleArray.wellChannelPopup = uicontrol('Style', 'popup',...
    'Parent',testWindowHandleArray.mainHandle,...
    'String','N/A',...
    'units','pixels',...
    'position',[384 18 50 35],...
    'fonts',16,...
    'visible','off',...
    'CreateFcn',{@wellRowCollumnCreateFcn,parentWindowHandleArray,testWindowHandleArray});
if(ismac)
    set(testWindowHandleArray.wellChannelPopup,'position',[344 18 80 35]);
else
    set(testWindowHandleArray.wellChannelPopup,'position',[384 18 50 35]);
end
%





%%%GO TO WELL BUTTON
testWindowHandleArray.goToWellBtn = uicontrol('Style', 'push',...
    'Parent',testWindowHandleArray.mainHandle,...
    'String','Go to',...
    'units','pixels',...
    'position',[434 18  70 35],...
    'fonts',14,...
    'BackgroundColor',[0.512 0.512 0.512],...
    'ForegroundColor',[1 1 1]);





%%% Contrast related UI ellements
testWindowHandleArray.contrastPanel = uipanel('BorderType','line',...
    'Units','pixels','Position',[14 53 490 100],...%0.02 0.29[0.02 0.29  0.7 0.7][100 180 410 120]
    'Title','Adjust Contrast','Fonts',10,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],'visible','off','Clipping','on');

testWindowHandleArray.applyContrast = uicontrol(testWindowHandleArray.contrastPanel,'Position',[440 4 50 25],...
    'Style', 'pushbutton','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'String','Apply','Fonts',10);

testWindowHandleArray.resetContrast = uicontrol(testWindowHandleArray.contrastPanel,'Position',[390 4 50 25],...
    'Style', 'pushbutton','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'String','Reset','Fonts',10);

testWindowHandleArray.minMaxContrast = uicontrol(testWindowHandleArray.contrastPanel,'Position',[340 4 50 25],...
    'Style', 'pushbutton','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'String','Auto','Fonts',10);

testWindowHandleArray.rangeStaticText = uicontrol(testWindowHandleArray.contrastPanel,'Style', 'text', 'String','Range','fonts',10,'Position',[5 4 50 20],...
    'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1]);

testWindowHandleArray.lowerLimitEdit = uicontrol(testWindowHandleArray.contrastPanel,'Style','edit','fonts',10,'Position',[60 4 50 20],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0]);

testWindowHandleArray.hyphenStaticText = uicontrol(testWindowHandleArray.contrastPanel,'Style','text','String','-','fonts',10,'Position',[115 4 10 20],...
    'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1]);

testWindowHandleArray.upperLimitEdit = uicontrol(testWindowHandleArray.contrastPanel,'Style','edit','fonts',10,'Position',[130 4 50 20],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0]);

testWindowHandleArray.histAxes = axes('units','pixels',...
    'Parent',testWindowHandleArray.contrastPanel,...
    'position',[0 30 490 80]);

%%%%%




% hist(double(I(:)));
% get(histAxes



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%ZOOM AND PAN

zoomPic = imread('zoomToggleFace.tif');
panPic = imread('panToggleFace.tif');
contrastPic = imread('contrastToggleFace.tif');
savePic = imread('saveFace.tif');
testWindowHandleArray.zoomToggleButton = uicontrol('Style', 'togglebutton',...
    'Parent',testWindowHandleArray.mainHandle,...
    'units','pixels',...
    'BackgroundColor',[0.512 0.512 0.512],...
    'position',[14.7 18  35 35],...
    'fonts',14,...
    'CData',zoomPic,...
    'Enable','off');

testWindowHandleArray.panToggleButton = uicontrol('Style', 'togglebutton',...
    'Parent',testWindowHandleArray.mainHandle,...
    'units','pixels',...
    'BackgroundColor',[0.512 0.512 0.512],...
    'position',[49.7 18  35 35],...
    'fonts',14,...
    'CData',panPic,...
    'Enable','off');


testWindowHandleArray.contrastToggleButton = uicontrol('Style', 'togglebutton',...
    'Parent',testWindowHandleArray.mainHandle,...
    'units','pixels',...
    'BackgroundColor',[0.512 0.512 0.512],...
    'position',[84.7 18 35 35],...
    'fonts',14,...
    'CData',contrastPic,...
    'Enable','off');
%%%minor visual tweaks for mac
if(ismac)
    set(testWindowHandleArray.contrastToggleButton,'Style','pushbutton'); 
    set(testWindowHandleArray.panToggleButton,'Style','pushbutton');  
    set(testWindowHandleArray.zoomToggleButton,'Style','pushbutton'); 
end
%%%%SAVE BUTTON
testWindowHandleArray.saveButton = uicontrol('Style', 'push',...
    'Parent',testWindowHandleArray.mainHandle,...
    'units','pixels',...
    'position',[119.7 18  35 35],...
    'fonts',14,...
    'BackgroundColor',[0.512 0.512 0.512],...
    'CData',savePic,...
    'Callback',{@saveCurrentImage,testWindowHandleArray},...
    'Enable','off');




switch testType
    case 'stitch'
        %%%Channel selector for stitch
        %         params = getParametersFromGUI(parentWindowHandleArray,'VIRUS');
        
    case 'mask'
        
        testWindowHandleArray.maskOverlayCheckBox = uicontrol('Style','checkbox',...
            'Parent',testWindowHandleArray.mainHandle,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 0 0],...
            'Units','pixels','Position',[511 110 200 35],'FontName','Arial','FontSize',9,'FontWeight','bold','String','Mask Overlay','Value',1);
        set(testWindowHandleArray.maskOverlayCheckBox,'Callback',{@visualizeWell,testWindowHandleArray});
        
    case 'nuclei'
        
        testWindowHandleArray.thresholdedImageOverlayCheckBox = uicontrol('Style','checkbox',...
            'Parent',testWindowHandleArray.mainHandle,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[0 0 1],...
            'Units','pixels','Position',[511 110 200 35],'FontName','Arial','FontSize',9,'FontWeight','bold','String','Thresholded Image Overlay','Value',1);
        
        set(testWindowHandleArray.thresholdedImageOverlayCheckBox,'Callback',{@visualizeWell,testWindowHandleArray});
        
    case 'virus'
        
        
        testWindowHandleArray.thresholdedImageOverlayCheckBox = uicontrol('Style','checkbox',...
            'Parent',testWindowHandleArray.mainHandle,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[0 1 0],...
            'Units','pixels','Position',[511 110 200 35],'FontName','Arial','FontSize',9,'FontWeight','bold','String','Thresholded Image Overlay','Value',1);
        
        
        %Get virus specific parameters to enable/disable the
        params = getParametersFromGUI(parentWindowHandleArray,'VIRUS');
        if(params.virus.finePlaqueDetectionFlag)
            testWindowHandleArray.localMaximaOverlayCheckBox = uicontrol('Style','checkbox',...
                'Parent',testWindowHandleArray.mainHandle,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 0 0],...
                'Units','pixels','Position',[511 75 200 35],'FontName','Arial','FontSize',9,'FontWeight','bold','String','Local Maxima Overlay','Value',1);
            set(testWindowHandleArray.localMaximaOverlayCheckBox,'Callback',{@visualizeWell,testWindowHandleArray});
        end
        set(testWindowHandleArray.thresholdedImageOverlayCheckBox,'Callback',{@visualizeWell,testWindowHandleArray});
end



%%%%%%% BUTTON CALLBACK DEFINITIONS

% callback functions for Zooming and Paning  current image are declared
% here.These are seperate from other attribute declarations because, Matlab
% can't see the button handles correctly inside callback functions. THis is
% probably a bug. I wasn't able o find a workaround.
set(testWindowHandleArray.zoomToggleButton,'Callback',{@toggleZoomImage,testWindowHandleArray});
set(testWindowHandleArray.panToggleButton,'Callback',{@togglePanImage,testWindowHandleArray});
set(testWindowHandleArray.contrastToggleButton,'Callback',{@changeContrast,testWindowHandleArray});
set(testWindowHandleArray.applyContrast,'Callback',{@applyContrastLimits,testWindowHandleArray});
set(testWindowHandleArray.resetContrast,'Callback',{@resetContrastLimits,testWindowHandleArray});
set(testWindowHandleArray.minMaxContrast,'Callback',{@minMaxContrastLimits,testWindowHandleArray});
set(testWindowHandleArray.goToWellBtn,'Callback',{@goToImage,parentWindowHandleArray,testWindowHandleArray});

function wellRowCollumnCreateFcn(handle,event,parentWindowHandleArray,testWindowHandleArray)

params = getParametersFromGUI(parentWindowHandleArray,'ALL');
testType = getappdata(testWindowHandleArray.mainHandle,'testType');

try
    
    
    switch testType
        
        
        case 'stitch'
            
            inputPath = params.stitch.inputFolder;
            filenamePattern = params.stitch.fileNamePattern;
            
        case 'mask'
            
            inputPath =  params.general.processingFolder;
            filenamePattern = params.general.fileNamePattern;
        case 'nuclei'
            
            inputPath =  params.general.processingFolder;
            filenamePattern = params.general.fileNamePattern;
        case 'virus'
            
            inputPath =  params.general.processingFolder;
            filenamePattern = params.general.fileNamePattern;
        otherwise
            error('WrongTestTypeSelected','No valid testing type selected');
            
    end
    
    parseOutput = parseImageFilenames(inputPath,filenamePattern);
    if(isempty(parseOutput))
        error('NoFilesFound','No files Found matching the specified pattern');
        errordlg('No files Found matching the specified pattern','Parse Error');
    end
    
    if(strcmp(testType,'stitch'))
        
        if(isfield(parseOutput,'channelNames'))
            channelList = parseOutput.channelNames;
        else
            channelList = '';
        end
        set(handle,'visible','on');
        set(handle,'String',channelList);
    end
    
    set(testWindowHandleArray.wellRowPopup,'String',parseOutput.wellRows);
    set(testWindowHandleArray.wellCollumnPopup,'String',parseOutput.wellCollumns);
    
    setappdata(testWindowHandleArray.mainHandle,'parseOutput',parseOutput);
    
    
catch ErrorMessage
    disp(ErrorMessage);
end





function  goToImage(handle,event,parentWindowHandleArray,testWindowHandleArray)

params = getParametersFromGUI(parentWindowHandleArray,'ALL');
testType = getappdata(testWindowHandleArray.mainHandle,'testType');
parseOutput = getappdata(testWindowHandleArray.mainHandle,'parseOutput');

switch testType
    
    case 'stitch'
        channelList = get(testWindowHandleArray.wellChannelPopup,'String');
        if(length(channelList)==1)
            channelValue = channelList;
        else
            channelValue = channelList{get(testWindowHandleArray.wellChannelPopup,'Value')};
        end
        
        
        inputPath = params.stitch.inputFolder;
        filenamePattern = params.stitch.fileNamePattern;
        
    case 'mask'
        channelValue =params.mask.selectedChannel;
        inputPath =  params.general.processingFolder;
        filenamePattern = params.general.fileNamePattern;
        
        
        
    case 'nuclei'
        channelValue =params.nuclei.selectedChannel;
        inputPath =  params.general.processingFolder;
        filenamePattern = params.general.fileNamePattern;
        
        
    case 'virus'
        channelValue =params.virus.selectedChannel;
        inputPath =  params.general.processingFolder;
        filenamePattern = params.general.fileNamePattern;
    otherwise
        h = errordlg('Incorrect test type selected','Error');
        error('IncorrectTestType','Incorrect test type selected');
        
end


rowValue = get(testWindowHandleArray.wellRowPopup,'Value');
colValue = get(testWindowHandleArray.wellCollumnPopup,'Value');

rowString = get(testWindowHandleArray.wellRowPopup,'String');
colString = get(testWindowHandleArray.wellCollumnPopup,'String');


selectedFileName = getFileListForWell(parseOutput.matchedFileNames,filenamePattern,rowString{rowValue},colString{colValue},channelValue);

selectedFileName = fullfile(inputPath,selectedFileName);

writeinlog(testWindowHandleArray.testWindowOutputPanelTextEdit,'Loading...');
switchOnOffAllGUIControls(testWindowHandleArray.mainHandle);
drawnow;
if length(selectedFileName) == 1
    selectedFileName = selectedFileName{:};
end

try
    currentWellData  = analyzeWell(selectedFileName,params,testType);
    %     currentWellData.contrastLimits=[0 1];% default contrasts
    
    %check if currentWellData has been already defined and has a
    %contrastLimits fields
    %field
    
    
    if(isappdata(testWindowHandleArray.imageHolder,'currentWellData'))
        previousWellData = getappdata(testWindowHandleArray.imageHolder,'currentWellData');
        if(isfield(previousWellData,'contrastLimits'))
            currentWellData.contrastLimits = previousWellData.contrastLimits;
        end
    end
    
    
    setappdata(testWindowHandleArray.imageHolder,'currentWellData',currentWellData);
    
    % imshow(imresize(imread('C:\Users\Vardan\Documents\MATLAB\plaque2.0\src\processing-data\D01_w2.TIF'),0.1),'Parent',testWindowHandleArray.imageHolder);
    visualizeWell(testWindowHandleArray);
    
    writeinlog(testWindowHandleArray.testWindowOutputPanelTextEdit,currentWellData.outputMessage');
    switchOnOffAllGUIControls(testWindowHandleArray.mainHandle);
    
catch ErrorMessage
    disp(ErrorMessage);
    writeinlog(testWindowHandleArray.testWindowOutputPanelTextEdit,strcat({'ERROR: '},ErrorMessage.message));
    switchOnOffAllGUIControls(testWindowHandleArray.mainHandle);
    drawnow;
end



function saveCurrentImage(handle,event,testWindowHandleArray)
currentImageToBeSaved = getimage(testWindowHandleArray.imageHolder);
if(~isempty(currentImageToBeSaved))
    [filename, pathname] = uiputfile('*.png',...
        'Save Image');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User selected Cancel');
    else
        disp(['User selected ',fullfile(pathname,filename)]);
        imwrite(currentImageToBeSaved,fullfile(pathname,filename),'png');
    end
end


function toggleZoomImage(handle,event,testWindowHandleArray)
disp(testWindowHandleArray.panToggleButton);

zoomToggleState = get(testWindowHandleArray.zoomToggleButton,'Value');
if(zoomToggleState)
    zoomObjectHandle = zoom(testWindowHandleArray.mainHandle)
    zoom on
    setAllowAxesZoom(zoomObjectHandle,testWindowHandleArray.histAxes,false);
    pan off
    set(testWindowHandleArray.panToggleButton,'Value',0);
    drawnow;
else
    zoom off
end


% zoom on
% pan off



function togglePanImage(handle,event,testWindowHandleArray)
disp(testWindowHandleArray.zoomToggleButton);

panToggleState = get(testWindowHandleArray.panToggleButton,'Value');

if(panToggleState)
    zoom off
    panObjectHandle = pan(testWindowHandleArray.mainHandle)
    pan on
    setAllowAxesPan(panObjectHandle,testWindowHandleArray.histAxes,false);
    set(testWindowHandleArray.zoomToggleButton,'Value',0);
    drawnow
else
    pan off
end


function changeContrast(handle,event,testWindowHandleArray)
 set(testWindowHandleArray.panToggleButton,'Value',0);
  set(testWindowHandleArray.zoomToggleButton,'Value',0);
pan off
zoom off
drawnow;
currentContrastPanelState = get(testWindowHandleArray.contrastPanel,'visible');

currentWellData = getappdata(testWindowHandleArray.imageHolder,'currentWellData');
testType = getappdata(testWindowHandleArray.mainHandle,'testType');
%     disp(currentWellData.bitDepth);

if(isfield(currentWellData,'contrastLimits'))
    contrastLimits = currentWellData.contrastLimits;
else
    contrastLimits = [0 1].*currentWellData.bitDepth;
end



if(strcmp(currentContrastPanelState,'on'))
    switchOnOffAllGUIControls(testWindowHandleArray.mainHandle);
    drawnow;
    visualizeWell(testWindowHandleArray);
    set(testWindowHandleArray.contrastPanel,'visible','off');
    switchOnOffAllGUIControls(testWindowHandleArray.mainHandle);
elseif(strcmp(currentContrastPanelState,'off'))
    imshow(currentWellData.inputImage,'Parent',testWindowHandleArray.imageHolder);
    initializeControlPanelAxes(testWindowHandleArray,contrastLimits);
    set(testWindowHandleArray.contrastPanel,'visible','on');
else
    error('SomethingWentWrong','You shouldnt get here unless there was a problem with Matlab GUI again...');
end






function applyContrastLimits(src,event,testWindowHandleArray)

currentContrastLimits{1} = str2num(get(testWindowHandleArray.lowerLimitEdit,'String'));
currentContrastLimits{2} =str2num(get(testWindowHandleArray.upperLimitEdit,'String'));

currentWellData = getappdata(testWindowHandleArray.imageHolder,'currentWellData');

if(isempty(currentContrastLimits{1})||isempty(currentContrastLimits{2}))
    
    currentContrastLimits = [0 currentWellData.bitDepth];
    
else
    currentContrastLimits =cell2mat(currentContrastLimits);
    if (any(currentContrastLimits<0)||any(currentContrastLimits>currentWellData.bitDepth))
        currentContrastLimits = [0,currentWellData.bitDepth];
    end
end

initializeControlPanelAxes(testWindowHandleArray,currentContrastLimits);
currentWellData.contrastLimits = currentContrastLimits;
setappdata(testWindowHandleArray.imageHolder,'currentWellData',currentWellData);




function resetContrastLimits(src,event,testWindowHandleArray)
currentWellData = getappdata(testWindowHandleArray.imageHolder,'currentWellData');
currentContrastLimits = [0 currentWellData.bitDepth];
initializeControlPanelAxes(testWindowHandleArray,currentContrastLimits);

function minMaxContrastLimits(src,evnt,testWindowHandleArray)
inputImage = getimage(testWindowHandleArray.imageHolder);
currentContrastLimits(1) = min(inputImage(:));
currentContrastLimits(2) = max(inputImage(:));
initializeControlPanelAxes(testWindowHandleArray,currentContrastLimits);


function initializeControlPanelAxes(testWindowHandleArray,newAxesXLimits)
cla(testWindowHandleArray.histAxes);

inputImage = getimage(testWindowHandleArray.imageHolder);

set(testWindowHandleArray.lowerLimitEdit,'String',num2str(newAxesXLimits(1)));
set(testWindowHandleArray.upperLimitEdit,'String',num2str(newAxesXLimits(2)));
set(testWindowHandleArray.imageHolder,'CLim',newAxesXLimits);
%HARDCODED%%
if(newAxesXLimits(2)<3000)
    nbins = newAxesXLimits(2);
else
    nbins = 1000;
end
%%%%%
% correctedImage = inputImage;
% correctedImage(correctedImage>newAxesXLimits(2)) =
hist(testWindowHandleArray.histAxes,double(inputImage(:)),nbins);
histPatchObject = findobj(testWindowHandleArray.histAxes,'Type','patch');
set(histPatchObject,'FaceColor',[.532 .532 .532],'EdgeColor',[.532 .532 .532]);
set(testWindowHandleArray.histAxes,'xtick',[],'ytick',[],'box','off','XColor',[0.512 0.512 0.512],'YColor',[0.512 0.512 0.512],'TickDir','in','XLimMode','manual');
set(testWindowHandleArray.histAxes,'XLim',newAxesXLimits);

histAxesXLim =  get(testWindowHandleArray.histAxes,'XLim');
histAxesYLim = get(testWindowHandleArray.histAxes,'YLim');

set(testWindowHandleArray.histAxes, 'Clipping', 'on');
%  axis(testWindowHandleArray.histAxes,[0 axisWidth 0 axisHeight]);

% axisLimits = [axisWidth axisHeight];

sliderWidth =floor((histAxesXLim(2)-histAxesXLim(1))*1/100);

histAxesXLim=histAxesXLim + [-sliderWidth sliderWidth];
set(testWindowHandleArray.histAxes,'XLim',histAxesXLim);
sliderHeight = histAxesYLim(2)-histAxesYLim(1);
x0= histAxesXLim(1);
y0 = 0;

xdata = [x0 x0 x0+sliderWidth x0+sliderWidth];
ydata = [y0 y0+sliderHeight y0+sliderHeight y0];
disp(histAxesXLim(1));
Limits = [histAxesXLim(1) histAxesXLim(2)-sliderWidth];



lowerLimitHandle = patch(xdata,ydata,[1 0 0],'AlphaDataMapping','none','Parent',testWindowHandleArray.histAxes,'Tag','lowerLimit','LineStyle','none');
setappdata(lowerLimitHandle,'width',sliderWidth);
setappdata(lowerLimitHandle,'height',sliderHeight);
setappdata(lowerLimitHandle,'dragLimits',Limits);
setappdata(lowerLimitHandle,'imageHolder',testWindowHandleArray.imageHolder);
setappdata(lowerLimitHandle,'editBox',testWindowHandleArray.lowerLimitEdit);

x0= histAxesXLim(2)-sliderWidth;
y0 = 0;
xdata = [x0 x0 x0+sliderWidth x0+sliderWidth];
ydata = [y0 y0+sliderHeight y0+sliderHeight y0];
Limits = [histAxesXLim(1)+sliderWidth histAxesXLim(2)];

upperLimitHandle = patch(xdata,ydata,[1 0 0],'AlphaDataMapping','none','Parent',testWindowHandleArray.histAxes,'Tag','upperLimit','LineStyle','none');
setappdata(upperLimitHandle,'width',sliderWidth);
setappdata(upperLimitHandle,'height',sliderHeight);
setappdata(upperLimitHandle,'dragLimits',Limits);
setappdata(upperLimitHandle,'imageHolder',testWindowHandleArray.imageHolder);
setappdata(upperLimitHandle,'editBox',testWindowHandleArray.upperLimitEdit);
set(testWindowHandleArray.mainHandle,'WindowButtonDownFcn',{@constrainContrastSliders,upperLimitHandle,lowerLimitHandle,histAxesXLim});

function constrainContrastSliders(src,evnt,upperLimitHandle,lowerLimitHandle,axisXLimits)

if gco == upperLimitHandle
    lowerLimitXdata = get(lowerLimitHandle,'xdata');
    setappdata(upperLimitHandle,'dragLimits',[lowerLimitXdata(4) axisXLimits(2)]);
    set(upperLimitHandle,'ButtonDownFcn',@startDraggingContrastSliders);
elseif gco == lowerLimitHandle
    upperLimitXdata = get(upperLimitHandle,'xdata');
    setappdata(lowerLimitHandle,'dragLimits',[axisXLimits(1) upperLimitXdata(1)]);
    set(lowerLimitHandle,'ButtonDownFcn',@startDraggingContrastSliders);
else
    disp('');
end

