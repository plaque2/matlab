function thresholdImagesUI(params,typeOfImage,parentThresholdEditHandle)%comment input for testing
% %Uncomment for testing
% typeOfImage = 'nuclei';
% params.general.processingFolder = 'D:\Plaque2SampleData\140727-HAdV-PLAQ-Ara-C-AY-3dpi-p1_Plate_910\TimePoint_1\Stitched';
% params.general.fileNamePattern = '(?<wellName>[A-Z][0-9]*)_(?<channelName>w[0-9]*).TIF';
% params.nuclei.selectedChannel= 'w1';
%

%

thresholdUIArray.mainHandle = figure('units','pixels',...
    'position',[700 300 800 480],...
    'menubar','none',...
    'numbertitle','off',...
    'name','Threshold Image',...
    'resize','off',...
    'Renderer','painters',...
    'Color',[0.314 0.314 0.314],...
    'BusyAction','cancel',...
    'Interruptible','off');

% parseoutput


%%%% Add all the read-only input parameters to the main handle for later
%%%% use
parseOutput =  parseImageFilenames(params.general.processingFolder,params.general.fileNamePattern);
setappdata(thresholdUIArray.mainHandle,'parseOutput',parseOutput);
setappdata(thresholdUIArray.mainHandle,'typeOfImage',typeOfImage);
setappdata(thresholdUIArray.mainHandle,'params',params);

thresholdUIArray.inputImageHolder = axes('units','pixels',...
    'Parent',thresholdUIArray.mainHandle,...
    'position',[20 70  360 360],...
    'xtick',[],'ytick',[],'box','on','XColor',[0.512 0.512 0.512],'YColor', [0.512 0.512 0.512],'TickDir','in');

thresholdUIArray.inputImageHolderTxt = title(thresholdUIArray.inputImageHolder,'Input Image','FontWeight','bold','FontName','Arial','FontSize',16,'Color',[1 1 1]);

thresholdUIArray.zoomedImageHolder = axes('units','pixels',...
    'Parent',thresholdUIArray.mainHandle,...
    'position',[420 70  360 360],...
    'xtick',[],'ytick',[],'box','on','XColor',[0.512 0.512 0.512],'YColor', [0.512 0.512 0.512],'TickDir','in');

thresholdUIArray.zoomedImageHolderTxt = title(thresholdUIArray.zoomedImageHolder,'Zoomed Region','FontWeight','bold','FontName','Arial','FontSize',16,'Color',[1 1 1]);


% %%%%%WELL SELECTION

thresholdUIArray.wellRowPopup = uicontrol('Style', 'popup',...
    'Parent',thresholdUIArray.mainHandle,...
    'String',{'N/A'},...
    'units','pixels',...
    'position',[20 45 50 25],...
    'UserData','Row',...
    'fonts',10,...
    'CreateFcn',{@wellRowCollumnCreateFcn,thresholdUIArray});
if(ismac)
    set(thresholdUIArray.wellRowPopup,'position',[15 45 65 25]);
else
    set(thresholdUIArray.wellRowPopup,'position',[20 45 50 25]);
end
thresholdUIArray.wellCollumnPopup = uicontrol('Style', 'popup',...
    'Parent',thresholdUIArray.mainHandle,...
    'String','N/A',...
    'units','pixels',...
    'position',[70 45 50 25],...
    'UserData','Collumn',...
    'fonts',10,...
    'CreateFcn',{@wellRowCollumnCreateFcn,thresholdUIArray});
if(ismac)
    set(thresholdUIArray.wellCollumnPopup,'position',[65 45 65 25]);
else
    set(thresholdUIArray.wellCollumnPopup,'position',[70 45 50 25]);
end

thresholdUIArray.currentThresholdText = uicontrol('Parent',thresholdUIArray.mainHandle,...
    'style','text','FontWeight','bold','String','Threshold:','BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'fonts',9,...
    'position',[415 40  70 25]);
thresholdUIArray.currentThresholdEdit = uicontrol('Parent',thresholdUIArray.mainHandle,...
    'style','edit','String','0.5','BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'fonts',9,...
    'position',[485 44  45 25]);


thresholdUIArray.autoScaleCheckBox = uicontrol('Style','checkbox',...
    'Parent',thresholdUIArray.mainHandle,'BackgroundColor',[0.314 0.314 0.314],'ForegroundColor',[1 1 1],...
    'Units','pixels','Position',[180 49 150 12],'FontName','Arial','FontSize',8,'FontWeight','bold','String','Auto Scale Images','Value',1);

%%%GO TO WELL BUTTON
thresholdUIArray.goToWellBtn = uicontrol('Style', 'push',...
    'Parent',thresholdUIArray.mainHandle,...
    'String','Go to',...
    'units','pixels',...
    'position',[120 44 50 26],...
    'fonts',10,...
    'BackgroundColor',[0.314 0.314 0.314],...
    'ForegroundColor',[1 1 1],...
    'Callback',{@goToImage,thresholdUIArray});



thresholdUIArray.thresholdSlider = uicontrol('Style', 'slider',...
    'Parent',thresholdUIArray.mainHandle,...
    'Min',0,'Max',1,'Value',0.5,...
    'Position', [530 44 251 25],'SliderStep',[0.001 0.01]);

thresholdUIArray.setThresholdBtn = uicontrol('Style', 'push',...
    'Parent',thresholdUIArray.mainHandle,...
    'String','Set Treshold',...
    'units','pixels',...
    'position',[700 10 80 26],...
    'fonts',10,...
    'BackgroundColor',[0.314 0.314 0.314],...
    'ForegroundColor',[1 1 1],...
    'Callback',{@setThreshold,thresholdUIArray,parentThresholdEditHandle});

set(thresholdUIArray.currentThresholdEdit,'Callback',{@applyThreshold,thresholdUIArray});
set(thresholdUIArray.thresholdSlider,'Callback',{@onSliderMove,thresholdUIArray});

function wellRowCollumnCreateFcn(handle,event,thresholdUIArray)
params = getappdata(thresholdUIArray.mainHandle,'params');
typeOfImage = getappdata(thresholdUIArray.mainHandle,'typeOfImage');
try
    switch typeOfImage
        
        case 'nuclei'
            inputPath =  params.general.processingFolder;
            pattern  = params.general.fileNamePattern;
            channel = params.nuclei.selectedChannel;
        case 'virus'
            inputPath =  params.general.processingFolder;
            pattern = params.general.fileNamePattern;
            channel = params.virus.selectedChannel;
        otherwise
            error('TreshUITypeImage:','You should not be here');
            
    end
    
    parseOutput = getappdata(thresholdUIArray.mainHandle,'parseOutput');
    
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



function  goToImage(handle,event,thresholdUIArray)
params = getappdata(thresholdUIArray.mainHandle,'params');
typeOfImage = getappdata(thresholdUIArray.mainHandle,'typeOfImage');
switch typeOfImage
    
    case 'nuclei'
        
        pattern  = params.general.fileNamePattern;
        channel = params.nuclei.selectedChannel;
    case 'virus'
        
        pattern = params.general.fileNamePattern;
        channel = params.virus.selectedChannel;
    otherwise
        error('TreshUITypeImage','You should not be here');
        
end

parseOutput = getappdata(thresholdUIArray.mainHandle,'parseOutput');
rowStrings = get(thresholdUIArray.wellRowPopup,'String');
collumnStrings = get(thresholdUIArray.wellCollumnPopup,'String');
selectedFilePath = getFileListForWell(parseOutput.matchedFileNames,pattern,rowStrings{get(thresholdUIArray.wellRowPopup,'Value')},collumnStrings{get(thresholdUIArray.wellCollumnPopup,'Value')},channel)

if length(selectedFilePath) == 1
    selectedFilePath = selectedFilePath{:};
else
    error('FileNotFound','ERROR: Selected file not found');
end
fullPathToImage = fullfile(params.general.processingFolder,selectedFilePath);
setappdata(thresholdUIArray.inputImageHolder,'currentImagePath',fullPathToImage);
currentImage = imread(fullPathToImage);
autoScaleFlag = get(thresholdUIArray.autoScaleCheckBox,'Value');
if(autoScaleFlag)
    imshow(imadjust(im2uint8(currentImage)),'Parent',thresholdUIArray.inputImageHolder);
else
    imshow((im2uint8(currentImage)),'Parent',thresholdUIArray.inputImageHolder);
end
title(thresholdUIArray.inputImageHolder,'Input Image','FontName','Arial','FontWeight','bold','FontSize',16,'Color',[1 1 1]);
zoomLevel = 20;%10x 5x 2x 1x
[xImageSize yImageSize] = size(currentImage);
initialPosition = [10 10 xImageSize/zoomLevel yImageSize/zoomLevel];
showZoomedRegion(initialPosition,currentImage,thresholdUIArray);
rectHandle = imrect(thresholdUIArray.inputImageHolder,initialPosition);
setappdata(thresholdUIArray.inputImageHolder,'rectHandle',rectHandle);
setFixedAspectRatioMode(rectHandle,true);
% imshow(currentImage(initialPosition(1):initialPosition(3),initialPosition(2):initialPosition(4)),'Parent',thresholdUIArray.zoomedImageHolder);

addNewPositionCallback(rectHandle,@(pos) showZoomedRegion(pos,currentImage,thresholdUIArray));
constraintRectHandle = makeConstrainToRectFcn('imrect',get(thresholdUIArray.inputImageHolder,'XLim')+[1 -1],get(thresholdUIArray.inputImageHolder,'YLim')+[1 -1]);
setPositionConstraintFcn(rectHandle,constraintRectHandle);

function showZoomedRegion(currentPosition,currentImage,thresholdUIArray)
params = getappdata(thresholdUIArray.mainHandle,'params');
typeOfImage = getappdata(thresholdUIArray.mainHandle,'typeOfImage');
currentPosition = floor(currentPosition);
imageRegion = currentImage(currentPosition(2):(currentPosition(4)+currentPosition(2)),currentPosition(1):(currentPosition(3)+currentPosition(1)));

% drawnow;
%Below is a STUPID METHOD OF OVERLAYING WIHTOUT TRANSPARENCY probably needs to
%be changed in later versions but so far this is the most efficient when working with
%Renderer Painter
thresholdedImageRegion  = im2bw(imageRegion,str2num(get(thresholdUIArray.currentThresholdEdit,'String')));
autoScaleFlag = get(thresholdUIArray.autoScaleCheckBox,'Value');
if(autoScaleFlag)
    overlayRGB=convert2RGB(imadjust(imageRegion),[1 1 1]);
else
    overlayRGB=convert2RGB((imageRegion),[1 1 1]);
end
switch typeOfImage
    case 'nuclei'
        
        nucleiOverlayRGB = convert2RGB(thresholdedImageRegion,[0.01 0.01 1]);
        overlayRGB(nucleiOverlayRGB>0) = nucleiOverlayRGB(nucleiOverlayRGB >0);
    case 'virus'
        virusOverlayRGB = convert2RGB(thresholdedImageRegion,[0.01 1 0.01]);
        overlayRGB(virusOverlayRGB>0) = virusOverlayRGB(virusOverlayRGB >0);
    otherwise
        error('InputTypeNotSpecified','Input type not specified');
end


imshow(overlayRGB,'Parent',thresholdUIArray.zoomedImageHolder);
title(thresholdUIArray.zoomedImageHolder,'Zoomed Region','FontName','Arial','FontWeight','bold','FontSize',16,'Color',[1 1 1]);
function applyThreshold(handle,event,thresholdUIArray)


rectHandle = getappdata(thresholdUIArray.inputImageHolder,'rectHandle');
if(~isempty(rectHandle)&&~isempty(str2num(get(handle,'String'))))
    pos = getPosition(rectHandle);
    set(thresholdUIArray.thresholdSlider,'Value',str2num(get(handle,'String')));
    
    currentImage = imread(getappdata(thresholdUIArray.inputImageHolder,'currentImagePath'));
    showZoomedRegion(pos,currentImage,thresholdUIArray);
end

function onSliderMove(handle,event,thresholdUIArray)

set(thresholdUIArray.currentThresholdEdit,'String',num2str(get(handle,'Value')));

rectHandle = getappdata(thresholdUIArray.inputImageHolder,'rectHandle');
if(~isempty(rectHandle))
    pos = getPosition(rectHandle);
    currentImage = imread(getappdata(thresholdUIArray.inputImageHolder,'currentImagePath'));
    showZoomedRegion(pos,currentImage,thresholdUIArray);
end

function setThreshold(handle,event,thresholdUIArray,parentThresholdEditHandle)

if(isempty(str2num(get(handle,'String'))))
    try
        if(str2num(get(thresholdUIArray.currentThresholdEdit,'String')))
            set(parentThresholdEditHandle,'String',get(thresholdUIArray.currentThresholdEdit,'String'));
        end
        
    catch errorMsg
        error('parentNotdefined','Parent EditBox Not found')
    end
end